//
//  YAML.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation


public enum YAMLError: ErrorType {
    case UnknownError
    case ParseError
}

public struct YAML {
    public static func load(input: String) throws -> YAMLNode {
        let parser = YAMLParser()
        return try parser.parse(input)
    }
}

private enum YAMLScalarState {
    case WaitingForKey
    case WaitingForValue
}

private class YAMLParser {
    let parser = UnsafeMutablePointer<yaml_parser_t>.alloc(sizeof(yaml_parser_t))
    let event = UnsafeMutablePointer<yaml_event_t>.alloc(sizeof(yaml_event_t))
    
    var state: YAMLScalarState = .WaitingForKey
    var currentKey: String = ""
    var level = 0

    var nodes = [YAMLNode]()
    var currentNode: YAMLNode {
        return self.nodes[self.level]
    }
    
    deinit {
        yaml_parser_delete(self.parser)
        yaml_event_delete(self.event)
    }
    
    func parse(input: String) throws -> YAMLNode {
        let initialized = yaml_parser_initialize(self.parser);
        guard initialized == 1 else {
            throw YAMLError.UnknownError
        }
        
        yaml_parser_set_input_string(self.parser, input, input.characters.count);
        
        var done = false
        while (!done) {
            guard yaml_parser_parse(self.parser, self.event) == 1 else {
                throw YAMLError.ParseError
            }
            done = handleEvent(self.event)
        }
        
        print("YAML node: \(self.nodes.first!)")
        return self.nodes.first!
    }
    
    private func handleEvent(event: UnsafeMutablePointer<yaml_event_t>) -> Bool {
        
        switch event.memory.type.rawValue {
        case YAML_STREAM_START_EVENT.rawValue:
            print("start stream")
            let rootNode = YAMLNode.Dictionary([String: YAMLNode]())
            self.nodes.append(rootNode)
        case YAML_DOCUMENT_START_EVENT.rawValue:
            print("document start")
            self.state = .WaitingForKey
        case YAML_DOCUMENT_END_EVENT.rawValue:
            print("document start")
            self.state = .WaitingForKey
        case YAML_ALIAS_EVENT.rawValue:
            print("alias event")
        case YAML_MAPPING_START_EVENT.rawValue:
            print("start mapping")
            self.handleMappingStartEvent(event)
        case YAML_MAPPING_END_EVENT.rawValue:
            print("end mapping")
            self.handleMappingEndEvent(event)
        case YAML_SEQUENCE_START_EVENT.rawValue:
            print("start sequence")
            self.state = .WaitingForKey
        case YAML_SEQUENCE_END_EVENT.rawValue:
            print("end sequence")
            self.state = .WaitingForKey
        case YAML_SCALAR_EVENT.rawValue:
            let value = yaml_event_scalar_value(event)
            let valueString = String.fromCString(yaml_cstring_char(value))!
            
            if case .WaitingForKey = state {
                print("key: \(valueString)")
                self.currentKey = valueString
                self.state = .WaitingForValue
            }
            else {
                print("value: \(valueString)")
//                self.currentNode[self.currentKey] = YAMLNode.String(valueString)
                self.state = .WaitingForKey
            }
            
        case YAML_STREAM_END_EVENT.rawValue:
            print("end stream")
            return true
        default:
            print("YAML: ENCOUNTERED UNKNOWN EVENT")
            return true
        }
        
        return false
    }
    
    private func handleMappingStartEvent(event: UnsafeMutablePointer<yaml_event_t>) {
        var currentNode = self.nodes[self.level]
        self.level++
        
        let newNode = YAMLNode.Dictionary([String: YAMLNode]())
        currentNode[self.currentKey] = newNode
        self.nodes.append(newNode)
    
        self.state = .WaitingForKey
    }
    
    private func handleMappingEndEvent(event: UnsafeMutablePointer<yaml_event_t>) {
        self.level--
        self.nodes.removeLast()
        self.state = .WaitingForKey
    }
}




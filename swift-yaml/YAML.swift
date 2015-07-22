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
    var currentKey: String?
    var level: Int = -1

    var rootNode: YAMLTree?
    var currentNode: YAMLTree?
    
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
        
        print("YAML root node: \(self.rootNode!.value)")
        return self.rootNode!.value
    }
    
    private func handleEvent(event: UnsafeMutablePointer<yaml_event_t>) -> Bool {
        
        switch event.memory.type.rawValue {
        case YAML_STREAM_START_EVENT.rawValue:
            print("start stream")
        case YAML_DOCUMENT_START_EVENT.rawValue:
            print("document start")
            let value: YAMLNode = [:]
            self.rootNode = YAMLTree(value: value, parent: nil)
            self.state = .WaitingForKey
        case YAML_DOCUMENT_END_EVENT.rawValue:
            print("document start")
            self.state = .WaitingForKey
        case YAML_ALIAS_EVENT.rawValue:
            print("alias event")
            self.state = .WaitingForKey
        case YAML_MAPPING_START_EVENT.rawValue:
            print("start mapping")
            let value: YAMLNode = [:]
            self.pushNode(value)
        case YAML_MAPPING_END_EVENT.rawValue:
            print("end mapping")
            self.popNode()
        case YAML_SEQUENCE_START_EVENT.rawValue:
            print("start sequence")
            let value: YAMLNode = []
            self.pushNode(value)
        case YAML_SEQUENCE_END_EVENT.rawValue:
            print("end sequence")
            self.popNode()
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
                if let node = self.currentNode {
                    node.value[self.currentKey!] = YAMLNode.String(valueString)
                }
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
    
    private func pushNode(value: YAMLNode) {
        self.level++
        guard self.level > 0 else {
            self.currentNode = self.rootNode
            return
        }
        
        let newNode = YAMLTree(value: value, parent: self.currentNode, key: self.currentKey!)
        self.currentNode!.children.append(newNode)
        self.currentNode = newNode
        
        self.state = .WaitingForKey
    }
    
    private func popNode() {
        self.level--
        
        if let parent = self.currentNode?.parent {
            if case .Array(var array) = parent.value {
                array.append(self.currentNode!.value)
                parent.value = YAMLNode.Array(array)
            }
            else if case .Dictionary(var dict) = parent.value {
                dict[self.currentNode!.key!] = self.currentNode!.value
                parent.value = YAMLNode.Dictionary(dict)
            }
        }
        
        self.currentNode = self.currentNode!.parent
        self.state = .WaitingForKey
    }
}

private class YAMLTree {
    let parent: YAMLTree?
    var children = [YAMLTree]()
    
    let key: String?
    var value: YAMLNode
    
    var level: Int {
        var level = 0
        var parent = self.parent
        while parent != nil {
            parent = parent?.parent
            level++
        }
        return level
    }
    
    init(value: YAMLNode, parent: YAMLTree?, key: String? = nil) {
        self.value = value;
        self.parent = parent
        self.key = key
    }
}

extension YAMLTree: CustomDebugStringConvertible {
    var debugDescription: String {
        
        var prefix = ""
        for _ in 0...self.level {
            prefix += "  "
        }
        
        var desc = "\n\(prefix)\(self.level). value: \(self.value), key: \(self.key)"
        for child in self.children {
            desc += "\n\(prefix) child: \(child)"
        }
        
        return desc
    }
}




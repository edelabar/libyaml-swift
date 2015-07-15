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

private struct YAMLParser {
    
    func parse(input: String) throws -> YAMLNode {
        let parser = UnsafeMutablePointer<yaml_parser_t>.alloc(sizeof(yaml_parser_t))
        let event = UnsafeMutablePointer<yaml_event_t>.alloc(sizeof(yaml_event_t))
        defer {
            yaml_parser_delete(parser)
            yaml_event_delete(event)
        }
        
        let initialized = yaml_parser_initialize(parser);
        guard initialized == 1 else {
            throw YAMLError.UnknownError
        }
        
        yaml_parser_set_input_string(parser, input, input.characters.count);
        
        var done = false
        var state: YAMLScalarState = .WaitingForKey
        var currentMapping = YAMLNode.None
        var currentKey: String = ""
        while (!done) {
            guard yaml_parser_parse(parser, event) == 1 else {
                throw YAMLError.ParseError
            }
            
            switch event.memory.type.rawValue {
            case YAML_STREAM_START_EVENT.rawValue:
                print("start stream")
            case YAML_DOCUMENT_START_EVENT.rawValue:
                print("document start")
                state = .WaitingForKey
            case YAML_DOCUMENT_END_EVENT.rawValue:
                print("document start")
                state = .WaitingForKey
            case YAML_ALIAS_EVENT.rawValue:
                print("alias event")
            case YAML_MAPPING_START_EVENT.rawValue:
                print("start mapping")
                currentMapping = .Dictionary([String: YAMLNode]())
                state = .WaitingForKey
            case YAML_MAPPING_END_EVENT.rawValue:
                print("end mapping")
                state = .WaitingForKey
            case YAML_SEQUENCE_START_EVENT.rawValue:
                print("start sequence")
                state = .WaitingForKey
            case YAML_SEQUENCE_END_EVENT.rawValue:
                print("end sequence")
                state = .WaitingForKey
            case YAML_SCALAR_EVENT.rawValue:
                let value = yaml_event_scalar_value(event)
                let valueString = String.fromCString(yaml_cstring_char(value))!
                
                if case .WaitingForKey = state {
                    print("key: \(valueString)")
                    currentKey = valueString
                    state = .WaitingForValue
                }
                else {
                    print("value: \(valueString)")
                    currentMapping[currentKey] = YAMLNode.String(valueString)
                    state = .WaitingForKey
                }
                
            case YAML_STREAM_END_EVENT.rawValue:
                print("end stream")
                done = true
            default:
                print("EVENT NOT YET IMPLEMENTED!!!")
            }
        }
        
        print("YAML node: \(currentMapping)")
        return currentMapping
    }
    
    
}




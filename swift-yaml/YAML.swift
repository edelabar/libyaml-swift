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
            self.state = .WaitingForKey
        case YAML_DOCUMENT_START_EVENT.rawValue:
            let value: YAMLNode = [:]
            self.rootNode = YAMLTree(value: value, parent: nil)
            self.state = .WaitingForKey
        case YAML_DOCUMENT_END_EVENT.rawValue:
            self.state = .WaitingForKey
        case YAML_ALIAS_EVENT.rawValue:
            let anchor = String.fromCString(yaml_cstring_char(yaml_event_alias_anchor(event)))
            if let anchor = anchor, let currentNode = self.currentNode, let anchorNode = self.rootNode?.treeWithAnchor(anchor) {
                currentNode.value[self.currentKey!] = anchorNode.value
                currentNode.children.append(anchorNode)
            }
            self.state = .WaitingForKey
        case YAML_MAPPING_START_EVENT.rawValue:
            let value: YAMLNode = [:]
            let anchor = String.fromCString(yaml_cstring_char(yaml_event_mapping_start_anchor(event)))
            self.pushNode(value, anchor: anchor)
        case YAML_MAPPING_END_EVENT.rawValue:
            self.popNode()
        case YAML_SEQUENCE_START_EVENT.rawValue:
            let value: YAMLNode = []
            self.pushNode(value)
        case YAML_SEQUENCE_END_EVENT.rawValue:
            self.popNode()
        case YAML_SCALAR_EVENT.rawValue:
            let value = yaml_event_scalar_value(event)
            let valueString = String.fromCString(yaml_cstring_char(value))!
            
            if case .WaitingForKey = state {
//                print("key: \(valueString)")
                self.currentKey = valueString
                self.state = .WaitingForValue
            }
            else {
//                print("value: \(valueString)")
                if let node = self.currentNode {
                    node.value[self.currentKey!] = YAMLNode.String(valueString)
                }
                self.state = .WaitingForKey
            }
            
        case YAML_STREAM_END_EVENT.rawValue:
            return true
        default:
            print("YAML: ENCOUNTERED UNKNOWN EVENT")
            return true
        }
        
        return false
    }
    
    private func pushNode(value: YAMLNode, anchor: String? = nil) {
        self.level++
        guard self.level > 0 else {
            self.currentNode = self.rootNode
            return
        }
        
        let newNode = YAMLTree(value: value, parent: self.currentNode, key: self.currentKey!, anchor: anchor)
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
    
    let anchor: String?
        
    init(value: YAMLNode, parent: YAMLTree?, key: String? = nil, anchor: String? = nil) {
        self.value = value;
        self.parent = parent
        self.key = key
        self.anchor = anchor
    }
    
    func treeWithAnchor(anchor: String) -> YAMLTree? {
        if self.anchor == anchor {
            return self
        }
        
        for child in self.children {
            if let tree = child.treeWithAnchor(anchor) {
                return tree
            }
        }
        
        return nil
    }
}




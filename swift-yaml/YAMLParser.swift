//
//  YAMLParser.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

private enum YAMLScalarState {
    case waitingForKey
    case waitingForValue
}

class YAMLParser {
    fileprivate let parser = UnsafeMutablePointer<yaml_parser_t>.allocate(capacity: MemoryLayout<yaml_parser_t>.size)
    fileprivate let event = UnsafeMutablePointer<yaml_event_t>.allocate(capacity: MemoryLayout<yaml_event_t>.size)
    
    fileprivate var state: YAMLScalarState = .waitingForKey
    fileprivate var currentKey: YAMLValue?
    fileprivate var level: Int = 0
    
    fileprivate var rootNodes: [YAMLTree]
    fileprivate var currentRootNode: YAMLTree? {
        return rootNodes.last
    }
    fileprivate var currentNode: YAMLTree?
    
    // whether parser should allow multiple documents in string
    let allowMultiple: Bool
    
    deinit {
        yaml_parser_delete(parser)
        free(parser)
        free(event)
    }
    
    init(allowMultiple: Bool = false) {
        self.allowMultiple = allowMultiple
        self.rootNodes = []
    }
    
    func parse(_ input: String) throws -> [YAMLValue] {
        let initialized = yaml_parser_initialize(self.parser)
        guard initialized == 1 else {
            throw YAMLError.unknownError
        }
        
        yaml_parser_set_input_string(self.parser, input, input.utf8.count);
        
        var done = false
        while (!done) {
            guard yaml_parser_parse(self.parser, self.event) == 1 else {
                throw YAMLError.parseError
            }
            done = try handleEvent(self.event)
            yaml_event_delete(self.event)
        }
        
        return self.rootNodes.map({ node in
            return node.value
        })
    }
    
    fileprivate func handleEvent(_ event: UnsafeMutablePointer<yaml_event_t>) throws -> Bool {
        
        switch event.pointee.type.rawValue {
        case YAML_STREAM_START_EVENT.rawValue:
            self.state = .waitingForValue
        case YAML_DOCUMENT_START_EVENT.rawValue:
            self.state = .waitingForValue
        case YAML_DOCUMENT_END_EVENT.rawValue:
            self.level = 0
            self.currentKey = nil
            self.currentNode = nil
        case YAML_ALIAS_EVENT.rawValue:
            if let cString = yaml_cstring_char(yaml_event_alias_anchor(event)) {
                let anchor = String(cString: cString)
                if let currentNode = currentNode, let anchorNode = currentRootNode?.treeWithAnchor(anchor) {
                    currentNode.value[self.currentKey!] = anchorNode.value
                    currentNode.children.append(anchorNode)
                }
            }
            self.state = .waitingForKey
        case YAML_MAPPING_START_EVENT.rawValue:
            let value: YAMLValue = [:]
            if let cString = yaml_cstring_char(yaml_event_mapping_start_anchor(event)) {
                let anchor = String(cString: cString)
                self.pushNode(value, anchor: anchor)
            }
            self.state = .waitingForKey
        case YAML_MAPPING_END_EVENT.rawValue:
            self.popNode()
        case YAML_SEQUENCE_START_EVENT.rawValue:
            let value: YAMLValue = []
            if let cString = yaml_cstring_char(yaml_event_sequence_start_anchor(event)) {
                let anchor = String(cString: cString)
                self.pushNode(value, anchor: anchor)
            }
            self.state = .waitingForValue
        case YAML_SEQUENCE_END_EVENT.rawValue:
            self.popNode()
        case YAML_SCALAR_EVENT.rawValue:
            let (_, value) = try valueForScalarEvent(event)
            if case .waitingForKey = state {
                self.currentKey = value
                self.state = .waitingForValue
            }
            else {
                if let node = self.currentNode {
                    if case .dictionary(_) = node.value {
                        node.value[self.currentKey!] = value
                        self.state = .waitingForKey
                    }
                    else if case .array(var array) = node.value {
                        array.append(value)
                        node.value = YAMLValue.array(array)
                        self.state = .waitingForValue
                    }
                }
                else {
                    // when there is no current node, this means this is the root node
                    self.pushNode(value)
                }
            }
        case YAML_STREAM_END_EVENT.rawValue:
            return true
        default:
            throw YAMLError.parseError
        }
        
        return false
    }
    
    fileprivate func pushNode(_ value: YAMLValue, anchor: String? = nil) {
        defer {
            self.level += 1
        }
        
        if self.level == 0 {
            let rootNode = YAMLTree(value: value, parent: nil)
            self.currentNode = rootNode
            self.rootNodes.append(rootNode)
            return
        }
        
        let newNode = YAMLTree(value: value, parent: self.currentNode, key: self.currentKey!, anchor: anchor)
        self.currentNode!.children.append(newNode)
        self.currentNode = newNode
        
    }
    
    fileprivate func popNode() {
        self.level -= 1
        
        if let parent = self.currentNode?.parent {
            if case .array(var array) = parent.value {
                array.append(self.currentNode!.value)
                parent.value = YAMLValue.array(array)
            }
            else if case .dictionary(var dict) = parent.value {
                dict[self.currentNode!.key!] = self.currentNode!.value
                parent.value = YAMLValue.dictionary(dict)
            }
        }
        
        self.currentNode = self.currentNode?.parent
    }
    
    fileprivate func valueForScalarEvent(_ event: UnsafeMutablePointer<yaml_event_t>) throws ->  (String, YAMLValue) {
        let value = yaml_event_scalar_value(event)
        guard let stringValue = String(validatingUTF8: yaml_cstring_char(value)) else {
            throw YAMLError.parseError
        }
        
        let tag = yaml_event_scalar_tag(event);
        if let cString = yaml_cstring_char(tag) {
            let tagString = String(cString: cString)
            print("tag: \(tagString)")
            
            if tagString == YAML_NULL_TAG {
                return (stringValue, YAMLValue.none)
            }
            else if tagString == YAML_STR_TAG {
                return (stringValue, YAMLValue.string(stringValue))
            }
            else if tagString == YAML_TIMESTAMP_TAG {
                // TODO: handle timestamp tag
            }
            else if tagString == YAML_BOOL_TAG || tagString == YAML_INT_TAG || tagString == YAML_FLOAT_TAG {
                // do nothing because casting does not apply here
            }
        }
        
        let style = yaml_event_scalar_style(event)
        if style == YAML_PLAIN_SCALAR_STYLE {
            let scanner = Scanner(string: stringValue)
            if scanner.scanInt32(nil) && scanner.scanLocation == stringValue.characters.count {
                let int = Int(stringValue)!
                return (stringValue, YAMLValue.int(int))
            }
            else if scanner.scanDouble(nil) && scanner.scanLocation == stringValue.characters.count {
                let double = Double(stringValue)!
                return (stringValue, YAMLValue.double(double))
            }
            else if ["true", "True", "TRUE"].contains(stringValue) {
                return (stringValue, YAMLValue.bool(true))
            }
            else if ["false", "False", "FALSE"].contains(stringValue) {
                return (stringValue, YAMLValue.bool(false))
            }
            else if ["", "null", "~"].contains(stringValue) {
                return (stringValue, YAMLValue.none)
            }
            
            // TODO: add support for HEX values
        }
        
        return (stringValue, YAMLValue.string(stringValue))
    }
}

private class YAMLTree {
    weak var parent: YAMLTree?
    var children = [YAMLTree]()
    
    let key: YAMLValue?
    var value: YAMLValue
    
    let anchor: String?
    
    init(value: YAMLValue, parent: YAMLTree?, key: YAMLValue? = nil, anchor: String? = nil) {
        self.value = value;
        self.parent = parent
        self.key = key
        self.anchor = anchor
    }
    
    func treeWithAnchor(_ anchor: String) -> YAMLTree? {
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


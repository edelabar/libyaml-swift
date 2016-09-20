//
//  YAML.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation


public enum YAMLError: Error {
    case unknownError
    case parseError
}

public struct YAML {
    public static func load(_ input: String) throws -> YAMLValue {
        let parser = YAMLParser()
        let output = try parser.parse(input)
        if let first = output.first {
            return first
        }
        else {
            return YAMLValue.none
        }
    }
    
    public static func loadMultiple(_ input: String) throws -> [YAMLValue] {
        let parser = YAMLParser(allowMultiple: true)
        return try parser.parse(input)
    }
    
    public static func emit(_ yaml: YAMLValue) throws -> String {
        let emitter = YAMLEmitter()
        return try emitter.emit(yaml)
    }
}


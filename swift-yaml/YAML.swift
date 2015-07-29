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
    public static func load(input: String) throws -> YAMLValue {
        let parser = YAMLParser()
        let output = try parser.parse(input)
        if let first = output.first {
            return first
        }
        else {
            throw YAMLError.UnknownError
        }
    }
    
    public static func loadMultiple(input: String) throws -> [YAMLValue] {
        let parser = YAMLParser(allowMultiple: true)
        return try parser.parse(input)
    }
    
    public static func emit(yaml: YAMLValue) throws -> String {
        let emitter = YAMLEmitter()
        return try emitter.emit(yaml)
    }
}


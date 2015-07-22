//
//  YAMLNode.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

public enum YAMLValue {
    case None
    case Bool(Swift.Bool)
    case Int(Swift.Int)
    case Double(Swift.Double)
    case String(Swift.String)
    case Array([YAMLValue])
    case Dictionary([Swift.String: YAMLValue])
}

extension YAMLValue: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .None:
            return 0
        case .String(let string):
            return string.hash
        case .Bool(let bool):
            return Swift.Int(bool)
        case .Int(let int):
            return int
        case .Double(let double):
            return Swift.Int(double)
        case .Array(let array):
            return array.reduce(0, combine: { $0 + $1.hashValue })
        case .Dictionary(let dictionary):
            return dictionary.keys.reduce(0) { $0 + $1.hashValue }
        }
    }
}

extension YAMLValue: Equatable {}
public func == (lhs: YAMLValue, rhs: YAMLValue) -> Bool {
    var equal = false
    switch lhs {
    case .None:
        if case .None = rhs { equal = true }
    case .String(let lv):
        if case .String(let rv) = rhs { equal = (lv == rv) }
    case .Bool(let lv):
        if case .Bool(let rv) = rhs { equal = (lv == rv) }
    case .Int(let lv):
        if case .Int(let rv) = rhs { equal == (lv == rv) }
    case .Double(let lv):
        if case .Double(let rv) = rhs { equal == (lv == rv) }
    case .Array(let lv):
        if case .Array(let rv) = rhs { equal == (lv == rv) }
    case .Dictionary(let lv):
        if case .Dictionary(let rv) = rhs { equal = (lv == rv) }
    }
    return equal
}

extension YAMLValue: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = .None
    }
}

extension YAMLValue: BooleanLiteralConvertible {
    public init(booleanLiteral: BooleanLiteralType) {
        self = .Bool(booleanLiteral)
    }
}

extension YAMLValue: IntegerLiteralConvertible {
    public init(integerLiteral: IntegerLiteralType) {
        self = .Int(integerLiteral)
    }
}

extension YAMLValue: FloatLiteralConvertible {
    public init(floatLiteral: FloatLiteralType) {
        self = .Double(floatLiteral)
    }
}

extension YAMLValue: StringLiteralConvertible {
    public init(stringLiteral: StringLiteralType) {
        self = .String(stringLiteral)
    }
    
    public init(extendedGraphemeClusterLiteral: StringLiteralType) {
        self = .String(extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: StringLiteralType) {
        self = .String(unicodeScalarLiteral)
    }
}

extension YAMLValue: ArrayLiteralConvertible {
    public init(arrayLiteral elements: YAMLValue...) {
        var array = [YAMLValue]()
        array.reserveCapacity(elements.count)
        for element in elements {
            array.append(element)
        }
        self = .Array(array)
    }
}

extension YAMLValue: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (Swift.String, YAMLValue)...) {
        var dictionary = Swift.Dictionary<Swift.String, YAMLValue>()
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .Dictionary(dictionary)
    }
}

extension YAMLValue {
    subscript(key: Swift.String) -> YAMLValue? {
        get {
            switch self {
            case .Dictionary(let dictionary):
                return dictionary[key]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .Dictionary(var dictionary):
                dictionary[key] = newValue
                self = .Dictionary(dictionary)
            default:
                assert(false, "Can't use subscript on type which is not a dictionary")
            }
        }
    }
}

extension YAMLValue: CustomDebugStringConvertible {
    public var debugDescription: Swift.String {
        switch self {
        case .None:
            return "None"
        case .Bool(let b):
            return "Bool(\(b))"
        case .Int(let i):
            return "Int(\(i))"
        case .Double(let f):
            return "Double(\(f))"
        case .String(let s):
            return "String(\(s))"
        case .Array(let s):
            return "Array(\(s))"
        case .Dictionary(let m):
            return "Dictionary(\(m))"
        }
    }
}


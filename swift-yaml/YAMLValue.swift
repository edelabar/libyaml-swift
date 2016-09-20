//
//  YAMLNode.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

public enum YAMLValue {
    case none
    case bool(Swift.Bool)
    case int(Swift.Int)
    case double(Swift.Double)
    case string(Swift.String)
    case array([YAMLValue])
    case dictionary([YAMLValue: YAMLValue])
}

extension YAMLValue: Hashable {
    public var hashValue: Swift.Int {
        switch self {
        case .none:
            return 0
        case .string(let string):
            return string.hash
        case .bool(let bool):
            return bool ? 1 : 0
        case .int(let int):
            return int
        case .double(let double):
            return Swift.Int(double)
        case .array(let array):
            return array.reduce(0, { $0 + $1.hashValue })
        case .dictionary(let dictionary):
            return dictionary.keys.reduce(0) { $0 + $1.hashValue }
        }
    }
}

extension YAMLValue: Equatable {}
public func == (lhs: YAMLValue, rhs: YAMLValue) -> Bool {
    var equal = false
    switch lhs {
    case .none:
        if case .none = rhs { equal = true }
    case .string(let lv):
        if case .string(let rv) = rhs { equal = (lv == rv) }
    case .bool(let lv):
        if case .bool(let rv) = rhs { equal = (lv == rv) }
    case .int(let lv):
        if case .int(let rv) = rhs { equal = (lv == rv) }
    case .double(let lv):
        if case .double(let rv) = rhs { equal = (lv == rv) }
    case .array(let lv):
        if case .array(let rv) = rhs { equal = (lv == rv) }
    case .dictionary(let lv):
        if case .dictionary(let rv) = rhs { equal = (lv == rv) }
    }
    return equal
}

extension YAMLValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .none
    }
}

extension YAMLValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral: BooleanLiteralType) {
        self = .bool(booleanLiteral)
    }
}

extension YAMLValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral: IntegerLiteralType) {
        self = .int(integerLiteral)
    }
}

extension YAMLValue: ExpressibleByFloatLiteral {
    public init(floatLiteral: FloatLiteralType) {
        self = .double(floatLiteral)
    }
}

extension YAMLValue: ExpressibleByStringLiteral {
    public init(stringLiteral: StringLiteralType) {
        self = .string(stringLiteral)
    }
    
    public init(extendedGraphemeClusterLiteral: StringLiteralType) {
        self = .string(extendedGraphemeClusterLiteral)
    }
    
    public init(unicodeScalarLiteral: StringLiteralType) {
        self = .string(unicodeScalarLiteral)
    }
}

extension YAMLValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: YAMLValue...) {
        var array = [YAMLValue]()
        array.reserveCapacity(elements.count)
        for element in elements {
            array.append(element)
        }
        self = .array(array)
    }
}

extension YAMLValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (YAMLValue, YAMLValue)...) {
        var dictionary = Swift.Dictionary<YAMLValue, YAMLValue>()
        for (k, v) in elements {
            dictionary[k] = v
        }
        self = .dictionary(dictionary)
    }
}

extension YAMLValue {
    subscript(key: Swift.String) -> YAMLValue? {
        get {
            switch self {
            case .dictionary(let dictionary):
                return dictionary[YAMLValue.string(key)]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .dictionary(var dictionary):
                dictionary[YAMLValue.string(key)] = newValue
                self = .dictionary(dictionary)
            default:
                assert(false, "Can't use subscript on type which is not a dictionary")
            }
        }
    }
    
    subscript(key: YAMLValue) -> YAMLValue? {
        get {
            switch self {
            case .dictionary(let dictionary):
                return dictionary[key]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .dictionary(var dictionary):
                dictionary[key] = newValue
                self = .dictionary(dictionary)
            default:
                assert(false, "Can't use subscript on type which is not a dictionary")
            }
        }
    }
}

extension YAMLValue: CustomDebugStringConvertible {
    public var debugDescription: Swift.String {
        switch self {
        case .none:
            return "None"
        case .bool(let b):
            return "Bool(\(b))"
        case .int(let i):
            return "Int(\(i))"
        case .double(let f):
            return "Double(\(f))"
        case .string(let s):
            return "String(\(s))"
        case .array(let s):
            return "Array(\(s))"
        case .dictionary(let m):
            return "Dictionary(\(m))"
        }
    }
}


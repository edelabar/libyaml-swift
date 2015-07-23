//
//  swift_yamlTests.swift
//  swift-yamlTests
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import XCTest
@testable import SwiftYAML

class SwiftYAMLTests: XCTestCase {
    
//    func testFile1() {
//        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("test1", ofType: "yml")!
//        let YAMLString = try! String(contentsOfFile: filePath)
//        try! YAML.load(YAMLString)
//    }
//    
//    func testFile2() {
//        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("test2", ofType: "yml")!
//        let YAMLString = try! String(contentsOfFile: filePath)
//        try! YAML.load(YAMLString)
//    }
//    func testASCIIArt() {
//        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("ascii", ofType: "yml")!
//        let YAMLString = try! String(contentsOfFile: filePath)
//        try! YAML.load(YAMLString)
//    }
    
    ///-------------------------------------------------
    /// @name Scalars
    ///-------------------------------------------------
    
    func testScalarValue() {
        let YAMLString = "foo: bar"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["foo": "bar"]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarIntegerValue() {
        let YAMLString = "amount: 5"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["amount": 5]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarDoubleValue() {
        let YAMLString = "price: 9.99"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["price": 9.99]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarBooleanValue() {
        let YAMLString = "true: true\n" +
                         "false: false"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["true": true, "false": false]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarNullValue() {
        let YAMLString = "nothing: null"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["nothing": nil]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarEmptyValue() {
        let YAMLString = "nothing: "
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["nothing": nil]
        XCTAssertEqual(value, expected)
    }
    
    func testScalarTildeValue() {
        let YAMLString = "nothing: ~"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["nothing": nil]
        XCTAssertEqual(value, expected)
    }
    
    ///-------------------------------------------------
    /// @name Mappings and sequences
    ///-------------------------------------------------
    
    func testArrayValue() {
        let YAMLString = "products:\n" +
                         "  - name: foo\n" +
                         "    sku: 1\n" +
                         "  - name: bar\n" +
                         "    sku: 2"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["products": [["name": "foo", "sku": 1], ["name": "bar", "sku": 2]]]
        XCTAssertEqual(value, expected)
    }
    
//    func testMappingValue {
//        let YAMLString = "products:\n" +
//            "  - name: foo\n" +
//            "    sku: 1\n" +
//            "  - name: bar\n" +
//        "    sku: 2"
//        let value = try! YAML.load(YAMLString)
//        let expected: YAMLValue = ["products": [["name": "foo", "sku": 1], ["name": "bar", "sku": 2]]]
//        XCTAssertEqual(value, expected)
//    }

    ///-------------------------------------------------
    /// @name Tags
    ///-------------------------------------------------
    
    func testValueForNullKey() {
        let YAMLString = "!!null key: value"
        let value = try! YAML.load(YAMLString)
        // we expect an empty dictionary, because 'null' keys are skipped over
        let expected: YAMLValue = [:]
        XCTAssertEqual(value, expected)
    }
    
    func testNullValueForKey() {
        let YAMLString = "key: !!null value"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["key": nil]
        XCTAssertEqual(value, expected)
    }
}

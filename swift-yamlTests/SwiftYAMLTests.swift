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
        // keys as well as values can represent booleans
        let expected: YAMLValue = [true: true, false: false]
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
    /// @name Collections
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
    
    func testMappingValue() {
        let YAMLString = "bill-to:\n" +
                         "  given: Chris\n" +
                         "  family: Dumars"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["bill-to": ["given": "Chris", "family": "Dumars"]]
        XCTAssertEqual(value, expected)
    }

    ///-------------------------------------------------
    /// @name Tags
    ///-------------------------------------------------
    
    func testValueForNullKey() {
        let YAMLString = "!!null key: value"
        let value = try! YAML.load(YAMLString)
        // we expect an empty dictionary, because 'null' keys are skipped over
        let expected: YAMLValue = [YAMLValue.None: "value"]
        XCTAssertEqual(value, expected)
    }
    
    func testNullValueForKey() {
        let YAMLString = "key: !!null value"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["key": nil]
        XCTAssertEqual(value, expected)
    }
    
    func testBoolTag() {
        let YAMLString = "foo: !!bool true\n" +
                         "bar: !!bool 0"
        let value = try! YAML.load(YAMLString)
        // expect bar to be integer because integers can not be cast to bool
        let expected: YAMLValue = ["foo": true, "bar": 0]
        XCTAssertEqual(value, expected)
    }
    
    func testStringTag() {
        let YAMLString = "foo: !!str 0"
        let value = try! YAML.load(YAMLString)
        // expect bar to be integer because integers can not be cast to bool
        let expected: YAMLValue = ["foo": "0"]
        XCTAssertEqual(value, expected)
    }
    
    ///-------------------------------------------------
    /// @name Aliases
    ///-------------------------------------------------
    
    func testAlias() {
        let YAMLString = "bill-to: &id001 \n" +
                         "  given: Chris\n" +
                         "  family: Dumars\n" +
                         "ship-to: *id001"
        let value = try! YAML.load(YAMLString)
        let address: YAMLValue = ["given": "Chris", "family": "Dumars"]
        let expected: YAMLValue = ["bill-to": address, "ship-to": address]
        XCTAssertEqual(value, expected)
    }
    
    func testSelfReferencingAlias() {
        let YAMLString = "tree: &parent \n" +
                         "  node: null\n" +
                         "  parent: *parent \n"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["tree": ["node": nil, "parent": ["node": nil]]]
        XCTAssertEqual(value, expected)
    }
    
    ///-------------------------------------------------
    /// @name Other
    ///-------------------------------------------------
    
    func testScalarRootValue() {
        let YAMLString = "foo"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = "foo"
        XCTAssertEqual(value, expected)
    }
    
    func testSequenceRootValue() {
        let YAMLString = "- foo\n" +
        "- bar"
        let value = try! YAML.load(YAMLString)
        let expected: YAMLValue = ["foo", "bar"]
        XCTAssertEqual(value, expected)
    }
    
    func testIllegalMapping() {
        let YAMLString = "foo\n" +
        "foo: bar"
        XCTempAssertThrowsSpecificError(YAMLError.ParseError) { try YAML.load(YAMLString) }
    }
}

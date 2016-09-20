//
//  YAMLEmitterTests.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 29/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import XCTest
@testable import SwiftYAML

class YAMLEmitterTests: XCTestCase {

    ///-------------------------------------------------
    /// @name Helpers
    ///-------------------------------------------------
    
    func emitAndParse(_ value: YAMLValue) -> YAMLValue {
        let output = try! YAML.emit(value)
        return try! YAML.load(output)
    }
    
    ///-------------------------------------------------
    /// @name Scalars
    ///-------------------------------------------------
    
    func testScalarString() {
        let value: YAMLValue = "foo"
        let output = self.emitAndParse(value)
        XCTAssertEqual(value, output)
    }
    
    func testScalarIntegerValue() {
        let value: YAMLValue = 5
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    func testScalarDoubleValue() {
        let value: YAMLValue = ["price": 9.99]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    func testScalarBooleanValue() {
        let value: YAMLValue = [true: true, false: false]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    func testScalarNullValue() {
        let value: YAMLValue = ["nothing": nil]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    ///-------------------------------------------------
    /// @name Collections
    ///-------------------------------------------------

    func testMapping() {
        let value: YAMLValue = ["foo": "bar"]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    func testSequence() {
        let value: YAMLValue = ["products": [["name": "foo", "sku": 1], ["name": "bar", "sku": 2]]]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
    
    func testSequenceRootValue() {
        let value: YAMLValue = ["foo", "bar"]
        let output = self.emitAndParse(value)
        XCTAssertEqual(output, value)
    }
}

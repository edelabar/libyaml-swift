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

    func testScalarString() {
        let value: YAMLValue = "foo"
        let output = try! YAML.emit(value)
        XCTAssertEqual(output, "--- foo\n...\n")
    }

    func testMapping() {
        let value: YAMLValue = ["foo": "bar"]
        let output = try! YAML.emit(value)
        XCTAssertEqual(output, "---\nfoo: bar\n")
    }
}

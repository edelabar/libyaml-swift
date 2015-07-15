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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialize() {
        try! YAML.load("title: Hello world\nsubtitle: Hello subtitle")
    }
    
    func testFile1() {
        let filePath = NSBundle(forClass: self.dynamicType).pathForResource("test1", ofType: "yml")!
        let YAMLString = try! String(contentsOfFile: filePath)
        try! YAML.load(YAMLString)
    }
    
}

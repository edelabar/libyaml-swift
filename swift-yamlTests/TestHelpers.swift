//
//  TestHelpers.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import XCTest

func XCTempAssertThrowsError(_ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
    do {
        try block()
        
        let msg = (message == "") ? "Tested block did not throw error as expected." : message
        XCTFail(msg, file: file, line: line)
    }
    catch {}
}

func XCTempAssertThrowsSpecificError(_ kind: Error, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
    do {
        try block()
        
        let msg = (message == "") ? "Tested block did not throw expected \(kind) error." : message
        XCTFail(msg, file: file, line: line)
    }
    catch let error as NSError {
        let expected = kind as NSError
        if ((error.domain != expected.domain) || (error.code != expected.code)) {
            let msg = (message == "") ? "Tested block threw \(error), not expected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
}

func XCTempAssertNoThrowError(_ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
    do {try block()}
    catch {
        let msg = (message == "") ? "Tested block threw unexpected error." : message
        XCTFail(msg, file: file, line: line)
    }
}


func XCTempAssertNoThrowSpecificError(_ kind: Error, _ message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
    do {try block()}
    catch let error as NSError {
        let unwanted = kind as NSError
        if ((error.domain == unwanted.domain) && (error.code == unwanted.code)) {
            let msg = (message == "") ? "Tested block threw unexpected \(kind) error." : message
            XCTFail(msg, file: file, line: line)
        }
    }
}

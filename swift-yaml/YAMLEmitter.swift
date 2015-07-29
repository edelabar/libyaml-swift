//
//  YAMLEmitter.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

class YAMLEmitter {
    func emit(yaml: YAMLValue) throws -> String {
        let emitter = UnsafeMutablePointer<yaml_emitter_t>.alloc(sizeof(yaml_emitter_t))
        defer { yaml_emitter_delete(emitter) }
        
        let initialized = yaml_emitter_initialize(emitter)
        guard initialized == 1 else {
            throw YAMLError.UnknownError
        }
        return ""
    }
}
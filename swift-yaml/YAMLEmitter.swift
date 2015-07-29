//
//  YAMLEmitter.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

class YAMLEmitter {
    private static let bufferSize = 65536
    
    func emit(yaml: YAMLValue) throws -> String {
        let emitter = UnsafeMutablePointer<yaml_emitter_t>.alloc(sizeof(yaml_emitter_t))
        guard yaml_emitter_initialize(emitter) == 1 else {
            print("unable to initialize emitter")
            throw YAMLError.UnknownError
        }        
        defer { yaml_emitter_delete(emitter) }

//        func writeHandler(data: UnsafeMutablePointer<Void>, buffer: UnsafeMutablePointer<UInt8>, size: Int) -> Int32 {
//            return Int32(0)
//        }
//        yaml_emitter_set_output(emitter, writeHandler, nil)
        
        
        yaml_emitter_set_canonical(emitter, 1)
        
        let output = UnsafeMutablePointer<UInt8>.alloc(YAMLEmitter.bufferSize)
        memset(output, 0, YAMLEmitter.bufferSize)
        defer {
            output.destroy()
            output.dealloc(YAMLEmitter.bufferSize)
        }
        
        var sizeWritten: Int = 0
        yaml_emitter_set_output_string(emitter, output, YAMLEmitter.bufferSize, &sizeWritten)
        
        let event = UnsafeMutablePointer<yaml_event_t>.alloc(sizeof(yaml_event_t))
        defer { yaml_event_delete(event) }

        // start stream
        yaml_stream_start_event_initialize(event, YAML_UTF8_ENCODING)
        yaml_emitter_emit(emitter, event)

        // start document
        yaml_document_start_event_initialize(event, nil, nil, nil, 1)
        yaml_emitter_emit(emitter, event)

//        // populate document
        emitYAMLValue(emitter, event: event, value: yaml)

        // end document
        yaml_document_end_event_initialize(event, 1)
        yaml_emitter_emit(emitter, event)

        // end stream
        yaml_stream_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
        
        let outputString = String.fromCString(yaml_cstring_uint8(output))!
        print("emitter output: \(outputString)")
        return outputString
    }
    
    private func emitYAMLValue(emitter: UnsafeMutablePointer<yaml_emitter_t>, event: UnsafeMutablePointer<yaml_event_t>, value: YAMLValue) {
        
        switch value {
        case .String(let string):
            yaml_scalar_event_initialize(event, nil, nil, yaml_char_from_string(string), Int32(string.characters.count), 1, 1, YAML_PLAIN_SCALAR_STYLE)
            yaml_emitter_emit(emitter, event)
        default:
            print("nothing to see here")
        }
    }
}
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

        yaml_emitter_set_unicode(emitter, 1)
        yaml_emitter_set_encoding(emitter, YAML_UTF8_ENCODING)
        yaml_emitter_set_indent(emitter, 2)
        
        var outputStream = NSOutputStream.outputStreamToMemory()
        outputStream.open()
        defer { outputStream.close() }
        func writeHandler(data: UnsafeMutablePointer<Void>, buffer: UnsafeMutablePointer<UInt8>, size: Int) -> Int32 {
            let outputPointer = UnsafeMutablePointer<NSOutputStream>(data)
            let outputStream: NSOutputStream = outputPointer.memory
            let success = outputStream.write(buffer, maxLength: size) > 0
            return success ? 1 : 0
        }
        
        yaml_emitter_set_output(emitter, writeHandler, &outputStream)
        
        let event = UnsafeMutablePointer<yaml_event_t>.alloc(sizeof(yaml_event_t))
        defer { yaml_event_delete(event) }

        // start stream
        yaml_stream_start_event_initialize(event, YAML_UTF8_ENCODING)
        yaml_emitter_emit(emitter, event)

        // start document
        yaml_document_start_event_initialize(event, nil, nil, nil, 0)
        yaml_emitter_emit(emitter, event)

        // populate document
        emitYAMLValue(emitter, event: event, value: yaml)

        // end document
        yaml_document_end_event_initialize(event, 1)
        yaml_emitter_emit(emitter, event)

        // end stream
        yaml_stream_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
        
        let outputData = outputStream.propertyForKey(NSStreamDataWrittenToMemoryStreamKey) as! NSData
        let outputString = NSString(data: outputData, encoding: NSUTF8StringEncoding)!
        print(outputString)
        return outputString as String
    }
    
    private func emitYAMLValue(emitter: UnsafeMutablePointer<yaml_emitter_t>, event: UnsafeMutablePointer<yaml_event_t>, value: YAMLValue) {
        switch value {
        case .Dictionary(let dictionary):
            emitMapping(emitter, event: event, mapping: dictionary)
        case .Array(let array):
            emitSequence(emitter, event: event, sequence: array)
        case .String(let string):
            emitScalarValue(emitter, event: event, value: string)
        case .Int(let int):
            emitScalarValue(emitter, event: event, value: "\(int)")
        case .Double(let double):
            emitScalarValue(emitter, event: event, value: "\(double)")
        case .Bool(let bool):
            emitScalarValue(emitter, event: event, value: (bool == true ? "true" : "false"))
        case .None:
            emitScalarValue(emitter, event: event, value: "null")
        }
    }
    
    private func emitScalarValue(emitter: UnsafeMutablePointer<yaml_emitter_t>, event: UnsafeMutablePointer<yaml_event_t>, value: String) {
        yaml_scalar_event_initialize(event, nil, nil, yaml_char_from_string(value), Int32(value.characters.count), 1, 1, YAML_PLAIN_SCALAR_STYLE)
        yaml_emitter_emit(emitter, event)
    }
    
    private func emitMapping(emitter: UnsafeMutablePointer<yaml_emitter_t>, event: UnsafeMutablePointer<yaml_event_t>, mapping: [YAMLValue: YAMLValue]) {
        yaml_mapping_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_MAPPING_STYLE)
        yaml_emitter_emit(emitter, event)
        for (key, value) in mapping {
            emitYAMLValue(emitter, event: event, value: key)
            emitYAMLValue(emitter, event: event, value: value)
        }
        yaml_mapping_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
    
    private func emitSequence(emitter: UnsafeMutablePointer<yaml_emitter_t>, event: UnsafeMutablePointer<yaml_event_t>, sequence: [YAMLValue]) {
        yaml_sequence_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_SEQUENCE_STYLE)
        yaml_emitter_emit(emitter, event)
        for value in sequence {
            emitYAMLValue(emitter, event: event, value: value)
        }
        yaml_sequence_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
}
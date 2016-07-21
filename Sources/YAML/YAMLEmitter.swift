//
//  YAMLEmitter.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation
import LibYAML

typealias EmitterType = UnsafeMutablePointer<yaml_emitter_t>
typealias EventType = UnsafeMutablePointer<yaml_event_t>

class YAMLEmitter {
    private static let bufferSize = 65536
    
    func emit(_ yaml: YAMLValue) throws -> String {
        let emitter = UnsafeMutablePointer<yaml_emitter_t>(allocatingCapacity:sizeof(yaml_emitter_t.self))
        defer { free(emitter) }
        guard yaml_emitter_initialize(emitter) == 1 else {
            print("unable to initialize emitter")
            throw YAMLError.unknownError
        }        
        defer { yaml_emitter_delete(emitter) }

        yaml_emitter_set_unicode(emitter, 1)
        yaml_emitter_set_encoding(emitter, YAML_UTF8_ENCODING)
        yaml_emitter_set_indent(emitter, 2)
        
        var outputStream = NSOutputStream.toMemory()
        outputStream.open()
        defer { outputStream.close() }
        
        func writeHandler(data: UnsafeMutablePointer<Void>?, buffer: UnsafeMutablePointer<UInt8>?, size: Int) -> Int32 {
            let outputPointer = UnsafeMutablePointer<NSOutputStream>(data)
            let stream: NSOutputStream? = outputPointer?.pointee
            if let stream = stream {
                let success = stream.write(buffer!, maxLength: size) > 0
                return success ? 1 : 0
            }
            return 0
        }
        
        yaml_emitter_set_output(emitter, writeHandler, &outputStream)
        
        let event = UnsafeMutablePointer<yaml_event_t>(allocatingCapacity: sizeof(yaml_event_t.self))
        defer {
            yaml_event_delete(event)
            free(event)
        }

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
        
        let outputData = outputStream.property(forKey: Stream.PropertyKey.dataWrittenToMemoryStreamKey) as! Data
        let outputString = NSString(data: outputData, encoding: String.Encoding.utf8.rawValue)!
        return outputString as String
    }
    
    private func emitYAMLValue(_ emitter: EmitterType, event: EventType, value: YAMLValue) {
        switch value {
        case .Array(let array):
            emitSequence(emitter, event: event, sequence: array)
        case .Dictionary(let dictionary):
            emitMapping(emitter, event: event, mapping: dictionary)
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
    
    private func emitScalarValue(_ emitter: EmitterType, event: EventType, value: String) {
        yaml_scalar_event_initialize(event, nil, nil, yaml_char_from_string(value), Int32(value.utf8.count), 1, 1, YAML_PLAIN_SCALAR_STYLE)
        yaml_emitter_emit(emitter, event)
    }
    
    private func emitMapping(_ emitter: EmitterType, event: EventType, mapping: [YAMLValue: YAMLValue]) {
        yaml_mapping_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_MAPPING_STYLE)
        yaml_emitter_emit(emitter, event)
        for (key, value) in mapping {
            emitYAMLValue(emitter, event: event, value: key)
            emitYAMLValue(emitter, event: event, value: value)
        }
        yaml_mapping_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
    
    private func emitSequence(_ emitter: EmitterType, event: EventType, sequence: [YAMLValue]) {
        yaml_sequence_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_SEQUENCE_STYLE)
        yaml_emitter_emit(emitter, event)
        for value in sequence as [YAMLValue] {
//            emitYAMLValue(emitter, event: event, value: value)
            
            // FIXME: this is copy and pasted from emitYAMLValue because the compiler gets stuck otherwise.
            // Try fixing when new version of compiler is released
            switch value {
            case .Array(let array):
                emitSequence(emitter, event: event, sequence: array)
            case .Dictionary(let dictionary):
                emitMapping(emitter, event: event, mapping: dictionary)
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

        yaml_sequence_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
}

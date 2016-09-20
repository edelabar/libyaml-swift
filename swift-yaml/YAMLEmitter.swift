//
//  YAMLEmitter.swift
//  swift-yaml
//
//  Created by Niels de Hoog on 23/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

typealias EmitterType = UnsafeMutablePointer<yaml_emitter_t>
typealias EventType = UnsafeMutablePointer<yaml_event_t>

class YAMLEmitter {
    fileprivate static let bufferSize = 65536
    
    func emit(_ yaml: YAMLValue) throws -> String {
        let emitter = UnsafeMutablePointer<yaml_emitter_t>.allocate(capacity: MemoryLayout<yaml_emitter_t>.size)
        defer { free(emitter) }
        guard yaml_emitter_initialize(emitter) == 1 else {
            print("unable to initialize emitter")
            throw YAMLError.unknownError
        }        
        defer { yaml_emitter_delete(emitter) }

        yaml_emitter_set_unicode(emitter, 1)
        yaml_emitter_set_encoding(emitter, YAML_UTF8_ENCODING)
        yaml_emitter_set_indent(emitter, 2)
        
        var outputStream = OutputStream.toMemory()
        outputStream.open()
        defer { outputStream.close() }
        func writeHandler(_ data: UnsafeMutableRawPointer?, buffer: UnsafeMutablePointer<UInt8>?, size: Int) -> Int32 {
            guard let data = data, let buffer = buffer else { return 0 }
            let outputStream = data.load(as: OutputStream.self)
            let success = outputStream.write(buffer, maxLength: size) > 0
            return success ? 1 : 0
        }
        
        yaml_emitter_set_output(emitter, writeHandler, &outputStream)
        
        let event = UnsafeMutablePointer<yaml_event_t>.allocate(capacity: MemoryLayout<yaml_event_t>.size)
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
    
    fileprivate func emitYAMLValue(_ emitter: EmitterType, event: EventType, value: YAMLValue) {
        switch value {
        case .array(let array):
            emitSequence(emitter, event: event, sequence: array)
        case .dictionary(let dictionary):
            emitMapping(emitter, event: event, mapping: dictionary)
        case .string(let string):
            emitScalarValue(emitter, event: event, value: string)
        case .int(let int):
            emitScalarValue(emitter, event: event, value: "\(int)")
        case .double(let double):
            emitScalarValue(emitter, event: event, value: "\(double)")
        case .bool(let bool):
            emitScalarValue(emitter, event: event, value: (bool == true ? "true" : "false"))
        case .none:
            emitScalarValue(emitter, event: event, value: "null")
        }
    
    }
    
    fileprivate func emitScalarValue(_ emitter: EmitterType, event: EventType, value: String) {
        yaml_scalar_event_initialize(event, nil, nil, yaml_char_from_string(value), Int32(value.utf8.count), 1, 1, YAML_PLAIN_SCALAR_STYLE)
        yaml_emitter_emit(emitter, event)
    }
    
    fileprivate func emitMapping(_ emitter: EmitterType, event: EventType, mapping: [YAMLValue: YAMLValue]) {
        yaml_mapping_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_MAPPING_STYLE)
        yaml_emitter_emit(emitter, event)
        for (key, value) in mapping {
            emitYAMLValue(emitter, event: event, value: key)
            emitYAMLValue(emitter, event: event, value: value)
        }
        yaml_mapping_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
    
    fileprivate func emitSequence(_ emitter: EmitterType, event: EventType, sequence: [YAMLValue]) {
        yaml_sequence_start_event_initialize(event, nil, nil, 1, YAML_BLOCK_SEQUENCE_STYLE)
        yaml_emitter_emit(emitter, event)
        for value in sequence as [YAMLValue] {
            emitYAMLValue(emitter, event: event, value: value)
        }

        yaml_sequence_end_event_initialize(event)
        yaml_emitter_emit(emitter, event)
    }
}

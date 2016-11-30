//
//  MediaUtils.swift
//  Allison
//
//  Created by User One on 5/20/16.
//  Copyright © 2016 Chad Lou. All rights reserved.
//

import Foundation


class MediaUtil {
    
    private static func dataToUTF8String(data: NSData, offset: Int, length: Int) -> String? {
        let range = NSMakeRange(offset, length)
        let subdata = data.subdata(with: range)
        return String(data: subdata, encoding: String.Encoding.utf8)
    }
    
    private static func dataToUInt32(data: NSData, offset: Int) -> Int {
        var num: UInt32 = 0
        let length = 4
        let range = NSMakeRange(offset, length)
        data.getBytes(&num, range: range)
        return Int(num)
    }
    
    static func repairWAVHeader(data: NSMutableData) {
        
        // resources for WAV header format:
        // [1] http://unusedino.de/ec64/technical/formats/wav.html
        // [2] http://soundfile.sapp.org/doc/WaveFormat/
        
        // update RIFF chunk size
        let fileLength = data.length
        var riffChunkSize = UInt32(fileLength - 8)
        let riffChunkSizeRange = NSMakeRange(4, 4)
        data.replaceBytes(in: riffChunkSizeRange, withBytes: &riffChunkSize)
        
        // find data subchunk
        var subchunkID: String?
        var subchunkSize = 0
        var fieldOffset = 12
        let fieldSize = 4
        while true {
            // prevent running off the end of the byte buffer
            if fieldOffset + 2*fieldSize >= data.length {
                return
            }
            
            // read subchunk ID
            subchunkID = dataToUTF8String(data: data, offset: fieldOffset, length: fieldSize)
            fieldOffset += fieldSize
            if subchunkID == "data" {
                break
            }
            
            // read subchunk size
            subchunkSize = dataToUInt32(data: data, offset: fieldOffset)
            fieldOffset += fieldSize + subchunkSize
        }
        
        // compute data subchunk size (excludes id and size fields)
        var dataSubchunkSize = UInt32(data.length - fieldOffset - fieldSize)
        
        // update data subchunk size
        let dataSubchunkSizeRange = NSMakeRange(fieldOffset, fieldSize)
        data.replaceBytes(in: dataSubchunkSizeRange, withBytes: &dataSubchunkSize)
    }
}

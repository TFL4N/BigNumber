//
//  StringStream.swift
//  NumberGenerator
//
//  Created by Spizzace on 11/19/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public class StringStreamWriter {
    public let encoding: String.Encoding
    public var fileHandle: FileHandle!
    public let delimData: Data
    
    public init?(url: URL, delimiter: String = "\n", encoding: String.Encoding = .utf8) {
        guard let fileHandle = try? FileHandle(forUpdating: url),
            let delimData = delimiter.data(using: encoding) else {
                return nil
        }
        
        self.encoding = encoding
        self.fileHandle = fileHandle
        self.delimData = delimData
    }
    
    @discardableResult
    public func append(_ str: String) -> Bool {
        self.fileHandle.seekToEndOfFile()
        if let data = str.data(using: self.encoding) {
            self.fileHandle.write(data)
            self.fileHandle.write(self.delimData)
            return true
        } else {
            return false
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    public func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

public class StringStreamReader  {
    public let encoding : String.Encoding
    public let chunkSize : Int
    public var fileHandle : FileHandle!
    public let delimData : Data
    public var buffer : Data
    public var atEof : Bool
    
    public init?(url: URL, delimiter: String = "\n", encoding: String.Encoding = .utf8,
          chunkSize: Int = 4096) {
        
        guard let fileHandle = try? FileHandle(forReadingFrom: url),
            let delimData = delimiter.data(using: encoding) else {
                return nil
        }
        self.encoding = encoding
        self.chunkSize = chunkSize
        self.fileHandle = fileHandle
        self.delimData = delimData
        self.buffer = Data(capacity: chunkSize)
        self.atEof = false
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    public func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        // Read data chunks from file until a line delimiter is found:
        while !atEof {
            if let range = buffer.range(of: delimData) {
                // Convert complete line (excluding the delimiter) to a string:
                let line = String(data: buffer.subdata(in: 0..<range.lowerBound), encoding: encoding)
                // Remove line (and the delimiter) from the buffer:
                buffer.removeSubrange(0..<range.upperBound)
                return line
            }
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.count > 0 {
                buffer.append(tmpData)
            } else {
                // EOF or read error.
                atEof = true
                if buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer as Data, encoding: encoding)
                    buffer.count = 0
                    return line
                }
            }
        }
        return nil
    }
    
    /// Start reading from the beginning of file.
    public func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.count = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    public func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}

extension StringStreamReader : Sequence {
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

//
//  SequenceGenerator.swift
//  NumberGenerator
//
//  Created by Spizzace on 11/19/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

//
//
// MARK: Sequences
//
//
public class PrimeNumberSequence<T: BinaryInteger & SequenceGeneratorEncodable>: SequenceGenerator<T> {
    public init() {
        super.init(name: "Prime Numbers",
                   file_name: "prime_numbers")
    }
}

//
//
// MARK: Sequence Encodable
//
//
extension BigInt: SequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return self.toString(base: 10)!
    }
}

extension UInt: SequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return String(self)
    }
}

extension Int: SequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return String(self)
    }
}

//
//
// MARK: Sequence Generator
//
//
public protocol SequenceGeneratorEncodable {
    init?(encodedString: String)
    func encode() -> String
}

public class SequenceGenerator<DataType: SequenceGeneratorEncodable> {
    // TODO: Make Awesomer
    /*
     Only open one FileHande in update mode, then keep track of read index
     This way a sequence can be read and written at the same time
     */
    
    public let name: String
    public let file_name: String
    public let file_extension: String
    private(set) public var data: [DataType] = []
    public var file_url: URL {
        let bundle = Bundle(identifier: "spaice.BigNumber")!
        
        return bundle.url(forResource: self.file_name, withExtension: self.file_extension)!
    }
    
    private var stream_writer_store: StreamWriter?
    public var stream_writer: StreamWriter? {
        if self.stream_writer_store == nil {
            self.closeReader()
            
            self.stream_writer_store = StreamWriter(url: self.file_url)
        }
        
        return self.stream_writer_store
    }
    
    private var stream_reader_store: StreamReader?
    public var stream_reader: StreamReader? {
        if self.stream_reader_store == nil {
            self.closeWriter()
            
            self.stream_reader_store = StreamReader(url: self.file_url)
        }
        
        return self.stream_reader_store
    }
    
    public init(name: String, file_name: String, extension: String = "txt") {
        self.name = name
        self.file_name = file_name
        self.file_extension = `extension`
    }
    
    deinit {
        self.closeWriter()
        self.closeReader()
    }
    
    public func encodeData(_ data: DataType) -> String {
        return data.encode()
    }
    
    public func decodeData(_ str: String) -> DataType? {
        return DataType.init(encodedString: str)
    }
    
    @discardableResult
    public func moveReader(toIndex: Int) -> Int? {
        guard let reader = self.stream_reader else {
            return nil
        }
        
        reader.rewind()
        
        var count = 0
        loop: while count < toIndex {
            if let _ = reader.nextLine() {
                count += 1
            } else {
                break loop
            }
        }
        
        return count
    }
    
    public func loadItems(min: Int, max: Int?) {
        guard (max == nil || max! - min > 0),
            let reader = self.stream_reader else {
                return
        }
        
        /// remove all
        self.data.removeAll(keepingCapacity: true)
        
        /// reserve memory
        var total = 0
        if max == nil {
            if let count = self.getDataCount() {
                total = count - min
            }
        } else {
            total = max! - min
        }
        if total > 0 {
            self.data.reserveCapacity(total)
        }
        
        /// reader data
        var count = 0
        loop: while count < total {
            count += 1
            
            if let str = reader.nextLine() {
                self.data.append(self.decodeData(str)!)
            } else {
                break loop
            }
        }
    }
    
    public func loadNextItem() {
        /*
         keep track of read index
         move reader to index
         read data
         */
    }
    
    public func getLastDataItemFromFile() -> (data: DataType, index: Int)? {
        guard let reader = self.stream_reader else {
            return nil
        }
        
        reader.rewind()
        var count = -1
        var encoded_str = ""
        while let line = reader.nextLine() {
            count += 1
            encoded_str = line
        }
        
        if count < 0 {
            return nil
        } else {
            return (self.decodeData(encoded_str)!, count)
        }
    }
    
    public func getDataCount() -> Int? {
        guard let reader = self.stream_reader else {
            return nil
        }
        
        reader.rewind()
        var count = 0
        while let _ = reader.nextLine() {
            count += 1
        }
        
        return count
    }
    
    public func closeWriter() {
        if let writer = self.stream_writer_store {
            writer.close()
            self.stream_writer_store = nil
        }
    }
    
    public func closeReader() {
        if let reader = self.stream_reader_store {
            reader.close()
            self.stream_reader_store = nil
        }
    }
}

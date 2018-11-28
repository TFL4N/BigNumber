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
public class PrimeNumberSequence<T>: StringSequenceGenerator<T> where T : BinaryInteger & StringSequenceGeneratorEncodable {
    public init() {
        super.init(name: "Prime Numbers",
                   file_name: "prime_numbers.txt")
    }
}

public class PrimeFactorsSequence<Number,Factor>: StringSequenceGenerator<StringSequencePair<Number,[UInt:Factor]>> where Number : BinaryInteger & StringSequenceGeneratorEncodable, Factor : BinaryInteger & StringSequenceGeneratorEncodable {
    public init() {
        super.init(name: "Prime Factorizations", file_name: "prime_factorizations.txt")
    }
}

public class CoprimeSequence<Number,Coprime>: StringSequenceGenerator<StringSequencePair<Number,[Coprime]>> where Number : BinaryInteger & StringSequenceGeneratorEncodable, Coprime : BinaryInteger & StringSequenceGeneratorEncodable {
    public init() {
        super.init(name: "Coprime Numbers", file_name: "coprime_numbers.txt")
    }
}

//
//
// MARK: Sequence Encodable
//
//
public class StringSequencePair<Key,Value>: StringSequenceGeneratorEncodable, CustomStringConvertible where Key : StringSequenceGeneratorEncodable, Value : StringSequenceGeneratorEncodable {
    public let key: Key
    public let value: Value
    
    private let separator: String = " "
    
    public var description: String {
        return "{\(self.key), \(self.value)}"
    }
    
    public init(_ key: Key, _ value: Value) {
        self.key = key
        self.value = value
    }
    
    public required init?(encodedString: String) {
        let comps = encodedString.components(separatedBy: self.separator)
        
        guard comps.count == 2,
            let key = Key.init(encodedString: comps[0]),
            let value = Value.init(encodedString: comps[1]) else {
                return nil
        }
        
        self.key = key
        self.value = value
    }
    
    public func encode() -> String {
        return self.key.encode() + self.separator + self.value.encode()
    }
}

extension BigInt: StringSequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return self.toString(base: 10)!
    }
}

extension UInt: StringSequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return String(self)
    }
}

extension Int: StringSequenceGeneratorEncodable {
    public init?(encodedString: String) {
        self.init(encodedString)
    }
    
    public func encode() -> String {
        return String(self)
    }
}

extension Array: StringSequenceGeneratorEncodable where Array.Element : StringSequenceGeneratorEncodable {
    public init?(encodedString: String) {
        let comps = encodedString.components(separatedBy: ",")
        
        guard comps.count > 0 else {
            self.init()
            return
        }
        
        self.init()
        self.reserveCapacity(comps.count)
        for str in comps {
            guard let value = Element.init(encodedString: str) else {
                    return nil
            }
            
            self.append(value)
        }
    }
    
    public func encode() -> String {
        var output = ""
        
        for v in self {
            output += "\(v.encode()),"
        }
        
        // remove trailing comma
        if !output.isEmpty {
            output.remove(at: output.index(before: output.endIndex))
        }
        
        return output
    }
}

extension Dictionary: StringSequenceGeneratorEncodable where Dictionary.Key : StringSequenceGeneratorEncodable, Dictionary.Value : StringSequenceGeneratorEncodable {
    
    public init?(encodedString: String) {
        let comps = encodedString.components(separatedBy: ",")
        
        guard comps.count > 0 else {
            self.init()
            return
        }
        
        self.init()
        self.reserveCapacity(comps.count)
        for str in comps {
            let elements = str.components(separatedBy: ":")
            guard elements.count == 2,
                let key = Key.init(encodedString: elements[0]),
                let value = Value.init(encodedString: elements[1]) else {
                    return nil
            }
            
            self[key] = value
        }
    }
    
    public func encode() -> String {
        var output = ""
        
        for (k,v) in self {
            output += "\(k.encode()):\(v.encode()),"
        }
        
        // remove trailing comma
        if !output.isEmpty {
            output.remove(at: output.index(before: output.endIndex))
        }
        
        return output
    }
}

//
//
// MARK: Sequence Generator
//
//
public protocol StringSequenceGeneratorEncodable {
    init?(encodedString: String)
    func encode() -> String
}

public class StringSequenceGenerator<DataType: StringSequenceGeneratorEncodable> {
    // TODO: Make Awesomer
    /*
     Only open one FileHande in update mode, then keep track of read index
     This way a sequence can be read and written at the same time
     
     
     Use a binary data format
     assume all numbers will fit into a Int/UInt
     for a simple list of numbers, such as, all primes, each 8-byte block is a number
     for a list of numbers with an attached array or dictionary, the first block is the number, the second block is a count of the number of elements in the collection.  Then read/write that many blocks
     */
    
    public let sequences_directory: String = "/Users/SpaiceMaine/lib/sequences/"
    
    public let name: String
    public let file_name: String
    private(set) public var data: [DataType] = []
    public var file_url: URL {
        return URL(fileURLWithPath: self.sequences_directory + self.file_name)
    }
    
    private var stream_writer_store: StringStreamWriter?
    public var stream_writer: StringStreamWriter? {
        if self.stream_writer_store == nil {
            self.closeReader()
            
            self.stream_writer_store = StringStreamWriter(url: self.file_url)
        }
        
        return self.stream_writer_store
    }
    
    private var stream_reader_store: StringStreamReader?
    public var stream_reader: StringStreamReader? {
        if self.stream_reader_store == nil {
            self.closeWriter()
            
            self.stream_reader_store = StringStreamReader(url: self.file_url)
        }
        
        return self.stream_reader_store
    }
    
    public init(name: String, file_name: String) {
        self.name = name
        self.file_name = file_name
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
    
    public func loadItems(block: (String)->Bool) {
    
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

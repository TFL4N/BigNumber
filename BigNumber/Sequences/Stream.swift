//
//  Stream.swift
//  BigNumber
//
//  Created by Spizzace on 11/27/18.
//  Copyright © 2018 SpaiceMaine. All rights reserved.
//

import Foundation

public class Stream {
    // constants
    public let chunk_size: Int
    
    // ivars
    public private(set) var file_handle: FileHandle!
    public private(set) var buffer: Data
    
    
    public init?(url: URL, chunk_size: Int = 4096) {
        guard let file_handle = try? FileHandle(forUpdating: url) else {
            return nil
        }
        
        self.chunk_size = chunk_size
        
        self.file_handle = file_handle
        self.buffer = Data(capacity: self.chunk_size)
    }
    
    deinit {
        self.close()
    }
    
    public func close() {
        file_handle?.closeFile()
        file_handle = nil
    }
}

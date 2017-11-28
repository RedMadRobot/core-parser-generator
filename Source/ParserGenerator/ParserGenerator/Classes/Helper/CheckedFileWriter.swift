//
// CheckedFileWriter
// Generator
//
// Created by Eugene Egorov on 16 March 2016.
// Copyright (c) 2016 Eugene Egorov. All rights reserved.
//

import Foundation


/**
 File writer with content changes checking.

 Write only if current file content is changed.
 
*/
class CheckedFileWriter {
    var atomic: Bool

    init(atomic: Bool)
    {
        self.atomic = atomic
    }

    func write(string: String, toFile filePath: String) throws
    {
        let currentString = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if let currentString = currentString , currentString == string {
            return
        }

        try string.write(toFile: filePath, atomically: atomic, encoding: String.Encoding.utf8)
    }

    func write(data: NSData, toFile filePath: String) throws
    {
        let currentData = NSData(contentsOfFile: filePath)
        if let currentData = currentData , currentData == data {
            return
        }

        try data.write(toFile: filePath, options: atomic ? [ .atomicWrite ] : [])
    }
}

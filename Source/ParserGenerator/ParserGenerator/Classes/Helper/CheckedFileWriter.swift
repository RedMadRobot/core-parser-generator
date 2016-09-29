//
// CheckedFileWriter
// Generator
//
// Created by Eugene Egorov on 16 March 2016.
// Copyright (c) 2016 Eugene Egorov. All rights reserved.
//

import Foundation


/**
 Писатель файлов с проверкой на идентичность контента.

 Запись производится в случае если текущий контент файла не совпадает с новым.
*/
class CheckedFileWriter {
    var atomic: Bool

    init(atomic: Bool)
    {
        self.atomic = atomic
    }

    func write(string string: String, toFile filePath: String) throws
    {
        let currentString = try? String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        if let currentString = currentString where currentString == string {
            return
        }

        try string.writeToFile(filePath, atomically: atomic, encoding: NSUTF8StringEncoding)
    }

    func write(data data: NSData, toFile filePath: String) throws
    {
        let currentData = NSData(contentsOfFile: filePath)
        if let currentData = currentData where currentData == data {
            return
        }

        try data.writeToFile(filePath, options: atomic ? [ .AtomicWrite ] : [])
    }
}

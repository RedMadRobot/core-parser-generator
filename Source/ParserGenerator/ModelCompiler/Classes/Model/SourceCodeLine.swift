//
//  SourceCodeLine.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


open class SourceCodeLine: CustomDebugStringConvertible, Equatable {
    
    open let absoluteFilePath:  String
    open let lineNumber:        Int
    open let line:              String
    
    open var debugDescription: String
    {
        get {
            return "Source Code Line: filename: \(self.absoluteFilePath); line number: \(self.lineNumber); line: \(self.line)"
        }
    }
    
    public init(absoluteFilePath: String, lineNumber: Int, line: String)
    {
        self.absoluteFilePath   = absoluteFilePath
        self.lineNumber         = lineNumber
        self.line               = line
    }
    
}

public func ==(left: SourceCodeLine, right: SourceCodeLine) -> Bool
{
    return
        left.lineNumber         == right.lineNumber
     && left.line               == right.line
     && left.absoluteFilePath   == right.absoluteFilePath
}

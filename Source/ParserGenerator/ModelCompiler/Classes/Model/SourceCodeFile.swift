//
//  SourceCodeFile.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


open class SourceCodeFile: CustomDebugStringConvertible {
    
    open let absoluteFilePath:  String
    open let lines:             [SourceCodeLine]
    
    open var debugDescription: String
    {
        get {
            return "SourceCodeFile: filename: \(self.absoluteFilePath); lines: \(self.lines)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }
    
    public init(absoluteFilePath: String, lines: [SourceCodeLine])
    {
        self.absoluteFilePath   = absoluteFilePath
        self.lines              = lines
    }
    
    convenience init(absoluteFilePath: String, contents: String)
    {
        var sourceCodeLines: [SourceCodeLine] = []
    
        for (index, line) in contents.lines().enumerated() {
            sourceCodeLines.append(
                SourceCodeLine(
                    absoluteFilePath: absoluteFilePath,
                    lineNumber: index + 1,
                    line: line
                )
            )
        }
    
        self.init(absoluteFilePath: absoluteFilePath, lines: sourceCodeLines)
    }
    
}

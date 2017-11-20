//
//  CompilerMessage.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


open class CompilerMessage: Error, CustomDebugStringConvertible {

    public enum MessageType: String {
        case Error = "error"
        case Warning = "warning"
        case Note = "note"
    }

    open let absoluteFilePath: String
    open let lineNumber: Int
    open let message: String
    open let type: MessageType

    fileprivate let columnNumber: Int
    
    open var debugDescription: String
    {
        get {
            return "\(self.absoluteFilePath):\(self.lineNumber):\(self.columnNumber): \(self.type.rawValue): \(self.message)\n"
        }
    }
    
    public init(
        absoluteFilePath: String,
        lineNumber: Int,
        message: String,
        type: MessageType = .Error
    )
    {
        self.absoluteFilePath   = absoluteFilePath
        self.lineNumber         = lineNumber
        self.message            = message
        self.type               = type

        self.columnNumber = 1
    }
    
}

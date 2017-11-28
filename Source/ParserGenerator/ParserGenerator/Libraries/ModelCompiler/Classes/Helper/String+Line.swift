//
//  String+Line.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

// MARK: - String helpers
public extension String {
    
    /**
     Add empty line
     
     - returns: New string with empty line
     */
    public func addBlankLine() -> String
    {
        return addLine("")
    }
    
    /**
     Add line **line** (with new line symbol).
     
     - parameter line: line, that need to add.
     
     - returns: New string with added **line** (with new line symbol).
     */
    public func addLine(_ line: String) -> String
    {
        let straightLine: String = line.replacingOccurrences(of: "\n", with: "")
        
        return self + straightLine + "\n"
    }
    
    /**
     Add text **line** (without new line symbol).
     
     - parameter line: text to add
     
     - returns: New text **line** (without new line symbol).
     */
    public func append(_ line: String) -> String
    {
        return self + line
    }
    
    public func lines() -> [String]
    {
        return self.components(separatedBy: "\n")
    }
    
}

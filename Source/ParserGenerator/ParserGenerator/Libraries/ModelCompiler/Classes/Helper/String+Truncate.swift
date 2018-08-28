//
//  String+Truncate.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

// MARK: - Обрезка строк
public extension String {
    
    /**
     Remove symbols to **word**.
     **word** remains in the line by default.
     
     - parameter word: remove symbols before this word ;
     - parameter includeWord: remove or not the **word**?
     
     - returns: New string, truncated before **word**. If there is no word return input **word**
     */
    public func truncateToWord(_ word: String, deleteWord: Bool = false) -> String
    {
        guard let wordRange: Range<String.Index> = range(of: word)
            else {
                return self
        }
        
        return deleteWord ? String(self[wordRange.upperBound...]) : String(self[wordRange.lowerBound...])
    }
    
    /**
     Remove symbols after **word**.
     All symbols will be removed after and with **word** by default.
     
     - parameter word: remove symbols after this word;
     - parameter includeWord: remove or not the **word**?
     
     - returns: New string, truncated after **word**. If there is no word return input **word**
     */
    public func truncateFromWord(_ word: String, deleteWord: Bool = true) -> String
    {
        guard let wordRange: Range<String.Index> = range(of: word)
            else {
                return self
        }
        
        return deleteWord ? String(self[..<wordRange.lowerBound]) : String(self[..<wordRange.upperBound])
    }
    
    /**
     Get last word from string.
     Last word -- any after last space or new line symbol.
     
     - returns: last word from string.
     */
    public func lastWord() -> String
    {
        if contains(" ") {
            return truncateToWord(" ", deleteWord: true).lastWord()
        }
        
        if contains("\n") {
            return truncateToWord("\n", deleteWord: true).lastWord()
        }
        
        return self
    }
    
    /**
     First word from string.
     First word -- any before first space or new line symbol.
     
     - returns: first word from string.
     */
    public func firstWord() -> String
    {
        if contains(" ") {
            return truncateFromWord(" ").firstWord()
        }
        
        if contains("\n") {
            return truncateFromWord("\n").firstWord()
        }
        
        return self
    }
    
    public func enumerateWords(_ enumerator: @escaping (_ word: String) -> ())
    {
        self.enumerateLines { (line: String, stop: inout Bool) in
            var mutableLine: String = line.trimmingCharacters(in: CharacterSet.whitespaces)
            
            while mutableLine.contains("  ") {
                mutableLine = mutableLine.replacingOccurrences(of: "  ", with: " ")
            }
            
            while !mutableLine.isEmpty {
                enumerator(mutableLine.firstWord())
                if mutableLine.contains(" ") {
                    mutableLine = mutableLine.truncateToWord(" ", deleteWord: true)
                } else {
                    break
                }
            }
            
            enumerator("\n")
        }
    }
    
    /**
     Truncate all spaces and new line symbols at the beginning of line.
     
     - returns: new string without spaces and symbols at the beginning.
     */
    public func truncateLeadingWhitespace() -> String
    {
        if hasPrefix(" ") {
            return String(self[index(startIndex, offsetBy: 1)...]).truncateLeadingWhitespace()
        }
        
        if hasPrefix("\n") {
            return String(self[index(startIndex, offsetBy: 1)...]).truncateLeadingWhitespace()
        }
        
        return self
    }
    
    public func truncateToWordFromBehind(_ word: String, deleteWord: Bool = true) -> String
    {
        let drow: String = String(word.reversed())
        let fles: String = String(self.reversed())
        
        let cut: String = fles.truncateToWord(drow, deleteWord: deleteWord)
        return String(cut.reversed())
    }
    
    public func truncateUntilWord(_ word: String) -> String
    {
        let drow: String = String(word.reversed())
        let fles: String = String(self.reversed())
        
        let cut: String = fles.truncateFromWord(drow, deleteWord: false)
        return String(cut.reversed())
    }
    
}

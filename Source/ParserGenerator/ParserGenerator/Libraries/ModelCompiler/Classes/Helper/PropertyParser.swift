//
//  PropertyParser.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class PropertyParser: KlassContentParser<Property> {
    
    open override func detectContent(line: SourceCodeLine) -> Bool
    {
        let cleanLine: String = line.line.truncateFromWord("//")
        return cleanLine.contains(" var ")
            || cleanLine.contains(" let ")
    }
    
    open override func appendContent(line: SourceCodeLine)
    {
        // ничего не делать
    }
    
    open override func endedParsingContent(line: SourceCodeLine, documentation: [SourceCodeLine]) throws -> Property?
    {
        let cleanLine: String = line.line.truncateFromWord("//")
        
        let lastBlockComment: String = documentation.reduce("", { (comment: String, line: SourceCodeLine) -> String in
            return comment + line.line + "\n"
        })
        
        let isConstant: Bool = cleanLine.contains(" let ")
        let name: String
        
        if isConstant {
            name = cleanLine.truncateToWord("let ", deleteWord: true).firstWord().replacingOccurrences(of: ":", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            name = cleanLine.truncateToWord("var ", deleteWord: true).firstWord().replacingOccurrences(of: ":", with: "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        let type: Typê = try TypeParser().parse(rawPropertyLine: line)
        let mandatory: Bool = !cleanLine.contains("?")
        let annotations: [Annotation] = AnnotationParser().parse(comment: lastBlockComment)
        
        return Property(
                name: name,
                type: type,
                annotations: annotations,
                constant: isConstant,
                mandatory: mandatory,
                declaration: line
        )
    }
    
}

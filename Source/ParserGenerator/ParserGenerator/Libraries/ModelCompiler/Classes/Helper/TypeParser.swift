//
//  TypeParser.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 04.04.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class TypeParser {
    
    open func parse(rawPropertyLine line: SourceCodeLine) throws -> Typê
    {
        if let detectedType: Typê = self.tryDetectInferedType(fromRawPropertyDeclaration: line) {
            return detectedType
        }
        
        let cleanLine: String
        if !line.line.contains("[") {
            cleanLine = line.line.truncateToWord(": ", deleteWord: true).truncateFromWord("//")
        } else {
            if let semicolonLocation: String.Index = line.line.range(of: ":")?.lowerBound {
                if let bracketLocation: String.Index = line.line.range(of: "[")?.lowerBound {
                    if semicolonLocation < bracketLocation {
                        cleanLine = line.line.truncateToWord(": ", deleteWord: true).truncateFromWord("//")
                    } else {
                        cleanLine = line.line.truncateFromWord("//")
                    }
                } else {
                    cleanLine = line.line.truncateToWord(": ", deleteWord: true).truncateFromWord("//")
                }
            } else {
                cleanLine = line.line.truncateFromWord("//")
            }
        }
        
        return try self.parseType(typeName: cleanLine, line: line)
    }
    
}
    
internal extension TypeParser {
    
    func tryDetectInferedType(fromRawPropertyDeclaration declaration: SourceCodeLine) -> Typê?
    {
        guard declaration.line.contains("=")
        else { return nil }
        
        // infer type from default value:
        let defaultValue: String =
            declaration.line
                .truncateToWord("=", deleteWord: true)
                .truncateFromWord("//")
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // check default value contains text in quotes:
        // let abc = "abcd"
        if let _ = defaultValue.range(of: "\"(.*)\"", options: .regularExpression) {
            return .StringType
        }
        
        // check default value is double:
        // let abc = 123.45
        if let _ = defaultValue.range(of: "(\\d+)\\.(\\d+)", options: .regularExpression) {
            return .DoubleType
        }
        
        // check default value is int:
        // let abc = 123
        if let _ = defaultValue.range(of: "(\\d+)", options: .regularExpression) {
            return .IntType
        }
        
        // check if default value is bool
        // let abc = true
        if defaultValue.contains("true") || defaultValue.contains("false") {
            return .BoolType
        }
        
        // check if default value contains object init statement:
        // let abc = Object(some: 123)
        if let _ = defaultValue.range(of: "(\\w+)\\((.*)\\)", options: .regularExpression) {
            let ObjectTypeName: String = defaultValue.truncateFromWord("(")
            
            if ObjectTypeName.contains("Bool") {
                return .BoolType
            }
            
            if ObjectTypeName.contains("Int") {
                return .IntType
            }
            
            if ObjectTypeName.contains("Float") {
                return .FloatType
            }
            
            if ObjectTypeName.contains("Double") {
                return .DoubleType
            }
            
            if ObjectTypeName.contains("NSDate") {
                return .DateType
            }
            
            if ObjectTypeName.contains("String") {
                return .StringType
            }
            
            return .ObjectType(name: ObjectTypeName)
        }
        
        return nil
    }
    
    func parseType(typeName: String, line: SourceCodeLine) throws -> Typê
    {
        if typeName.contains("<") && typeName.contains(">") {
            let name: String = typeName.truncateFromWord("<").truncateLeadingWhitespace()
            let itemName: String = typeName.truncateToWord("<", deleteWord: true).truncateFromWord(">")
            let itemType: Typê = try self.parseType(typeName: itemName, line: line)
            return Typê.GenericType(name: name, item: itemType)
        }
        
        if typeName.contains("[") && typeName.contains("]") {
            let collecitonItemTypeName: String = typeName.truncateToWord("[", deleteWord: true).truncateFromWord("]").trimmingCharacters(in: CharacterSet.whitespaces)
            return try self.parseCollectionItemType(collecitonItemTypeName, line: line)
        }
        
        if typeName.contains("Bool") {
            return Typê.BoolType
        }
        
        if typeName.contains("Int") {
            return Typê.IntType
        }
        
        if typeName.contains("Float") {
            return Typê.FloatType
        }
        
        if typeName.contains("Double") {
            return Typê.DoubleType
        }
        
        if typeName.contains("NSDate") {
            return Typê.DateType
        }
        
        if typeName.contains("String") {
            return Typê.StringType
        }
        
        var ObjectTypeName: String = typeName.firstWord()
        if ObjectTypeName.characters.last == "?" {
            ObjectTypeName = String(ObjectTypeName.characters.dropLast())
        }
        
        if ObjectTypeName.isEmpty {
            throw CompilerMessage(
                absoluteFilePath: line.absoluteFilePath,
                lineNumber: line.lineNumber,
                message: "[Compiler] Could not determine type"
            )
        }
        
        return Typê.ObjectType(name: ObjectTypeName)
    }
    
    func parseCollectionItemType(_ collecitonItemTypeName: String, line: SourceCodeLine) throws -> Typê
    {
        if collecitonItemTypeName.contains(":") {
            let keyTypeName:   String = collecitonItemTypeName.truncateFromWord(":")
            let valueTypeName: String = collecitonItemTypeName.truncateToWord(":", deleteWord: true)
            
            return Typê.MapType(pair: (key: try self.parseType(typeName: keyTypeName, line: line), value: try self.parseType(typeName: valueTypeName, line: line)))
        } else {
            return Typê.ArrayType(item: try self.parseType(typeName: collecitonItemTypeName, line: line))
        }
    }
    
}

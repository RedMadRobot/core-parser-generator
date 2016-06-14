//
//  ParserImplementationWriter.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 09/11/15.
//  Copyright © 2015 Egor Taflanidi. All rights reserved.
//

import Foundation


let tab = "    "

/**
 Генератор реализации парсера.
 */
class ParserImplementationWriter {
    
    // MARK: - Публичные методы
    
    /**
     Сгенерировать реализацию (.swift).
     */
    internal func writeImplementation(
        klass: Klass,
        klasses: [Klass],
        projectName: String
        ) throws -> String
    {
        let head: String = ""
            .addLine("//")
            .addLine("//  \(klass.name)Parser.swift")
            .addLine("//  \(projectName)")
            .addLine("//")
            .addLine("//  Created by Code Generator")
            .addLine("//  Copyright (c) 2015 RedMadRobot LLC. All rights reserved.")
            .addLine("//")
            .addBlankLine()
        
        let headImports: String = head
            .addLine("import Foundation")
            .addLine("import CoreParser")
            .addBlankLine()
            .addBlankLine()
        
        let headImportsParseObject: String = headImports
            .addLine("class \(klass.name)Parser: JSONParser<\(klass.name)> {")
            .addBlankLine()
            .addLine(tab + "override func parseObject(data: [String : JSON]) -> \(klass.name)?")
            .addLine(tab + "{")
            .addLine(tab + tab + "guard")
        
        let allGuard: String = headImportsParseObject
            .append(try self.guardStatements(klasses, properties: klass.properties.filter { nil != $0.jsonKey() && $0.mandatory() }))
            .addBlankLine()
            .addLine(tab + tab + "else { return nil }")
            .addBlankLine()
        
        let allOptional: String = allGuard
            .append(try self.optionalStatements(klasses, properties: klass.properties.filter { nil != $0.jsonKey() && !$0.mandatory() }))
            .addBlankLine()
            .addBlankLine()
        
        let fillObject: String = allOptional
            .addLine(tab + tab + "let object = \(klass.name)()")
            .append(self.fillPropertiesStatements(klass.properties.filter { nil != $0.jsonKey() }))
            .addBlankLine()
            .addBlankLine()
            .addLine(tab + tab + "return object")
            .addLine(tab + "}")
            .addBlankLine()
            .addLine("}")
        
        return fillObject
    }
}

private extension ParserImplementationWriter {
    
    func guardStatements(klasses: [Klass], properties: [Property]) throws -> String
    {
        return properties.reduce("") { (line: String, p: Property) -> String in
            let letStatement: String = tab + tab + tab + "let \(p.name) = "
            let guardStatement: String
            
            switch p.type {
                case .StringType:
                    guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.string"
                
                case .IntType:
                    guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.int"
                
                case .DoubleType:
                    guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.double"
                
                case .FloatType:
                    guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.float"
                
                case .DateType:
                    guardStatement = letStatement + "NSDate(timeIntervalSince1970: data[\"\(p.jsonKey()!)\"]?.double)"
                
                case let .ObjectType(typename):
                    if self.hasKlassParser(forTypeName: typename, klasses: klasses) {
                        guardStatement = letStatement + "\(typename)Parser().parseObject(data[\"\(p.jsonKey()!)\"]?.dictionary)"
                    } else {
                        fatalError()
                    }
                
                case let .ArrayType(itemType):
                    switch itemType {
                        case .IntType, .FloatType, .DoubleType, .StringType:
                            guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.array"
                        default:
                            fatalError()
                    }
                
                case .MapType:
                    guardStatement = letStatement + "data[\"\(p.jsonKey()!)\"]?.dictionary"
            }
            
            return line.isEmpty ? guardStatement : line + ",\n" + guardStatement
        }
    }
    
    func optionalStatements(klasses: [Klass], properties: [Property]) throws -> String
    {
        return properties.reduce("") { (line: String, p: Property) -> String in
            let statement: String
            
            switch p.type {
                case .IntType:
                    statement = tab + tab + "let \(p.name): Int? = data[\"\(p.jsonKey()!)\"]!.int!"
                
                case .FloatType:
                    statement = tab + tab + "let \(p.name): Float? = data[\"\(p.jsonKey()!)\"]!.float!"
                
                case .DoubleType:
                    statement = tab + tab + "let \(p.name): Double? = data[\"\(p.jsonKey()!)\"]!.double!"
                
                case .DateType:
                    statement = tab + tab + "let \(p.name): NSDate? = NSDate(timeIntervalSince1970: data[\"\(p.jsonKey()!)\"]!.double!)"
                
                case .StringType:
                    statement = tab + tab + "let \(p.name): String? = data[\"\(p.jsonKey()!)\"]!.string!"
                
                case let .ObjectType(typename):
                    if self.hasKlassParser(forTypeName: typename, klasses: klasses) {
                        statement = tab + tab + "let \(p.name): \(typename)? = \(typename)Parser().parseObject(data[\"\(p.jsonKey()!)\"]!.dictionary!)"
                    } else {
                        fatalError()
                    }
                
                case let .ArrayType(itemType):
                    switch itemType {
                        case .IntType, .FloatType, .DoubleType, .StringType:
                            statement = tab + tab + "let \(p.name) = data[\"\(p.jsonKey()!)\"]!.array!"
                        
                        case let .ObjectType(typename):
                            statement = tab + tab + "let \(p.name) = \(typename)Parser.parse(data[\"\(p.jsonKey()!)\"]!)"
                        
                        default:
                            fatalError()
                    }
                
                case .MapType:
                    statement = tab + tab + "let \(p.name) = data[\"\(p.jsonKey()!)\"]!.dictionary!"
            }
            
            let ifStatement: String = tab + tab + "if nil != data[\"\(p.jsonKey()!)\"] {\n" + tab + statement + "\n" + tab + tab + "}"
            return line.isEmpty ? ifStatement : line + "\n" + ifStatement
        }
    }
    
    func fillPropertiesStatements(properties: [Property]) -> String
    {
        return properties.reduce("") { (line: String, p: Property) -> String in
            let statement = tab + tab + "object.\(p.name) = \(p.name)"
            return line.isEmpty ? statement : line + "\n" + statement
        }
    }
    
    func hasKlassParser(forTypeName type: String, klasses: [Klass]) -> Bool
    {
        for klass in klasses {
            if klass.name == type {
                return true
            }
        }
        return false
    }
    
}

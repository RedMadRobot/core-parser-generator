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
        
        var guardStatements:      [String] = []
        var optionalStatements:   [String] = []
        var fillObjectStatements: [String] = []

        for property in klass.properties {
            let propertyWriter: PropertyWriter =
                PropertyWriterFactory().createWriterForProperty(property, availableKlasses: klasses)

            if property.mandatory {
                try guardStatements += propertyWriter.parseStatements()
            } else {
                try optionalStatements += propertyWriter.parseStatements()
            }

            try fillObjectStatements += propertyWriter.fillObjectStatements()
        }
        
        let allGuard: String = headImportsParseObject
            .append(guardStatements.joinWithSeparator("\n"))
            .addBlankLine()
            .addLine(tab + tab + "else { return nil }")
            .append(optionalStatements.count > 0 ? "\n" : "")

        let allOptional: String = allGuard
            .append(optionalStatements.joinWithSeparator("\n"))
            .addBlankLine()
            .append(optionalStatements.count > 0 ? "\n" : "")

        let fillObject: String = allOptional
            .addLine(tab + tab + "let object = \(klass.name)()")
            .append(fillObjectStatements.joinWithSeparator("\n"))
            .addBlankLine()
            .addBlankLine()
            .addLine(tab + tab + "return object")
            .addLine(tab + "}")
            .addBlankLine()
            .addLine("}")
        
        return fillObject
    }
}

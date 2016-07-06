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
            .addLine("class \(klass.name)Parser: JSONParser<\(klass.name)>")
            .addLine("{")
            .addBlankLine()
            .addLine("    override init(fulfiller: Fulfiller<\(klass.name)>?)")
            .addLine("    {")
            .addLine("        super.init(fulfiller: fulfiller)")
            .addLine("    }")
            .addBlankLine()
            .addLine(tab + "override func parseObject(data: [String : JSON]) -> \(klass.name)?")
            .addLine(tab + "{")
            .addLine(tab + tab + "guard")
        
        var guardStatements:      [String] = []
        var optionalStatements:   [String] = []
        var fillObjectStatements: [String] = []

        var constructorArguments: [String : String] = [:]

        for property in klass.properties {
            let propertyWriter: PropertyWriter =
                PropertyWriterFactory().createWriter(
                    forProperty: property,
                    currentKlass: klass,
                    availableKlasses: klasses
                )

            if property.mandatory {
                try guardStatements += propertyWriter.parseStatements()
            } else {
                try optionalStatements += propertyWriter.parseStatements()
            }

            try fillObjectStatements += propertyWriter.fillObjectStatements()

            if let constructorArgument = propertyWriter.constructorArgument() {
                constructorArguments[property.name] = constructorArgument
            }
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
            .addLine(tab + tab + "let object = \(klass.name)(")
            .append(try self.write(constructorArguments: constructorArguments, forKlass: klass))
            .addLine(tab + tab + ")")
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

private extension ParserImplementationWriter {

    func write(
        constructorArguments arguments: [String : String],
        forKlass klass: Klass
    ) throws -> String
    {
        var constructor: Method? = nil

        for method in klass.methods {
            if method.name == "init" {
                constructor = method
                break
            }
        }

        guard let klassConstructor: Method = constructor
        else {
            throw ParseException(
                filename: klass.declaration.filename,
                lineNumber: klass.declaration.lineNumber,
                message: "Class does not have constructor"
            )
        }

        return try klassConstructor.arguments
            .reduce("") { (initial: String, argument: Argument) -> String in
                if let constructorArgument = arguments[argument.name] {
                    return tab + tab + tab + constructorArgument + "\n"
                } else {
                    throw ParseException(
                        filename: argument.declaration.filename,
                        lineNumber: argument.declaration.lineNumber,
                        message: "Constructor argument could not be initialized"
                    )
                }
            }
    }

}

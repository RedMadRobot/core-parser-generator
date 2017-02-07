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
        let properties =
            (klass.properties + self.getInheritedProperties(forKlass: klass, availableKlasses: klasses)).filter { return nil != $0.jsonKey() }

        let constructor: Method = try self.chooseConstructor(fromKlass: klass, forProperties: properties)

        let head: String = ""
            .addLine("//")
            .addLine("//  \(klass.name)Parser.swift")
            .addLine("//  \(projectName)")
            .addLine("//")
            .addLine("//  Created by Code Generator")
            .addLine("//  Copyright (c) 2017 RedMadRobot LLC. All rights reserved.")
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
            .addLine(tab + "override func parseObject(_ data: JSON) -> \(klass.name)?")
            .addLine(tab + "{")
            .addLine(tab + tab + "printAbsentFields(in: data)")
            .addBlankLine()

        var guardStatements:      [String] = []
        var optionalStatements:   [String] = []
        var fillObjectStatements: [String] = []

        for property in properties {
            if property.constant {
                if property.hasDefaultValue() {
                    throw CompilerMessage(
                        absoluteFilePath: property.declaration.absoluteFilePath,
                        lineNumber: property.declaration.lineNumber,
                        message: "[ParserGenerator] Initialized constant property cannot be filled from JSON"
                    )
                }
            }

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
                
                if !constructor.arguments.contains(argument: property.name) {
                    fillObjectStatements += [ tab + tab + "object.\(property.name) = \(property.name)" ]
                }
            }
        }
        
        let allGuard: String = headImportsParseObject
            .append(guardStatements.count > 0 ? tab + tab + "guard\n" : "")
            .append(guardStatements.joined(separator: ",\n"))
            .append(guardStatements.count > 0 ? "\n" : "")
            .append(guardStatements.count > 0 ? tab + tab + "else { return nil }\n" : "")
            .append(guardStatements.count > 0 ? "\n" : "")

        let allOptional: String = allGuard
            .append(optionalStatements.joined(separator: "\n"))
            .append(optionalStatements.count > 0 ? "\n" : "")
            .append(optionalStatements.count > 0 ? "\n" : "")

        let constructorArgumentsLine: String
            = try self.writeArguments(forConstructor: constructor, usingProperties: properties)

        let fillObject: String = allOptional
            .append(tab + tab + "let object = \(klass.name)(")
            .append(constructorArgumentsLine.isEmpty ? "" : "\n")
            .append(constructorArgumentsLine)
            .append(constructorArgumentsLine.isEmpty ? ")" : "\n" + tab + tab + ")")
            .append(fillObjectStatements.count > 0 ? "\n" : "")
            .append(fillObjectStatements.joined(separator: "\n"))
            .append(fillObjectStatements.count > 0 ? "\n" : "")
            .addBlankLine()
            .addLine(tab + tab + "return object")
            .addLine(tab + "}")
            .addBlankLine()
        
        let mandatoryFieldList: String = properties
            .filter { (p: Property) -> Bool in
                return p.mandatory
            }
            .reduce("") { (line: String, p: Property) -> String in
                return "\"" + p.jsonKey()! + "\", " + line
            }
        
        let optionalFieldList: String = properties
            .filter { (p: Property) -> Bool in
                return !p.mandatory
            }
            .reduce("") { (line: String, p: Property) -> String in
                return "\"" + p.jsonKey()! + "\", " + line
            }
        
        let modelFields: String = fillObject
            .addLine(tab + "override class func modelFields() -> Fields")
            .addLine(tab + "{")
            .addLine(tab + tab + "return Fields(")
            .addLine(tab + tab + tab + "mandatory: Set([")
            .addLine(tab + tab + tab + tab + mandatoryFieldList)
            .addLine(tab + tab + tab + "]),")
            .addLine(tab + tab + tab + "optional: Set([")
            .addLine(tab + tab + tab + tab + optionalFieldList)
            .addLine(tab + tab + tab + "])")
            .addLine(tab + tab + ")")
            .addLine(tab + "}")
            .addLine("}")
        
        return modelFields
    }
}

private extension ParserImplementationWriter {
    
    func getInheritedProperties(forKlass klass: Klass, availableKlasses: [Klass]) -> [Property]
    {
        if let parent: String = klass.parent {
            if let parentKlass = availableKlasses[parent] {
                return parentKlass.properties + self.getInheritedProperties(forKlass: parentKlass, availableKlasses: availableKlasses)
            } else if parent.contains(".") {
                // do nothing; parent class belongs to some framework
                print(
                    CompilerMessage(
                        absoluteFilePath: klass.declaration.absoluteFilePath,
                        lineNumber: klass.declaration.lineNumber,
                        message: "[ParserGenerator] Parent class is not available in generator's scope",
                        type: .Note
                    )
                )
                return []
            } else {
                print(
                    CompilerMessage(
                        absoluteFilePath: klass.declaration.absoluteFilePath,
                        lineNumber: klass.declaration.lineNumber,
                        message: "[ParserGenerator] Parent class is not available in generator's scope",
                        type: .Warning
                    )
                )
                return []
            }
        } else {
            return []
        }
    }
    
    func chooseConstructor(
        fromKlass klass: Klass,
        forProperties properties: [Property]
    ) throws -> Method
    {
        let constructors: [Method] = klass.methods.filter { return $0.name == "init" }
        
        for constructor in constructors {
            var initsAllProperties: Bool = true
            for property in properties {
                if !constructor.arguments.contains(argument: property.name) {
                    if property.constant {
                        initsAllProperties = false
                        break
                    }
                    if property.mandatory {
                        initsAllProperties = false
                        break
                    }
                }
            }
            
            for argument in constructor.arguments {
                if !properties.contains(property: argument.name) {
                    if argument.mandatory && !argument.declaration.line.truncateFromWord("//").contains("=") {
                        initsAllProperties = false
                    }
                }
            }
            
            if initsAllProperties {
                return constructor
            }
        }
        
        throw CompilerMessage(
            absoluteFilePath: klass.declaration.absoluteFilePath,
            lineNumber: klass.declaration.lineNumber,
            message: "[ParserGenerator] Parser could not pick an initializer method: "
                   + "don't know how to associate init arguments with class properties"
        )
    }
    
    func writeArguments(
        forConstructor constructor: Method,
        usingProperties properties: [Property]
    ) throws -> String
    {
        return try constructor.arguments.reduce("") { (initial: String, argument: Argument) -> String in
            let prefix: String
                = initial.isEmpty ? tab + tab + tab : initial + ",\n" + tab + tab + tab
    
            if properties.contains(property: argument.name) {
                return prefix + "\(argument.name): \(argument.name)"
            } else if !argument.mandatory {
                return prefix + "\(argument.name): nil"
            } else if argument.declaration.line.truncateFromWord("//").contains("=") {
                return initial
            } else {
                throw CompilerMessage(
                    absoluteFilePath: argument.declaration.absoluteFilePath,
                    lineNumber: argument.declaration.lineNumber,
                    message: "[ParserGenerator] Parser could not use an initializer method: "
                           + "don't know how to fill \(argument.name) argument"
                )
            }
        }
    }
    
}

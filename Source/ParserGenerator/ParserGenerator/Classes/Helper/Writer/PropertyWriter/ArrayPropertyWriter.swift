// 
// ArrayPropertyWriter.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

class ArrayPropertyWriter: PropertyWriter {

    let itemType: Typê

    internal init(
        property: Property,
        currentKlass: Klass,
        availableKlasses: [Klass],
        itemType: Typê
    )
    {
        self.itemType = itemType
        super.init(property: property, currentKlass: currentKlass, availableKlasses: availableKlasses)
    }

    override func parseStatements() throws -> [String]
    {
        if let parser: String = self.property.parser() {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(parser)().parse(data[\"\(self.property.jsonKey()!)\"]!.raw()) : nil"
            ]
        } else if self.checkIfParserAvailableInScope(forKlass: self.itemType.description) {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(self.itemType)Parser().parse(data[\"\(self.property.jsonKey()!)\"]!.raw()) : nil"
            ]
        } else if self.itemType.isPrimitive() {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? data[\"\(self.property.jsonKey()!)\"]!.array as? \(self.property.type) : nil"
            ]
        } else {
            throw CompilerMessage(
                absoluteFilePath: self.property.declaration.absoluteFilePath,
                lineNumber: self.property.declaration.lineNumber,
                message: "[ParserGenerator] Cannot find parser for object type \(self.property.type)"
            )
        }

    }

}

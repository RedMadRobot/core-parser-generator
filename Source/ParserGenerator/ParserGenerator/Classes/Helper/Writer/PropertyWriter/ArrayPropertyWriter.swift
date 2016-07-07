// 
// ArrayPropertyWriter.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

class ArrayPropertyWriter: PropertyWriter {

    let itemType: PropertyType

    internal init(
        property: Property,
        currentKlass: Klass,
        availableKlasses: [Klass],
        itemType: PropertyType
    )
    {
        self.itemType = itemType
        super.init(property: property, currentKlass: currentKlass, availableKlasses: availableKlasses)
    }

    override func parseStatements() throws -> [String]
    {
        if self.checkIfParserAvailableInScope(forKlass: self.itemType.description) {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(self.itemType)Parser().parse(body: data[\"\(self.property.jsonKey()!)\"]!) : nil"
            ]
        } else {
            throw CompilerMessage(
                filename: self.property.declaration.filename,
                lineNumber: self.property.declaration.lineNumber,
                message: "[ParserGenerator] Cannot find parser for object type \(self.property.type)"
            )
        }

    }

}

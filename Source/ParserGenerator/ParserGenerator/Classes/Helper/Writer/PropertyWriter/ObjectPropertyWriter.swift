// 
// ObjectPropertyWriter.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation


class ObjectPropertyWriter: PropertyWriter {

    override func parseStatements() throws -> [String]
    {
        if let parser: String = self.property.parser() {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(parser)().parse(data[\"\(self.property.jsonKey()!)\"]!.raw()).first : nil"
            ]
        } else if self.checkIfParserAvailableInScope(forKlass: self.property.type.description) {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(self.property.type)Parser().parse(data[\"\(self.property.jsonKey()!)\"]!.raw()).first : nil"
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

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
        if self.checkIfParserAvailableInScope(forKlass: self.property.type.description) {
            return [
                optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"]) ? \(self.property.type)Parser().parse(body: data[\"\(self.property.jsonKey()!)\"]!) : nil"
            ]
        } else {
            throw ParseException(filename: "Filename", lineNumber: 0, message: "Cannot find parser for object type \(self.property.type)")
        }
    }

}

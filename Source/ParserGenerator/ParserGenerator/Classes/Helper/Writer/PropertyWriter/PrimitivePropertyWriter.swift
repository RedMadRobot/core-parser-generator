// 
// PrimitivePropertyWriter.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

class PrimitivePropertyWriter: PropertyWriter {

    override func parseStatements() throws -> [String]
    {
        let valueSuffix: String = self.property.mandatory ? "Value" : ""

        return [
            optTab + tab + tab + "let \(self.property.name): \(self.property.type)\(optMark) = data[\"\(self.property.jsonKey()!)\"]?.\(self.property.type.getSwiftyJsonSuffix())\(valueSuffix)"
        ]
    }

}

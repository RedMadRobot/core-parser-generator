// 
// DatePropertyWriter.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

class DatePropertyWriter: PropertyWriter {

    override func parseStatements() throws -> [String]
    {
        let valueSuffix: String = self.property.mandatory ? "Value" : ""

        return [
            optTab + tab + tab + "let \(self.property.name): NSDate\(optMark) = (nil != data[\"\(self.property.jsonKey()!)\"].\(self.property.type.getSwiftyJsonSuffix())\(valueSuffix)) ? NSDate(timeIntervalSince1970: data[\"\(self.property.jsonKey()!)\"]!.\(self.property.type.getSwiftyJsonSuffix())\(valueSuffix)) : nil"
        ]
    }

}

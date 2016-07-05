//
//  PropertyWriter.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 04.07.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


class PropertyWriter {
    
    internal let property:          Property
    internal let availableKlasses:  [Klass]
    internal let optTab:            String
    internal let optMark:           String

    internal init(property: Property, availableKlasses: [Klass])
    {
        self.property           = property
        self.availableKlasses   = availableKlasses
        self.optTab             = property.mandatory ? tab : ""
        self.optMark            = property.mandatory ? "" : "?"
    }
    
    internal func parseStatements() throws  -> [String]
    {
        return []
    }
    
    internal func fillObjectStatements() throws -> [String]
    {
        return [
            tab + tab + "object.\(self.property.name) = \(self.property.name)"
        ]
    }
    
    internal func checkIfParserAvailableInScope(forKlass klassName: String) -> Bool
    {
        for klass in self.availableKlasses {
            if klass.name == klassName {
                return true
            }
        }

        return false
    }

}

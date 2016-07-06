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
    internal let currentKlass:      Klass
    internal let availableKlasses:  [Klass]
    internal let optTab:            String
    internal let optMark:           String

    internal init(property: Property, currentKlass: Klass, availableKlasses: [Klass])
    {
        self.property           = property
        self.currentKlass       = currentKlass
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
        if self.isPropertyInitializedThroughConstructor() {
            return []
        }

        return [
            tab + tab + "object.\(self.property.name) = \(self.property.name)"
        ]
    }

    internal func constructorArgument() -> String?
    {
        if self.isPropertyInitializedThroughConstructor() {
            return "\(self.property.name): \(self.property.name)"
        }

        return nil
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

private extension PropertyWriter {

    func isPropertyInitializedThroughConstructor() -> Bool
    {
        var constructorBody: [SourceCodeLine] = []

        for method in self.currentKlass.methods {
            if method.name == "init" {
                constructorBody = method.body
                break
            }
        }

        for line in constructorBody {
            if line.line.containsString("self.\(self.property.name) = ") {
                return true
            }
        }

        return false
    }

}

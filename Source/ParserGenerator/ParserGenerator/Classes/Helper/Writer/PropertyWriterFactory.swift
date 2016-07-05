//
//  PropertyWriterFactory.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 04.07.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


class PropertyWriterFactory {

    internal func createWriterForProperty(
        property: Property,
        availableKlasses: [Klass]
    ) -> PropertyWriter
    {
        switch property.type {
            case .IntType, .BoolType, .FloatType, .DoubleType, .StringType:
                return PrimitivePropertyWriter(
                    property: property,
                    availableKlasses: availableKlasses
                )

            case .DateType:
                return DatePropertyWriter(
                    property: property,
                    availableKlasses: availableKlasses
                )

            case .ObjectType:
                return ObjectPropertyWriter(
                    property: property,
                    availableKlasses: availableKlasses
                )

            case let .ArrayType(itemType):
                return ArrayPropertyWriter(property: property, availableKlasses: availableKlasses, itemType: itemType)

            case let .MapType(pair):
                return PropertyWriter(property: property, availableKlasses: availableKlasses)
        }
    }

}

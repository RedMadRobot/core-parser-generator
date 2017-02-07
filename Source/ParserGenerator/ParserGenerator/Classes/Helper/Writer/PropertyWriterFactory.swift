//
//  PropertyWriterFactory.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 04.07.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


class PropertyWriterFactory {

    internal func createWriter(
        forProperty property: Property,
        currentKlass: Klass,
        availableKlasses: [Klass]
    ) -> PropertyWriter
    {
        switch property.type {
            case .IntType, .BoolType, .FloatType, .DoubleType, .StringType:
                return PrimitivePropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses
                )

            case .DateType:
                return DatePropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses
                )

            case .ObjectType:
                return ObjectPropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses
                )

            case let .ArrayType(itemType):
                return ArrayPropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses,
                    itemType: itemType
                )

            case .MapType:
                return PropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses
                )
            
            case .GenericType:
                return PropertyWriter(
                    property: property,
                    currentKlass: currentKlass,
                    availableKlasses: availableKlasses
                )
        }
    }

}

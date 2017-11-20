//
//  Property.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class Property: Equatable, CustomDebugStringConvertible {
    
    open let name:        String
    open let type:        Typê
    open let annotations: [Annotation]
    open let constant:    Bool
    open let mandatory:   Bool
    open let declaration: SourceCodeLine
    
    public init(
        name: String,
        type: Typê,
        annotations: [Annotation],
        constant: Bool,
        mandatory: Bool,
        declaration: SourceCodeLine
    )
    {
        self.name        = name
        self.type        = type
        self.annotations = annotations
        self.constant    = constant
        self.mandatory   = mandatory
        self.declaration = declaration
    }
    
    open var debugDescription: String
    {
        get {
            return "Property: name: \(self.name); type: \(self.type); constant: \(self.constant); mandatory: \(self.mandatory); annotations: \(self.annotations)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }
    
}

public func ==(left: Property, right: Property) -> Bool
{
    return left.name        == right.name
        && left.type        == right.type
        && left.annotations == right.annotations
        && left.constant    == right.constant
        && left.mandatory   == right.mandatory
        && left.declaration == right.declaration
}

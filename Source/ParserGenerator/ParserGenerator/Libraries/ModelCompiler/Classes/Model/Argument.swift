//
//  Argument.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


open class Argument: Equatable, CustomDebugStringConvertible {
    
    open let name: String
    open let bodyName: String
    open let type: Typê
    open let mandatory: Bool
    open let annotations: [Annotation]
    open let declaration: SourceCodeLine
    
    public init(
        name: String,
        bodyName: String,
        type: Typê,
        mandatory: Bool,
        annotations: [Annotation],
        declaration: SourceCodeLine
    )
    {
        self.name        = name
        self.bodyName    = bodyName
        self.type        = type
        self.mandatory   = mandatory
        self.annotations = annotations
        self.declaration = declaration
    }

    open var debugDescription: String
    {
        get {
            return "Argument: name: \(self.name); body name: \(self.bodyName); type: \(self.type); mandatory: \(self.mandatory); annotations: \(self.annotations)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }

}

public func ==(left: Argument, right: Argument) -> Bool
{
    return
        left.annotations == right.annotations
     && left.declaration == right.declaration
     && left.mandatory   == right.mandatory
     && left.type        == right.type
     && left.name        == right.name
}

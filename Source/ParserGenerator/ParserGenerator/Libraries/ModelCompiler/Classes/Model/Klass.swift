//
//  Klass.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class Klass: Equatable, CustomDebugStringConvertible {
    
    open let name:        String
    open let parent:      String?
    open let properties:  [Property]
    open let annotations: [Annotation]
    open let declaration: SourceCodeLine
    open let methods:     [Method]
    open let body:        [SourceCodeLine]
    
    public init(
        name:           String,
        parent:         String?,
        properties:     [Property],
        annotations:    [Annotation],
        declaration:    SourceCodeLine,
        methods:        [Method],
        body:           [SourceCodeLine]
    )
    {
        self.name        = name
        self.parent      = parent
        self.properties  = properties
        self.annotations = annotations
        self.declaration = declaration
        self.methods     = methods
        self.body        = body
    }
    
    open var debugDescription: String
    {
        get {
            return "Klass: name: \(self.name); parent: \(self.parent ?? ""); annotations: \(self.annotations)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }
    
}

public func ==(left: Klass, right: Klass) -> Bool
{
    return left.name        == right.name
        && left.parent      == right.parent
        && left.properties  == right.properties
        && left.annotations == right.annotations
        && left.declaration == right.declaration
        && left.methods     == right.methods
//        uncomment if necessary
//        && left.body        == right.body
}

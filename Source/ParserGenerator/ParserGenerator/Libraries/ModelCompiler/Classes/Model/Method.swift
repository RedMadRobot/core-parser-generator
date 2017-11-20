//
//  Method.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


open class Method: Equatable, CustomDebugStringConvertible {

    open let name:        String
    open let arguments:   [Argument]
    open let annotations: [Annotation]
    open let returnType:  Typê?
    open let declaration: SourceCodeLine
    open let body:        [SourceCodeLine]

    public init(
        name: String,
        arguments: [Argument],
        annotations: [Annotation],
        returnType: Typê?,
        declaration: SourceCodeLine,
        body: [SourceCodeLine]
    )
    {
        self.name = name
        self.arguments = arguments
        self.annotations = annotations
        self.returnType = returnType
        self.declaration = declaration
        self.body = body
    }

    open var debugDescription: String
    {
        get {
            return "Method: name: \(self.name); return type: \(self.returnType); annotations: \(self.annotations)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }

}

public func ==(left: Method, right: Method) -> Bool
{
    return
        left.declaration == right.declaration
     && left.annotations == right.annotations
     && left.arguments   == right.arguments
     && left.name        == right.name
     && left.returnType  == right.returnType
     && left.body        == right.body
}

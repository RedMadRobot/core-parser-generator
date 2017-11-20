//
//  Annotation.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class Annotation: Equatable, CustomDebugStringConvertible {
    
    open let name: String
    open let value: String?
    
    public init(name: String, value: String?)
    {
        self.name  = name
        self.value = value
    }
    
    open var debugDescription: String
    {
        get {
            return "Annotation: name = \(self.name); value = \(self.value)"
        }
    }
    
}

public func ==(left: Annotation, right: Annotation) -> Bool
{
    return left.name  == right.name
        && left.value == right.value
}

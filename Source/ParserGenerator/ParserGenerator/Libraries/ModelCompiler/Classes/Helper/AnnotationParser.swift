//
//  AnnotationParser.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class AnnotationParser {
    
    public init()
    {
    }
    
    open func parse(comment string: String) -> [Annotation]
    {
        var s:          String       = string
        var annotaions: [Annotation] = []
        
        while s.contains("@") {
            let annotationName: String = s.truncateToWord("@", deleteWord: true).firstWord()
            s = s.truncateToWord("@" + annotationName, deleteWord: true)
            
            let annotationValue: String?
            
            if s.hasPrefix("\n") || s.hasPrefix(" \n") {
                annotationValue = nil
            } else {
                annotationValue = s.truncateLeadingWhitespace().firstWord()
            }
            
            annotaions.append(Annotation(name: annotationName, value: annotationValue))
        }
        
        return annotaions
    }
    
}

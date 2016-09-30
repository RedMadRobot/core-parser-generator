//
//  Klass+Parser.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


extension Klass {
    
    func isModel() -> Bool
    {
        return self.annotations.contains(Annotation(name: "model", value: nil))
    }
    
    func isAbstract() -> Bool
    {
        return self.isModel() ? self.annotations.contains(Annotation(name: "abstract", value: nil)) : true
    }
    
}

extension Array where Element: Klass {
    
    func contains(klass: String) -> Bool
    {
        for element in self {
            if klass == element.name {
                return true
            }
        }
        return false
    }
    
    subscript (index: String) -> Klass?
    {
        for element in self {
            if element.name == index {
                return element
            }
        }
        return nil
    }
    
}

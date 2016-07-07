//
//  Property+Parser.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


extension Property {
    
    func jsonKey() -> String?
    {
        var key: String? = nil
        
        self.annotations.forEach { (a: Annotation) in
            if a.name == "json" {
                key = a.value
            }
        }
        
        return key
    }

    func hasDefaultValue() -> Bool
    {
        return self.declaration.line.truncateFromWord("//").containsString("=")
    }
    
}

extension Array where Element: Property {
    
    func contains(property property: String) -> Bool
    {
        for element in self {
            if element.name == property {
                return true
            }
        }
        
        return false
    }
    
}

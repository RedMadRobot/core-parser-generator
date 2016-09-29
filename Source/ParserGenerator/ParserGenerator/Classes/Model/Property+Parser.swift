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
        for annotation in self.annotations {
            if annotation.name == "json" {
                if let key: String = annotation.value {
                    return key
                } else {
                    return self.name
                }
            }
        }
        
        return nil
    }

    func hasDefaultValue() -> Bool
    {
        return self.declaration.line.truncateFromWord("//").containsString("=")
    }
    
    func parser() -> String?
    {
        for annotation in self.annotations {
            if annotation.name == "parser" {
                if let key: String = annotation.value {
                    return key
                } else {
                    return nil
                }
            }
        }
        return nil
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

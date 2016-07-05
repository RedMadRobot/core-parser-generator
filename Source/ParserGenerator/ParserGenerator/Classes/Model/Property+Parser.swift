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
        
}

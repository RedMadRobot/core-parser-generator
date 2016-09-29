// 
// Argument+Parser.swift
// AppCode
// 
// Created by Egor Taflanidi on 07.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation


extension Array where Element: Argument {
    
    func contains(argument: String) -> Bool
    {
        for element in self {
            if element.name == argument {
                return true
            }
        }
        
        return false
    }
    
}

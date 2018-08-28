// 
// Protokol.swift
// AppCode
// 
// Created by Egor Taflanidi on 08.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

class Protokol: Klass {
    
    override var debugDescription: String
    {
        get {
            return "Protokol: name: \(self.name); parent: \(self.parent ?? ""); annotations: \(self.annotations)"
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
        }
    }
    
}

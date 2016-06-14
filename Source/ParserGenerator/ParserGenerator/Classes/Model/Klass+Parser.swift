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
    
}

//
//  String+Line.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

// MARK: - Добавление строк
public extension String {
    
    /**
     Добавляет пустую строку.
     
     - returns: Добавляет пустую строку.
     */
    public func addBlankLine() -> String
    {
        return addLine("")
    }
    
    /**
     Добавляет строку **line** (с переносом каретки).
     
     - parameter line: строка, которую нужно добавить.
     
     - returns: Добавляет строку **line** (с переносом каретки).
     */
    public func addLine(_ line: String) -> String
    {
        let straightLine: String = line.replacingOccurrences(of: "\n", with: "")
        
        return self + straightLine + "\n"
    }
    
    /**
     Добавляет текст **line** (без переноса каретки).
     
     - parameter line: текст, который нужно добавить
     
     - returns: Добавляет текст **line** (без переноса каретки).
     */
    public func append(_ line: String) -> String
    {
        return self + line
    }
    
    public func lines() -> [String]
    {
        return self.components(separatedBy: "\n")
    }
    
}

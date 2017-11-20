//
//  Typê.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

public indirect enum Typê: Equatable, CustomStringConvertible {
    case BoolType
    case IntType
    case FloatType
    case DoubleType
    case StringType
    case DateType
    case ObjectType(name: String)
    case ArrayType(item: Typê)
    case MapType(pair: (key: Typê, value: Typê))
    case GenericType(name: String, item: Typê)
    
    public var description: String
    {
        get {
            switch self {
                case .BoolType: return "Bool"
                case .IntType: return "Int"
                case .FloatType: return "Float"
                case .DoubleType: return "Double"
                case .StringType: return "String"
                case .DateType: return "NSDate"
                case let .ObjectType(name): return "\(name)"
                case let .ArrayType(item): return "[\(item)]"
                case let .MapType(keyValue): return "[\(keyValue.key) : \(keyValue.value)]"
                case let .GenericType(name, item): return "\(name)<\(item)>"
            }
        }
    }

    public func getSwiftyJsonSuffix() -> String
    {
        switch self {
            case .BoolType: return "bool"
            case .IntType: return "int"
            case .FloatType: return "float"
            case .DoubleType: return "double"
            case .StringType: return "string"
            case .DateType: return "double"
            case .ObjectType: return "dictionary"
            case .ArrayType: return "array"
            case .MapType: return "dictionary"
            case .GenericType: return "dictionary"
        }
    }
    
    public func isPrimitive() -> Bool
    {
        switch self {
            case .BoolType, .IntType, .FloatType, .DoubleType, .StringType: return true
            case .DateType, .ObjectType, .ArrayType, .MapType, .GenericType: return false
        }
    }
}

public func ==(left: Typê, right: Typê) -> Bool
{
    switch (left, right) {
        case (Typê.BoolType, Typê.BoolType):
            return true
        
        case (Typê.IntType, Typê.IntType):
            return true
        
        case (Typê.FloatType, Typê.FloatType):
            return true
        
        case (Typê.DoubleType, Typê.DoubleType):
            return true
        
        case (Typê.DateType, Typê.DateType):
            return true
        
        case (Typê.StringType, Typê.StringType):
            return true
        
        case (let Typê.ObjectType(name: leftName), let Typê.ObjectType(name: rightName)):
            return leftName == rightName
        
        case (let Typê.ArrayType(item: leftItem), let Typê.ArrayType(item: rightItem)):
            return leftItem == rightItem
        
        case (let Typê.MapType(pair: (key: leftKey, value: leftValue)), let Typê.MapType(pair: (key: rightKey, value: rightValue))):
            return leftKey == rightKey && leftValue == rightValue
        
        case (let Typê.GenericType(leftName, leftItem), let Typê.GenericType(rightName, rightItem)):
            return leftName == rightName && leftItem == rightItem
        
        default:
            return false
    }
}

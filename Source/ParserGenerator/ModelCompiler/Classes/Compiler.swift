//
//  Compiler.swift
//  ModelCompiler
//
//  Created by Egor Taflanidi on 30.03.16.
//  Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation

open class Compiler {
    
    fileprivate let verbose: Bool

    public init(verbose: Bool)
    {
        self.verbose = verbose
    }
    
    open func compile(files: [SourceCodeFile]) throws -> [Klass]
    {
        return try files.flatMap { (file: SourceCodeFile) -> Klass? in
            return try self.compile(file: file)
        }
    }
    
    open func compile(file: SourceCodeFile) throws -> Klass?
    {
        if self.shouldIgnore(file: file) {
            return nil
        }
        
        let klass: Klass = try KlassParser().parse(file: file)
        self.verbosePrint(klass: klass)
        return klass
    }
    
}

private extension Compiler {
    
    func shouldIgnore(file: SourceCodeFile) -> Bool
    {
        for line in file.lines {
            if line.line.contains("@ignore") {
                return true
            }
        }
        return false
    }

    func verbosePrint(klass: Klass)
    {
        if self.verbose {
            let klassMessage: CompilerMessage = CompilerMessage(
                absoluteFilePath: klass.declaration.absoluteFilePath,
                lineNumber: klass.declaration.lineNumber,
                message: "\(klass)",
                type: .Warning
            )

            let propertyMessages: [CompilerMessage] = klass.properties
                .map { (property: Property) -> CompilerMessage in
                    return CompilerMessage(
                        absoluteFilePath: property.declaration.absoluteFilePath,
                        lineNumber: property.declaration.lineNumber,
                        message: "\(property)",
                        type: .Warning
                    )
                }

            let methodMessages: [CompilerMessage] = klass.methods
                .map { (method: Method) -> CompilerMessage in
                    return CompilerMessage(
                        absoluteFilePath: method.declaration.absoluteFilePath,
                        lineNumber: method.declaration.lineNumber,
                        message: "\(method)",
                        type: .Warning
                    )
                }

            let argumentMessages: [CompilerMessage] = klass.methods
                .reduce([]) { (initial: [CompilerMessage], method: Method) -> [CompilerMessage] in
                    return initial + method.arguments.map { (argument: Argument) -> CompilerMessage in
                        return CompilerMessage(
                            absoluteFilePath: argument.declaration.absoluteFilePath,
                            lineNumber: argument.declaration.lineNumber,
                            message: "\(argument)",
                            type: .Warning
                        )
                    }
                }

            print("\(klassMessage)")

            propertyMessages.forEach { print("\($0)") }
            methodMessages.forEach   { print("\($0)") }
            argumentMessages.forEach { print("\($0)") }
        }
    }

}

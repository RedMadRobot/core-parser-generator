// 
// ArgumentParser.swift
// AppCode
// 
// Created by Egor Taflanidi on 05.07.16.
// Copyright © 2016 RedMadRobot LLC. All rights reserved.
//

import Foundation


open class ArgumentParser {

    open func parse(argumentDeclarations declarations: [SourceCodeLine]) throws -> [Argument]
    {
        if declarations.count == 1 {
            return try self.parseInlineArguments(declaration: declarations.first!)
        } else {
            return try declarations.reduce([]) { (initial: [Argument], declaration: SourceCodeLine) -> [Argument] in
                let singleArgumentDeclaration: SourceCodeLine = SourceCodeLine(absoluteFilePath: declaration.absoluteFilePath, lineNumber: declaration.lineNumber, line: declaration.line.replacingOccurrences(of: ",", with: ""))
                let arguments: [Argument] = try self.parseInlineArguments(declaration: singleArgumentDeclaration)
                return initial + arguments
            }
        }
    }

}

private extension ArgumentParser {

    func parseInlineArguments(declaration line: SourceCodeLine) throws -> [Argument]
    {
        let rawArguments: String = line.line.truncateToWord("(", deleteWord: true).truncateFromWord(")")
        let rawArgumentList: [String] =
            rawArguments
            .components(separatedBy: ",")
            .map { (rawArgument: String) -> String in
                return rawArgument.trimmingCharacters(in: CharacterSet.whitespaces)
            }
            .filter { (rawArgument: String) -> Bool in
                return !rawArgument.isEmpty
            }

        return try rawArgumentList
            .map { (rawArgument: String) -> Argument in
                let name: String = rawArgument.truncateFromWord(":").trimmingCharacters(in: CharacterSet.whitespaces).firstWord()
                let bodyName: String = name.contains(" ") ? name.truncateToWord(" ", deleteWord: true) : name
                let mandatory: Bool = !rawArgument.truncateFromWord("//").contains("?")
                let rawType = rawArgument.truncateFromWord(",").truncateFromWord("//").truncateFromWord("=")
                let type: Typê = try TypeParser().parse(rawPropertyLine: SourceCodeLine(absoluteFilePath: line.absoluteFilePath, lineNumber: line.lineNumber, line: rawType))
                let comment: String = rawArgument.contains("//") ? rawArgument.truncateToWord("//", deleteWord: true) + "\n" : ""
                let annotations: [Annotation] = AnnotationParser().parse(comment: comment)

                return Argument(
                    name: name,
                    bodyName: bodyName,
                    type: type,
                    mandatory: mandatory,
                    annotations: annotations,
                    declaration: SourceCodeLine(absoluteFilePath: line.absoluteFilePath, lineNumber: line.lineNumber, line: rawArgument)
                )
            }
    }

}

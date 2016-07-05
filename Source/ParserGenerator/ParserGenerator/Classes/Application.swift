//
//  Application.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


/**
 ### Класс «Приложение»
 
 Предполагается, что в ходе исполнения код вспомогательного модуля **main.swift** запустит следующую
 инструкцию:
 ```
 exit(Application().run())
 ```
 - precondition: Для исполнения требует предоставить имена файлов заголовков модельных объектов в
 качестве параметров запуска.
 
 - postcondition: Результат исполнения: сгенерированы файлы заголовков и реализации парсеров,
 соответствующих предоставленным модельным объектам.
 - note: Заголовки модельных объектов должны быть соответствующим образом аннотированы.
 - seealso: main.swift
 */
class Application {
    
    /**
     Аргументы запуска приложения.
     */
    let arguments: [String]
    
    // MARK: - Публичные методы
    
    init()
    {
        self.arguments = Process.arguments
    }
    
    func run() -> Int32
    {
        if arguments.contains("-help") || arguments.contains("--help") {
            printHelp()
            return 0
        }
        
        let projectName:      String = self.valueForArgument("-project_name", defaultValue: "GEN")
        let inputFilesFolder: String = self.valueForArgument("-input", defaultValue: ".")
        let outputFolder:     String = self.valueForArgument("-output", defaultValue: ".")
        let debugMode:        Bool   = arguments.contains("-debug")
        
        if debugMode {
            self.printArguments(self.arguments)
        }
        
        let inputFilePaths: [String] = self.collectInputFilesAtDirectory(
            inputFilesFolder,
            fileExtension: ".swift",
            debugMode: debugMode
        )

        let klasses: [Klass] = self.readKlasses(
            filePathList: inputFilePaths,
            debugMode: debugMode
        )
        
        let parsersWritten: Int = self.tryWriteParsers(
            forKlasses: klasses,
            outputFolder: outputFolder,
            projectName: projectName,
            debugMode: debugMode
        )
        
        print("Parsers written: " + String(parsersWritten))
        
        return 0
    }
    
}

private extension Application {
    
    func printHelp()
    {
        print("Accepted arguments:")
        print("")
        print("-input <directory>")
        print("Path to the folder, where header files to be processed are stored.")
        print("If not set, current working directory is used by default.")
        print("")
        print("-output <directory>")
        print("Path to the folder, where generated files should be placed.")
        print("If not set, current working directory is used by default")
        print("")
        print("-project_name <name>")
        print("Project name to be used in generated files.")
        print("If not set, \"GEN\" is used as a default project name.")
        print("")
        print("-debug")
        print("Forces generator to print names of analyzed input files and generated parsers.")
    }
    
    func valueForArgument(argument: String, defaultValue: String) -> String
    {
        guard let index: Int = arguments.indexOf(argument)
            else {
                return defaultValue
        }
        
        return arguments.count > index + 1 ? arguments[index + 1] : defaultValue
    }
    
    func printArguments(arguments: [String])
    {
        print("Arguments: " + arguments.reduce("", combine: { (string: String, argument: String) -> String in
            return string + argument + " "
        }))
    }
    
    func collectInputFilesAtDirectory(
        directory: String,
        fileExtension: String,
        debugMode: Bool
        ) -> [String]
    {
        let filePaths: [String] = FileListFetcher().fileListInFolder(directory)
        
        return filePaths.filter { (filePath: String) -> Bool in
            if debugMode {
                print("Found input item: \(filePath)")
            }
            
            return filePath.hasSuffix(fileExtension)
        }
    }
    
    func readKlasses(filePathList paths: [String], debugMode: Bool) -> [Klass]
    {
        return paths.flatMap({ (filePath: String) -> Klass? in
            let filename: String = filePath.truncateUntilWord("/")
            
            if debugMode {
                print("Loading file " + filename)
            }
            
            let sourceCode: String = try! String(contentsOfFile: filePath)
            let klass: Klass? = self.tryCompileSourceCode(sourceCode, filename: filename, debugMode: debugMode)
            
            return klass
        })
        .filter { (element: Klass) -> Bool in
            let isModelClass: Bool = element.isModel()
            if debugMode && isModelClass {
                print("Found model class " + element.name)
            }
            return isModelClass
        }
    }
    
    func tryCompileSourceCode(code: String, filename: String, debugMode: Bool) -> Klass?
    {
        var sourceCodeLines: [SourceCodeLine] = []
        
        for (index, line) in code.lines().enumerate() {
            sourceCodeLines.append(
                SourceCodeLine(
                    filename: filename,
                    lineNumber: index,
                    line: line
                )
            )
        }
        
        let sourceCodeFile: SourceCodeFile = SourceCodeFile(
            filename: filename,
            lines: sourceCodeLines
        )
        
        return self.tryCompileSourceCode(sourceCodeFile, filename: filename, debugMode: debugMode)
    }
    
    func tryCompileSourceCode(code: SourceCodeFile, filename: String, debugMode: Bool) -> Klass?
    {
        var klass: Klass? = nil
        
        do {
            klass = try Compiler().compile(file: code)
        } catch let error as ParseException {
            print(error)
        } catch {
            // ничего не делать
        }
        
        return klass
    }
    
    func tryWriteParsers(forKlasses klasses: [Klass], outputFolder: String, projectName: String, debugMode: Bool) -> Int
    {
        let implementations: [Implementation] = klasses.flatMap { (k: Klass) -> Implementation? in
            do {
                return Implementation(
                    filename: k.name + "Parser.swift",
                    content: try ParserImplementationWriter().writeImplementation(k, klasses: klasses, projectName: projectName)
                )
            } catch let error {
                print(error)
            }
            
            return nil
        }
        
        return self.tryWriteImplementations(implementations, outputFolder: outputFolder, projectName: projectName, debugMode: debugMode)
    }
    
    func tryWriteImplementations(implementations: [Implementation], outputFolder: String, projectName: String, debugMode: Bool) -> Int
    {
        let path: String
        if !outputFolder.hasSuffix("/") {
            path = outputFolder + "/"
        } else {
            path = outputFolder
        }

        return implementations.reduce(0, combine: { (written: Int, i: Implementation) -> Int in
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
                let writer = CheckedFileWriter(atomic: false)
                try writer.write(string: i.content, toFile: path + i.filename)
            } catch {
                return written
            }
            
            return written + 1
        })
    }
    
}
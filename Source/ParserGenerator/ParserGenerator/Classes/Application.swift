//
//  Application.swift
//  ParserGenerator
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation


/**
 ### Class «Application»
 
 Assumed **main.swift** will call:
 ```
 exit(Application().run())
 ```
 - precondition: Model classes folder should be passed as input.
 
 - postcondition: Result: Generated parsers for input model classes.
 - note: Model classes should include annotations.
 - seealso: main.swift
 */
class Application {
    
    /**
     Run arguments.
     */
    let arguments: [String]
    
    // MARK: - Public methods
    
    init()
    {
        self.arguments = CommandLine.arguments
    }
    
    func run() -> Int32
    {
        if arguments.contains("-help") || arguments.contains("--help") {
            printHelp()
            return 0
        }
        
        let projectName:      String = self.valueForArgument(argument: "-project_name", defaultValue: "GEN")
        let inputFilesFolder: String = self.valueForArgument(argument: "-input", defaultValue: ".")
        let outputFolder:     String = self.valueForArgument(argument: "-output", defaultValue: ".")
        let debugMode:        Bool   = arguments.contains("-debug")
        let suppressParentClassWarnings: Bool = arguments.contains("-suppress_parent_class_warnings")
        
        if debugMode {
            self.printArguments(arguments: self.arguments)
        }
        
        let inputFilePaths: [String] = self.collectInputFilesAtDirectory(
            directory: inputFilesFolder,
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
            debugMode: debugMode,
            suppressParentClassWarnings: suppressParentClassWarnings
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
        print("")
        print("-suppress_parent_class_warnings")
        print("Don't show warnings if generator can't find model parent class.")
    }
    
    func valueForArgument(argument: String, defaultValue: String) -> String
    {
        guard let index: Int = arguments.index(of: argument)
            else {
                return defaultValue
        }
        
        return arguments.count > index + 1 ? arguments[index + 1] : defaultValue
    }
    
    func printArguments(arguments: [String])
    {
        print("Arguments: " + arguments.reduce("", { (string: String, argument: String) -> String in
            return string + argument + " "
        }))
    }
    
    func collectInputFilesAtDirectory(
        directory: String,
        fileExtension: String,
        debugMode: Bool
        ) -> [String]
    {
        let filePaths: [String] = FileListFetcher().fileListInFolder(folder: directory)
        
        return filePaths.filter { (filePath: String) -> Bool in
            if debugMode {
                print("Found input item: \(filePath)")
            }
            
            return filePath.hasSuffix(fileExtension)
        }
    }
    
    func readKlasses(filePathList paths: [String], debugMode: Bool) -> [Klass]
    {
        return paths.compactMap({ (filePath: String) -> Klass? in
            let filename: String = filePath.truncateUntilWord("/")
            
            if debugMode {
                print("Loading file " + filename)
            }
            
            let sourceCode: String = try! String(contentsOfFile: filePath)
            let klass: Klass? = self.tryCompileSourceCode(sourceCode, filepath: filePath, debugMode: debugMode)
            
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
    
    func tryCompileSourceCode(_ code: String, filepath: String, debugMode: Bool) -> Klass?
    {
        let sourceCodeFile: SourceCodeFile = SourceCodeFile(
            absoluteFilePath: filepath,
            contents: code
        )
        
        return self.tryCompileSourceCode(sourceCodeFile, filename: filepath, debugMode: debugMode)
    }
    
    func tryCompileSourceCode(_ code: SourceCodeFile, filename: String, debugMode: Bool) -> Klass?
    {
        var klass: Klass? = nil
        
        do {
            klass = try Compiler(verbose: debugMode).compile(file: code)
        } catch let error as CompilerMessage {
            print(error)
        } catch {
            // ничего не делать
        }
        
        return klass
    }
    
    func tryWriteParsers(
        forKlasses klasses: [Klass],
                   outputFolder: String,
                   projectName: String,
                   debugMode: Bool,
                   suppressParentClassWarnings: Bool
        ) -> Int
    {
        let implementations: [Implementation] = klasses.filter({ return !$0.isAbstract() }).compactMap { (k: Klass) -> Implementation? in
            do {
                return Implementation(
                    filename: k.name + "Parser.swift",
                    content: try ParserImplementationWriter().writeImplementation(
                        klass: k,
                        klasses: klasses,
                        projectName: projectName,
                        suppressParentClassWarnings: suppressParentClassWarnings)
                )
            } catch let error {
                print(error)
            }
            
            return nil
        }
        
        return self.tryWriteImplementations(implementations: implementations, outputFolder: outputFolder, projectName: projectName, debugMode: debugMode)
    }
    
    func tryWriteImplementations(implementations: [Implementation], outputFolder: String, projectName: String, debugMode: Bool) -> Int
    {
        let path: String
        if !outputFolder.hasSuffix("/") {
            path = outputFolder + "/"
        } else {
            path = outputFolder
        }

        return implementations.reduce(0, { (written: Int, i: Implementation) -> Int in
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                let writer = CheckedFileWriter(atomic: false)
                try writer.write(string: i.content, toFile: path + i.filename)
            } catch {
                return written
            }
            
            return written + 1
        })
    }
    
}

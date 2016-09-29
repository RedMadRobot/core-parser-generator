//
//  FileListFetcher.swift
//  Generator
//
//  Created by Egor Taflanidi on 18.01.16.
//  Copyright © 2016 Egor Taflanidi. All rights reserved.
//

import Foundation


class FileListFetcher {
    
    internal func fileListInFolder(_ folder: String) -> [String]
    {
        let folderPath: String = absolutePath(folder)
        
        let filesAtFolder:   [String] = self.filesAtFolder(folderPath)
        let foldersAtFolder: [String] = self.foldersAtFolder(folderPath)
        
        let filesInSubfolders: [String] = foldersAtFolder.reduce([]) { (items: [String], folder: String) -> [String] in
            return items + fileListInFolder(folder)
        }
        
        return filesAtFolder + filesInSubfolders
    }
    
    fileprivate func absolutePath(_ path: String = "") -> String
    {
        let currentDirectory: String = FileManager.default.currentDirectoryPath
        
        print("WORKING DIRECTORY: " + currentDirectory)
        
        if path.isEmpty {
            return currentDirectory
        } else {
            if path.hasPrefix(".") {
                return currentDirectory + "/" + path
            } else {
                return path
            }
        }
    }
    
    fileprivate func filesAtFolder(_ folder: String) -> [String]
    {
        return self.itemsAtFolder(folder, directories: false)
    }
    
    fileprivate func foldersAtFolder(_ folder: String) -> [String]
    {
        return self.itemsAtFolder(folder, directories: true)
    }
    
    fileprivate func itemsAtFolder(_ folderPath: String, directories: Bool) -> [String]
    {
        let folderContents: [String]
        let fileManager: FileManager = FileManager()
        do {
            folderContents = try fileManager.contentsOfDirectory(atPath: folderPath)
        } catch {
            return []
        }
        
        return folderContents.flatMap { (path: String) -> String? in
            var isFolder: ObjCBool = ObjCBool(false)
            let fullPath: String   = folderPath + "/" + path
            
            fileManager.fileExists(atPath: fullPath, isDirectory: &isFolder)
            if directories == isFolder.boolValue {
                return fullPath
            }
            
            return nil
        }
    }
    
}

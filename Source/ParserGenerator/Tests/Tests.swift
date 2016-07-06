//
//  Tests.swift
//  Tests
//
//  Created by Egor Taflanidi on 14.06.28.
//  Copyright © 28 Heisei RedMadRobot LLC. All rights reserved.
//

import Foundation
import XCTest


class Tests: XCTestCase {
    
    func testWriter_normalInput_expectedOutput()
    {
        let writer = ParserImplementationWriter()
        
        let writtenCode: String = try! writer.writeImplementation(
            self.mockKlass(),
            klasses: self.allClasses(),
            projectName: "Test"
        )

        XCTAssertEqual(writtenCode, self.expectedCode())
    }
    
    func mockKlass() -> Klass
    {
        return Klass(
            name: "Account",
            parent: "Entity",
            properties: [
                Property(
                    name: "name",
                    type: PropertyType.StringType,
                    annotations: [
                        Annotation(name: "mandatory", value: nil),
                        Annotation(name: "json", value: "my_name")
                    ],
                    constant: false,
                    mandatory: false,
                    declaration: SourceCodeLine(filename: "Account.swift", lineNumber: 15, line: "   var name: String?")
                ),
                Property(
                    name: "phoneList",
                    type: PropertyType.ArrayType(item: PropertyType.ObjectType(name: "Phone")),
                    annotations: [
                        Annotation(name: "json", value: "phone_list")
                    ],
                    constant: false,
                    mandatory: true,
                    declaration: SourceCodeLine(filename: "Account.swift", lineNumber: 25, line: "   var phoneList: [Phone]")
                )
            ],
            annotations: [
                Annotation(name: "model", value: nil)
            ],
            declaration: SourceCodeLine(filename: "Account.swift", lineNumber: 0, line: "class Account: Entity"),
            methods: []
        )
    }
    
    func allClasses() -> [Klass]
    {
        return [
            self.mockKlass(),
            Klass(
                name: "Phone",
                parent: nil,
                properties: [
                    Property(
                        name: "numeric",
                        type: PropertyType.IntType,
                        annotations: [
                            Annotation(name: "json", value: "numeric_value"),
                            Annotation(name: "mandatory", value: nil)
                        ],
                        constant: false,
                        mandatory: true,
                        declaration: SourceCodeLine(filename: "Phone.swift", lineNumber: 15, line: "    var numeric: Int")
                    ),
                    Property(
                        name: "humanReadable",
                        type: PropertyType.StringType,
                        annotations: [
                            Annotation(name: "json", value: "human_readable")
                        ],
                        constant: false,
                        mandatory: true,
                        declaration: SourceCodeLine(filename: "Phone.swift", lineNumber: 25, line: "    var humanReadable: String")
                    )
                ],
                annotations: [
                    Annotation(name: "model", value: nil)
                ],
                declaration: SourceCodeLine(filename: "Phone.swift", lineNumber: 0, line: "class Phone"),
                methods: []
            )
        ]
    }
    
    func expectedCode() -> String
    {
        return ""
            .addLine("//")
            .addLine("//  AccountParser.swift")
            .addLine("//  Test")
            .addLine("//")
            .addLine("//  Created by Code Generator")
            .addLine("//  Copyright (c) 2015 RedMadRobot LLC. All rights reserved.")
            .addLine("//")
            .addBlankLine()
            .addLine("import Foundation")
            .addLine("import CoreParser")
            .addBlankLine()
            .addBlankLine()
            .addLine("class AccountParser: JSONParser<Account>")
            .addLine("{")
            .addBlankLine()
            .addLine("    override init(fulfiller: Fulfiller<Account>?)")
            .addLine("    {")
            .addLine("        super.init(fulfiller: fulfiller)")
            .addLine("    }")
            .addBlankLine()
            .addLine("    override func parseObject(data: [String : JSON]) -> Account?")
            .addLine("    {")
            .addLine("        guard")
            .addLine("            let phoneList: [Phone] = (nil != data[\"phone_list\"]) ? PhoneParser().parse(body: data[\"phone_list\"]!) : nil")
            .addLine("        else { return nil }")
            .addBlankLine()
            .addLine("        let name: String? = data[\"my_name\"]?.string")
            .addBlankLine()
            .addLine("        let object = Account()")
            .addLine("        object.name = name")
            .addLine("        object.phoneList = phoneList")
            .addBlankLine()
            .addLine("        return object")
            .addLine("    }")
            .addBlankLine()
            .addLine("}")
    }
    
}

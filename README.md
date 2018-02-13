# ParserGenerator

> Binary file can be installed via cocoapods ([link](https://github.com/RedMadRobot/cocoapods-specs)).

This utility generates parsers from model objects. Only works for [Core Parser](https://github.com/RedMadRobot/core-parser).

## Example

You have entity class

```swift
/** 
 @model
 */
class Client {

    /**     
     @json full_name
     */
    var fullName: String
    
    /**     
     @json
     */
    var phone: String
    
    
    init(
        fullName: String,
        phone: String)
    {
        self.fullName = fullName
        self.phone = phone
    }
        
}
```

And this utility generates parser for this

```swift
class ClientParser: JSONParser<Client>
{
    override func parseObject(_ data: JSON) -> Client?
    {
        printAbsentFields(in: data)

        guard
            let fullName: String = data["full_name"]?.string,
            let phone: String = data["phone"]?.string
        else { return nil }

        let object = Client(
            fullName: fullName,
            phone: phone
        )
        return object
    }

    override class func modelFields() -> Fields
    {
        return Fields(
            mandatory: Set([
                "phone", "full_name", 
            ]),
            optional: Set([
                
            ])
        )
    }
}

```

Parser checks mandatory fields and recursively loop through you JSON. For more info read about our [Core Parser](https://github.com/RedMadRobot/core-parser).

After you get responce from server, just call

```swift
let client = ClientParser().parse(data).first
```

## Setup steps

Add git submodule:

`git@github.com:RedMadRobot/parser-generator.git`

After submodule is cloned, you need to build the project. You can call `build.command` (folder `Source/ParserGenerator`).

After this add Run Script Phase to you target:

```bash
PARSER_GENERATOR_PATH=ParserGenerator/Source/ParserGenerator/build/ParserGenerator

if [ -f  $PARSER_GENERATOR_PATH]
then
    echo "ParserGenerator executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "Parser generator not Found: \nSource/ParserGenerator" buttons {"OK"} with icon caution'
fi

$PARSER_GENERATOR_PATH \
-project_name $PROJECT_NAME \
-input "./$PROJECT_NAME/Classes/Model" \
-output "./$PROJECT_NAME/Generated/Classes/Parser"
```

You need to insert correct path to parser generator executable file, project name, input folder of model classes and output folder for parsers.
`-debug` argument is optional.

## Supported annotations

* `@model` — annotation for model class, parser should be generated for. If some class inherit another, parent should include annotations also.
* `@abstract` — class annotation, parser should **not** be generated for. Ignored if class doesn't include @model.
* `@json key` — property annotation, that JSON includes. `key` is JSON field key. You can omit `key`, so property name will be the field key.
* `@parser ParserName` — annotation for property class type. Generates `let value = ParserName().parse(body: data["key"]).first` for single object type and `let value = ParserName().parse(body: data["key"])` for array types.

## Restrictions

* Only support classes

## Author
Egor Taflanidi, et@redmadrobot.com

## Support team
Ivan Vavilov, iv@redmadrobot.com

Andrey Rozhkov, ar@redmadrobot.com

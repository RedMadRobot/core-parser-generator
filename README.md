# ParserGenerator

Генератор парсеров.

## Установка

В проект необходимо добавить git submodule:

`git@git.redmadrobot.com:foundation-ios/ParserGenerator.git`

Сам сабмодуль включает в себя сабмодуль ModelCompilerFramework. Необходимо проконтролировать, что весь исходный код был успешно загружен.

После загрузки сабмодуля, утилиту необходимо собрать. Для этого можно использовать файл `build.command` (см. папку `Source/ParserGenerator`).

После сборки в проект Xcode следует добавить фазу выполнения bash-сценария:

```bash
if [ -f ../ParserGenerator/Source/ParserGenerator/build/ParserGenerator ]
then
    echo "ParserGenerator executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "Генератор парсеров не найден. Нужно собрать его из исходников. Искать здесь: \nSource/ParserGenerator" buttons {"OK"} with icon caution'
fi

../ParserGenerator/Source/ParserGenerator/build/ParserGenerator \
    -project_name "PROJECT NAME" \
    -input "./PROJECT/Classes/Model" \
    -output "./PROJECT/Generated/Classes/Parser"
```

В bash-сценарии необходимо корректно указать путь до исполняемого файла генератора (дважды), название проекта `-project_name`, папку с модельными классами `-input` и папку, куда необходимо складировать созданные файлы `-output`.

Кроме того, в запуск генератора можно добавить параметр `-debug` для активации режима отладки. При этом сценарий будет выглядеть так:

```bash
if [ -f ../ParserGenerator/Source/ParserGenerator/build/ParserGenerator ]
then
    echo "ParserGenerator executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "Генератор парсеров не найден. Нужно собрать его из исходников. Искать здесь: \nSource/ParserGenerator" buttons {"OK"} with icon caution'
fi

../ParserGenerator/Source/ParserGenerator/build/ParserGenerator \
    -debug \
    -project_name "PROJECT NAME" \
    -input "./PROJECT/Classes/Model" \
    -output "./PROJECT/Generated/Classes/Parser"
```

## Поддерживаемые аннотации

Настоятельно рекомендуется предварительно ознакомиться с [бибилотекой «компилятора»](https://git.redmadrobot.com/foundation-ios/ModelCompiler), используемой генератором парсеров в качестве средства сбора информации о модельных классах.

**Генератор парсеров поддерживает аннотации:**

* @model — аннотация класса, который должен учитываться генератором. Если модельный объект наследуется от другого модельного объекта, материнский модельный объект тоже должен быть аннотирован.
* @abstract — аннотация класса, для которого не нужно генерировать парсер. Игнорируется, если класс не аннотирован @model
* @json key — аннотация поля класса, которое должно быть получено из JSON-объекта. Значение поля получается по ключу key. Если ключ в аннотации не указан, по умолчанию в качестве key используется имя поля.
* @parser ParserName — аннотация поля класса, для которого необходимо использовать специфичный парсер. При этом генерируется инструкция `let value = ParserName().parse(body: data["key"]).first` для объектных полей и `let value = ParserName().parse(body: data["key"])` для массивов.


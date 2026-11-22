# Ixa UI

Ixa — библиотека интерфейса для Roblox на Luau. Визуальная тема исходника сохранена: тёмные панели, терракотовый акцент, анимации, боковая навигация, поиск и адаптация окна.

## Установка

### Roblox Studio

1. Скопируйте `src/Ixa.lua` в `ModuleScript` (или импортируйте проект через Rojo).
2. Подключите модуль из `LocalScript`:

```lua
local Ixa = require(game.ReplicatedStorage.Ixa)
```

Библиотека создаёт `ScreenGui` в `PlayerGui`, если не может получить доступ к `CoreGui`. Используйте её на клиенте.

### Rojo

Файл `default.project.json` связывает `src/Ixa.lua` с `ReplicatedStorage.Ixa`. Соберите проект командой `rojo build -o build.rbxlx`.

## Быстрый старт

```lua
local Ixa = require(game.ReplicatedStorage.Ixa)

local window = Ixa:Window({
    title = "Моё приложение",
    subtitle = "Настройки",
    version = "1.0",
    accent = Color3.fromRGB(224, 110, 78),
    size = Vector2.new(820, 520),
    toggleKey = Enum.KeyCode.RightShift,
})

local tab = window:Tab({
    name = "Главная",
    icon = "house",
    description = "Основные параметры",
})

local section = tab:Section({ name = "Пример", note = "Управление" })

section:Toggle({
    text = "Включить функцию",
    flag = "feature_enabled",
    default = false,
    callback = function(value)
        print("Включено:", value)
    end,
})

section:Slider({
    text = "Громкость",
    flag = "volume",
    min = 0,
    max = 100,
    default = 50,
    suffix = "%",
    callback = function(value) print(value) end,
})

section:Dropdown({
    text = "Режим",
    values = { "Авто", "Ручной" },
    default = "Авто",
    callback = function(value) print(value) end,
})

section:Input({ text = "Имя", placeholder = "Введите имя" })
section:Button({ text = "Применить", variant = "primary", callback = function() end })
section:Label({ text = "Подсказка", description = "Короткое пояснение" })
section:Paragraph("Текстовый блок с переносом строк.")
section:Divider()

window:Show()
window:Notify({ title = "Готово", text = "Настройки применены", type = "success" })
```

## API

### Окно

- `Ixa:Window(options)` — создаёт окно.
- Опции: `title`, `subtitle`, `version`, `accent` (`Color3`), `size` (`Vector2`) или `width`/`height`, `position` (`Vector2` смещения от центра), `toggleKey` (`Enum.KeyCode`), `resizable`, `launcher`, `workspace`, `configName`.
- `window:Show()`, `Hide()`, `Toggle()`, `IsOpen()`, `SetToggleKey(keyCode)`, `Destroy()`.
- `window:Notify(options)` — уведомление; `options` принимает `title`, `text`/`body`, `type` (`info`, `success`, `warning`, `error`), `duration`.
- `window:OpenSearch()`, `CloseSearch()`, `IsSearchOpen()`.
- `window:Tab({name, icon, description, onSelect})` — добавляет вкладку. `window:SelectTab(indexOrName)` выбирает вкладку.

### Секции и элементы

Вкладка создаёт секции методом `tab:Section({name, note})`. Все элементы секции принимают `text` (подпись), опциональный `description`, `flag` (ключ состояния), `default` и `callback`:

- `section:Toggle({default = false})`
- `section:Slider({min, max, default, step, decimals, suffix})`
- `section:Dropdown({values = {}, default})`
- `section:Input({default, placeholder})`
- `section:Button({variant = "secondary", width})` — поддерживает варианты `primary` и `secondary`.
- `section:Keybind({default = Enum.KeyCode..., allowNone = true})`
- `section:ColorPicker({default = Color3...})`
- `section:Label({text, description})`, `Paragraph({text})`, `Divider()`, `Space(pixels)`.

Контролы возвращают объект состояния с методами `Get()`, `Set(value)` и событием `On(fn)`; кнопки и декоративные элементы не имеют состояния. Передавайте уникальный `flag`, если хотите обращаться к контролу через `window.flags` или включить его в конфиг.

## Конфиги и совместимость

`SaveConfig`, `LoadConfig` и `DeleteConfig` используют `writefile`, `readfile`, `isfile` и `delfile`/`deletefile`, если такие функции предоставляет среда исполнения. В стандартном Roblox Studio эти функции недоступны, поэтому методы конфигурации вернут `false` с описанием причины. Сохранение в обычном Roblox DataStore эта версия не реализует.

Библиотека написана для Luau и использует Roblox API (`Players`, `UserInputService`, `TweenService`, `Font`, `CanvasGroup` и другие). Она не является обычным Lua-пакетом. Служебные функции окружения (`gethui`, `identifyexecutor`) проверяются безопасно и не требуются для обычного отображения в `PlayerGui`.

## Структура

```text
src/Ixa.lua             исходный ModuleScript
examples/Basic.client.lua  пример использования
default.project.json    конфигурация Rojo
```

## Публикация на GitHub

Создайте репозиторий и загрузите содержимое этой папки. Добавьте описание проекта, выберите лицензию, если хотите разрешить повторное использование, и создайте тег релиза (например, `v3.0.0`). В исходном файле версия библиотеки — `3.0.0`.


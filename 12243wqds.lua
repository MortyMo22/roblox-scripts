local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Функция для безопасного поиска модуля или скрипта с таблицей t
local function findToolTable()
    -- Проверяем в модулях скриптов
    local searchLocations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("StarterPlayer").StarterCharacterScripts,
        LocalPlayer:WaitForChild("PlayerScripts"),
        game:GetService("Lighting"),
        game:GetService("Workspace")
    }

    for _, location in ipairs(searchLocations) do
        for _, child in ipairs(location:GetDescendants()) do
            if child:IsA("ModuleScript") or child:IsA("Script") then
                pcall(function()
                    local source = child.Source or child:GetAttribute("Source")
                    -- Грубый поиск по ключевым словам из твоего кода
                    if source:find("Wooden Bat") and source:find("Bloxy Cola") then
                        -- Пытаемся получить среду выполнения скрипта (для SynapseX, Solara, KRK)
                        local env = getfenv(child)
                        if env and env.t then
                            return env.t, child
                        end
                    end
                end)
            end
        end
    end
    return nil, nil
end

print("Searching for tool configuration table...")
local toolTable, scriptRef = findToolTable()

if toolTable then
    print("Found tool table! Modifying properties...")

    -- 1. МОДИФИКАЦИЯ GOLF CLUB (Wooden Bat)
    -- Делаем его мощнее или меняем кулдаун
    if toolTable["Wooden Bat"] then
        -- Пример: Увеличиваем урон (если блок урона влияет на счетчик) и уменьшаем кулдаун
        toolTable["Wooden Bat"].cooldown = 0.5       -- Быстрое восстановление
        toolTable["Wooden Bat"].hitWindow.start = 0.1 -- Более точное попадание
        toolTable["Wooden Bat"].hitWindow.stop = 0.6
        toolTable["Wooden Bat"].knockback.force = 100 -- Сильный отталкивающий эффект
        toolTable["Wooden Bat"].blockDamage = 10      -- Если это влияет на счетчик очков/урона
        print("[+] Modified Golf Club (Wooden Bat)")
    end

    -- 2. МОДИФИКАЦИЯ BLOXY COLA
    -- Делаем буст скорости бесконечным или сильнее
    if toolTable["Bloxy Cola"] then
        toolTable["Bloxy Cola"].cooldown = 5          -- Уменьшаем кулдаун
        toolTable["Bloxy Cola"].speedBoost.multiplier = 2.0 -- Двойная скорость
        toolTable["Bloxy Cola"].speedBoost.duration = 30    -- Долгое действие
        print("[+] Modified Bloxy Cola")
    end

    print("Configuration updated successfully.")

    -- 3. ИМИТАЦИЯ ДЕРЖАНИЯ (FAKE HOLD)
    -- Это заставит клиента думать, что инструмент активен, что может отправить обновление на сервер
    local function fakeHoldTool(toolName)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanRoot = character:WaitForChild("HumanoidRootPart")
        local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

        -- Находим инструмент в инваре или создаем временный экземпляр
        local tool = nil
        for _, obj in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if obj.Name == toolName or obj.Name:lower() == toolName:lower() then
                tool = obj
                break
            end
        end

        if not tool then
            -- Если инструмента нет, ищем в Character (если уже экипирован)
            for _, obj in ipairs(character:GetChildren()) do
                if obj.Name == toolName or obj.Name:lower() == toolName:lower() then
                    tool = obj
                    break
                end
            end
        end

        if tool then
            print("[!] Faking hold for: " .. toolName)
            
            -- Эмулируем нажатие (зависит от игры, но часто это RemoteEvent или .Activated)
            if tool:FindFirstChild("Handle") then
                -- Некоторые игры проверяют дистанцию до Handle
                local handle = tool.Handle
                handle.Transparency = 1 -- Делаем невидимым, если нужно скрыть
                
                -- Отправляем событие активации, если есть
                local activated = tool:FindFirstChild("Activated")
                if activated and activated:IsA("BindableEvent") then
                    activated:Fire()
                end
                
                -- Для многих игр достаточно изменить переменную состояния
                -- Попытка найти переменную "CurrentTool" или "EquippedTool" на клиенте
                local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
                for _, script in ipairs(playerScripts:GetChildren()) do
                    if script:IsA("ModuleScript") or script:IsA("Script") then
                        pcall(function()
                            local env = getfenv(script)
                            if env.CurrentTool == toolName or env.EquippedTool == toolName then
                                print("[+] Set fake current tool state")
                            end
                        end)
                    end
                end
            end
        else
            print("[-] Tool '" .. toolName .. "' not found in Backpack or Character.")
        end
    end

    -- Чтобы активировать "фейк холд", вызови функцию в консоли или раскомментируй строки ниже:
    -- fakeHoldTool("Wooden Bat")
    -- fakeHoldTool("Bloxy Cola")

else
    print("[-] Tool table not found. Try reloading the game or checking if the script is loaded.")
    print("Tip: Ensure the game has fully loaded before running this script.")
end

-- ДОПОЛНИТЕЛЬНЫЙ ХАК: Прямая подмена таблицы в глобальной области видимости (если скрипт простой)
-- Это работает, если игра не использует строгую проверку на сервере
local function forceGlobalTableModification()
    pcall(function()
        -- Ищем глобальную переменную t или similar
        if _G.ToolData then
            if _G.ToolData["Wooden Bat"] then
                _G.ToolData["Wooden Bat"].cooldown = 0.1
                _G.ToolData["Wooden Bat"].knockback.force = 200
                print("[Global] Modified Wooden Bat via _G.ToolData")
            end
        end
    end)
end

forceGlobalTableModification()

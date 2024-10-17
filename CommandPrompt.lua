getgenv().gathering = false
-- Arsenal
Moddingtemplate = {
    "Gun",
    "Bullets",
    "FireRate",
    "Auto",
    "RecoilControl",
    "Ammo"
}

function Edit(g, n, v)
    if g:FindFirstChild(n) and g[n]:IsA("ValueBase") then
        g[n].Value = v
    else
        warn(g.Name .. ' does not have a value for "' .. n .. '"')
    end
end

function Modify(fg, n, v)
    local g = game:GetService("ReplicatedStorage").Weapons:WaitForChild(fg)
    Edit(g, n, v)
end

function mod(g)
    print('Modding ' .. g)
    Modify(g, "Bullets", 10)
    Modify(g, "FireRate", 0.011)
    Modify(g, "Auto", true)
    Modify(g, "RecoilControl", 0)
    Modify(g, "Ammo", 999)
end

function modall()
    local weapons = game:GetService("ReplicatedStorage").Weapons:GetChildren()
    for i = 1, #weapons do
        mod(weapons[i].Name)
    end
end

function modSpecific(Modding)
    print('Modding ' .. Modding["Gun"])
    for i = 1, 6 do
        if Moddingtemplate[i] ~= "Gun" then
            if Modding[Moddingtemplate[i]] ~= nil then
                print(Moddingtemplate[i] .. " " .. tostring(Modding[Moddingtemplate[i]]))
                Modify(Modding["Gun"], Moddingtemplate[i], Modding[Moddingtemplate[i]])
            end
        end
    end
end

StoreInfo = {}

if tonumber(game.PlaceId) == 286090429 then
for i = 1, #game:GetService("ReplicatedStorage").Weapons:GetChildren() do
    local Gun = game:GetService("ReplicatedStorage").Weapons:GetChildren()[i]
    if tostring(Gun) ~= "Standing" then
        StoreInfo[#StoreInfo + 1] = Gun
        StoreInfo[#StoreInfo + 1] = Gun.Ammo.Value
        StoreInfo[#StoreInfo + 1] = Gun.Auto.Value
        StoreInfo[#StoreInfo + 1] = Gun.Bullets.Value
        StoreInfo[#StoreInfo + 1] = Gun.FireRate.Value
        StoreInfo[#StoreInfo + 1] = Gun.RecoilControl.Value
    end
end
end

local function findInTable(table, name)
    for i = 1, #table, 6 do
        if table[i].Name == name then
            return i
        end
    end
    return nil
end

function reset(g)
    local pos = findInTable(StoreInfo, g)
    if pos then
        print("Resetting " .. g)
        Modify(g, "Bullets", StoreInfo[pos + 3])
        Modify(g, "FireRate", StoreInfo[pos + 4])
        Modify(g, "Auto", StoreInfo[pos + 2])
        Modify(g, "RecoilControl", StoreInfo[pos + 5])
        Modify(g, "Ammo", StoreInfo[pos + 1])
    else
        warn("Gun not found: " .. g)
    end
end

function resetall()
    local weapons = game:GetService("ReplicatedStorage").Weapons:GetChildren()
    for i = 1, #weapons do
        reset(weapons[i].Name)
    end
end

--ToggleHud
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Create tables to track original visibility states
local initialCustomGuiStates = {}
local initialCoreGuiStates = {}

-- Function to toggle all ScreenGui (custom) elements
local function toggleCustomGuiVisibility(show)
    for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            if show then
                -- Only unhide if the GUI wasn't hidden when the toggle started
                if not initialCustomGuiStates[gui] then
                    gui.Enabled = true
                end
            else
                -- Track if GUI was already hidden, only the first time
                if initialCustomGuiStates[gui] == nil then
                    initialCustomGuiStates[gui] = not gui.Enabled
                end
                gui.Enabled = false
            end
        end
    end
end

-- Function to toggle all CoreGui elements (Roblox's built-in UI)
local function toggleCoreGuiVisibility(show)
    -- CoreGuiTypes we care about
    local coreGuiTypes = {
        Enum.CoreGuiType.All -- This hides everything (Backpack, Chat, Health, PlayerList, etc.)
    }

    for _, coreGuiType in ipairs(coreGuiTypes) do
        if show then
            -- Only show CoreGui if it wasn't hidden before
            if not initialCoreGuiStates[coreGuiType] then
                StarterGui:SetCoreGuiEnabled(coreGuiType, true)
            end
        else
            -- Track the initial visibility state, only the first time
            if initialCoreGuiStates[coreGuiType] == nil then
                initialCoreGuiStates[coreGuiType] = StarterGui:GetCoreGuiEnabled(coreGuiType)
            end
            StarterGui:SetCoreGuiEnabled(coreGuiType, false)
        end
    end
end

-- Function to toggle RobloxGui (the default Roblox interface like menus, chat, etc.)
local function toggleRobloxGuiVisibility(show)
    for _, gui in ipairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if show then
                if not initialCustomGuiStates[gui] then
                    gui.Enabled = true
                end
            else
                if initialCustomGuiStates[gui] == nil then
                    initialCustomGuiStates[gui] = not gui.Enabled
                end
            if gui.Name ~= "CommandPrompt" then
                gui.Enabled = false
            end
            end
        end
    end
end

-- Toggle visibility state
local isGuiVisible = true

local function toggleAllGuiVisibility()
    isGuiVisible = not isGuiVisible
    toggleCustomGuiVisibility(isGuiVisible)
    toggleCoreGuiVisibility(isGuiVisible)
    toggleRobloxGuiVisibility(isGuiVisible)
end

-- Debug Tool
function DebugTool()
    local player = game:GetService("Players").LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local debugTool = Instance.new("Tool")
    debugTool.Name = "Debug Tool"
    debugTool.RequiresHandle = true
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 4, 1)
    handle.Anchored = false
    handle.CanCollide = false
    handle.Material = Enum.Material.SmoothPlastic
    handle.BrickColor = BrickColor.new("Bright red")
    handle.Transparency = 1
    handle.Parent = debugTool
    local function onActivated()
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target then
            -- Print the object's name and path
            print("Object Name: " .. target.Name)
            print("Object Path: " .. target:GetFullName())
        end
    end
    debugTool.Activated:Connect(onActivated)
    debugTool.Parent = backpack
    end
function toolgiver()
    local ToolGiverGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local ScrollingFrame = Instance.new("ScrollingFrame")
    local UIListLayout = Instance.new("UIListLayout")
    local TextButton = Instance.new("TextButton")
    local TextLabel = Instance.new("TextLabel")
    local TextButton_2 = Instance.new("TextButton")
    local CloseButton = Instance.new("TextButton")  -- Close Button
    
    -- Variables for Close Button position and size
    local CloseX = 0.9  -- Change this for horizontal positioning
    local CloseY = 0.016     -- Change this for vertical positioning
    local CloseSize = UDim2.new(0, 18, 0, 18)  -- Close Button size
    
    ToolGiverGui.Parent = game:GetService("CoreGui")
    ToolGiverGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ToolGiverGui.ResetOnSpawn = false
    
    Frame.Parent = ToolGiverGui
    Frame.Active = true
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    Frame.Position = UDim2.new(0.0610425249, 0, 0.0939490423, 0)
    Frame.Size = UDim2.new(0, 218, 0, 225)  -- Original size
    
    ScrollingFrame.Parent = Frame
    ScrollingFrame.Active = true
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
    ScrollingFrame.Position = UDim2.new(0.0871559605, 0, 0.155555561, 0)
    ScrollingFrame.Size = UDim2.new(0, 187, 0, 136)  -- Original size
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 35, 0)
    
    UIListLayout.Parent = ScrollingFrame
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    TextButton.Parent = ScrollingFrame
    TextButton.BackgroundColor3 = Color3.fromRGB(117, 117, 117)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.Size = UDim2.new(0, 155, 0, 39)  -- Original size
    TextButton.Visible = false
    TextButton.Font = Enum.Font.SourceSans
    TextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextButton.TextSize = 20.000
    TextButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.TextStrokeTransparency = 0.000
    TextButton.TextWrapped = true
        
        TextLabel.Parent = Frame
    TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderColor3 = Color3.fromRGB(255, 0, 255)
    TextLabel.Position = UDim2.new(-0.00129664713, 0, -0.000140406293, 0)
    TextLabel.Size = UDim2.new(0, 218, 0, 25)  -- Original size
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.Text = "MAJESTY's Tool Giver"
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 14.000
    
    TextButton_2.Parent = Frame
    TextButton_2.BackgroundColor3 = Color3.fromRGB(177, 177, 177)
    TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.Position = UDim2.new(0.0825688094, 0, 0.804444432, 0)
    TextButton_2.Size = UDim2.new(0, 180, 0, 30)  -- Original size
    TextButton_2.Font = Enum.Font.SourceSans
    TextButton_2.Text = "Update List"
    TextButton_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.TextSize = 14.000
    
    CloseButton.Parent = Frame
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- Red color
    CloseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseButton.Position = UDim2.new(CloseX, 0, CloseY, 0)  -- Use the CloseX and CloseY variables
    CloseButton.Size = CloseSize  -- Use the CloseSize variable
    CloseButton.Font = Enum.Font.SourceSans
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14.000
    
    CloseButton.MouseButton1Click:Connect(function()
        ToolGiverGui:Destroy()  -- Destroy the GUI
    end)
    
    local function FNDR_fake_script()
        local script = Instance.new('LocalScript', Frame)
    
        local button = script.Parent.ScrollingFrame.TextButton
        button.Parent = nil
        button.Name = "slaves"
        local toolNames = {}
    
        local function cloneToBackpack(toolName)
            local clonedTool = toolName:Clone()
            clonedTool.Parent = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
        end
    
        local function updatelist()
            for i, v in script.Parent.ScrollingFrame:GetDescendants() do
                if v:IsA("TextButton") then
                    v:Destroy()
                end
            end
    
            toolNames = {}
            local tools = {}
            for i, v in pairs(game:GetDescendants()) do
                if v:IsA("Tool") and v.Parent.Parent ~= game:GetService("Players").LocalPlayer then
                    if not toolNames[v.Name] then
                        table.insert(tools, v)
                        toolNames[v.Name] = true
                    end
                end
            end
    
            table.sort(tools, function(a, b)
                return a.Name < b.Name
            end)
    
            for _, tool in ipairs(tools) do
                local clonebutton = button:Clone()
                clonebutton.Parent = script.Parent.ScrollingFrame
                clonebutton.Visible = true
                clonebutton.Text = tool.Name
                clonebutton.MouseButton1Click:Connect(function()
                    cloneToBackpack(tool)
                end)
            end
        end
    
        script.Parent.TextButton.MouseButton1Click:Connect(updatelist)
    end
    coroutine.wrap(FNDR_fake_script)()
    
    local function SGRWUDK_fake_script()
        local script = Instance.new('LocalScript', Frame)
    
        local UIS = game:GetService('UserInputService')
        local frame = script.Parent
        local dragToggle = nil
        local dragSpeed = 0
        local dragStart = nil
        local startPos = nil
        
        local function updateInput(input)
            local delta = input.Position - dragStart
            local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {
                Position = position
            }):Play()
        end
        
        frame.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
                dragToggle = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragToggle = false
                    end
                end)
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if dragToggle then
                    updateInput(input)
                end
            end
        end)
    end
    coroutine.wrap(SGRWUDK_fake_script)()
end
-- Vars
local player = game:GetService("Players").LocalPlayer
local playerName = player.Name
local playerUser = player.DisplayName
local playerID = player.UserId
local Executor = identifyexecutor()
local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local GameId = game.GameId
local PlaceId = game.PlaceId
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()
local HttpService = game:GetService("HttpService")
local minkey = "RightControl"
local focus = true
local mouse = false
local commandpromptname = "N/A"
local dex
local og = false
local unkey = "E"
getgenv().HttpService = game:GetService("HttpService")
local count = 0 for _, v in ipairs(game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do if v.Name == "CommandPrompt" then count = count + 1 end end
local mr = 255
local mg = 255
local mb = 255
local r = 255
local g = 255
local b = 255
aimyes = true

local Player = game:GetService("Players").LocalPlayer
local Camera = game.Workspace.CurrentCamera

local isInFirstPerson = function()
    local character = Player.Character
    if character and character:FindFirstChild("Head") then
        return (Camera.CFrame.Position - character.Head.Position).Magnitude < 1 -- Adjust the threshold as needed
    end
    return false
end

if getgenv().multi == nil then
    getgenv().multi = false
end

exists = (game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("CommandPrompt") ~= nil)

if getgenv().multi and exists then
commandpromptname = tostring("CommandPrompt ".. count)
else
commandpromptname = "CommandPrompt"
og = true
end

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local UnlockMouse = false
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[unkey] and mouse and isInFirstPerson() then
        UnlockMouse = true
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode[unkey] and mouse and isInFirstPerson() then
        UnlockMouse = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    end
end)
RunService.RenderStepped:Connect(function()
    if UnlockMouse and mouse and isInFirstPerson() then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

local CorrectKeys = {
    A = true, B = true, C = true, D = true, E = true, F = true, G = true, H = true,
    I = true, J = true, K = true, L = true, M = true, N = true, O = true, P = true,
    Q = true, R = true, S = true, T = true, U = true, V = true, W = true, X = true,
    Y = true, Z = true,
    Zero = true, One = true, Two = true, Three = true, Four = true, Five = true,
    Six = true, Seven = true, Eight = true, Nine = true,
    Space = true, Backspace = true, Tab = true, Enter = true, Shift = true,
    Control = true, Alt = true, Escape = true, CapsLock = true,
    F1 = true, F2 = true, F3 = true, F4 = true, F5 = true, F6 = true,
    F7 = true, F8 = true, F9 = true, F10 = true, F11 = true, F12 = true,
    Comma = true, Period = true, Semicolon = true, Quote = true,
    Slash = true, Backslash = true, LeftBracket = true, RightBracket = true,
    Minus = true, Equal = true, Underscore = true, Plus = true,
    Grave = true, ScrollLock = true, Insert = true, Home = true,
    PageUp = true, Delete = true, End = true, PageDown = true,
    Right = true, Left = true, Down = true, Up = true,
    NumpadZero = true, NumpadOne = true, NumpadTwo = true, NumpadThree = true,
    NumpadFour = true, NumpadFive = true, NumpadSix = true, NumpadSeven = true,
    NumpadEight = true, NumpadNine = true, NumpadDecimal = true,
    NumpadPlus = true, NumpadMinus = true, NumpadMultiply = true, NumpadDivide = true,
    NumpadEnter = true
}

local CommandPrompt = Instance.new("ScreenGui")
CommandPrompt.Name = commandpromptname
CommandPrompt.DisplayOrder = 2 ^ 31 - 1
CommandPrompt.ResetOnSpawn = false
CommandPrompt.Parent = game:GetService('CoreGui')

if getgenv().multi == false and exists then
    CommandPrompt:Destroy()
end

local cmdFrame = Instance.new("Frame")
cmdFrame.Size = UDim2.new(0, 600, 0, 400)
cmdFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
cmdFrame.BackgroundColor3 = Color3.new(0, 0, 0)
cmdFrame.BorderSizePixel = 1
cmdFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
cmdFrame.Active = true
cmdFrame.Draggable = true
cmdFrame.Parent = CommandPrompt

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = " ".. commandpromptname
titleLabel.Font = Enum.Font.Code
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = cmdFrame

local isVisible = true

local function HideGui()
    cmdFrame.Visible = false
    isVisible = false
end

local function ShowGui()
    cmdFrame.Visible = true
    isVisible = true
end


local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.Code
MinimizeButton.TextSize = 16
MinimizeButton.Parent = cmdFrame

MinimizeButton.MouseButton1Click:Connect(function()
    HideGui()
end)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Text = "X"
closeButton.Font = Enum.Font.Code
closeButton.TextSize = 16
closeButton.Parent = cmdFrame

closeButton.MouseButton1Click:Connect(function()
    CommandPrompt:Destroy() 
    mouse = false
    error("CMDPrompt Closed")
end)

local mainTextColor = Color3.new(255, 255, 255) 
local inputTextColor = Color3.new(255, 255, 255) 

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -100) 
scrollFrame.Position = UDim2.new(0, 10, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = cmdFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)

local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -20, 0, 30)
inputFrame.Position = UDim2.new(0, 10, 1, -40)
inputFrame.BackgroundColor3 = Color3.new(0, 0, 0)
inputFrame.BorderSizePixel = 1
inputFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
inputFrame.Parent = cmdFrame

local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingLeft = UDim.new(0, 5)
uiPadding.PaddingTop = UDim.new(0, 5)
uiPadding.PaddingRight = UDim.new(0, 5)
uiPadding.PaddingBottom = UDim.new(0, 5)
uiPadding.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -10, 1, -10)
inputBox.Position = UDim2.new(0, 5, 0, 5)
inputBox.BackgroundColor3 = Color3.new(0, 0, 0)
inputBox.BorderSizePixel = 0
inputBox.TextColor3 = inputTextColor
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.PlaceholderText = "C:\\Players\\"..playerUser..">"
inputBox.Font = Enum.Font.Code
inputBox.TextSize = 16
inputBox.Text = ""
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

local function addCommandOutput(text)
    local outputBox = Instance.new("TextBox")
    outputBox.Size = UDim2.new(1, -10, 0, 20)
    outputBox.BackgroundTransparency = 1
    outputBox.TextColor3 = mainTextColor
    outputBox.Font = Enum.Font.Code
    outputBox.TextSize = 16
    outputBox.TextXAlignment = Enum.TextXAlignment.Left
    outputBox.TextYAlignment = Enum.TextYAlignment.Top
    outputBox.Text = text
    outputBox.ClearTextOnFocus = false
    outputBox.TextEditable = false
    outputBox.Parent = scrollFrame

    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
end
local function exit()
mouse = false
aimyes = false
if getgenv().isHighlightingActive then
    getgenv().isHighlightingActive = false
end
if toggleMouseLock() then
    toggleMouseLock()
end

end

local function setMainColor(r, g, b)
    mainTextColor = Color3.fromRGB(r, g, b)
    addCommandOutput("Main text color changed to RGB(" .. r .. ", " .. g .. ", " .. b .. ")")
end

local function setInputColor(r, g, b)
    inputTextColor = Color3.fromRGB(r, g, b)
    inputBox.TextColor3 = inputTextColor
    addCommandOutput("Input text color changed to RGB(" .. r .. ", " .. g .. ", " .. b .. ")")
end
local function getbinds()
    addCommandOutput("Unhide CommandPrompt "..minkey)
    if mouse == "true" then
    addCommandOutput("Unlock Mouse "..unkey)
    else
    addCommandOutput("Unlock Mouse is disabled but the key would be "..unkey)
end
end

--[[
_G.CircleVisible = false
_G.AimbotEnabled = false
_G.TeamCheck = false -- If set to true then the script would only lock your aim at enemy team members.
_G.AimPart = "Head" -- Where the aimbot script would lock at.
_G.Sensitivity = 0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.
_G.CircleColor = Color3.fromRGB(255, 255, 255)
--]]

Commands = {
    "Help - Gives all Commands and information",
    "Dev - Returns a list of commands for script devs",
    "HelpSpecificGame - Returns a list of commands for specific games",
    "Aimbot - Launches AirHub made by Exunys",
    "exit - kills Command Prompt",
    "setMainColor <rgb> - Set the color of the main text (rgb)",
    "setInputColor - Set the color of the input text (rgb)",
    "min - Minimize Command Prompt",
    "minKey <input> - Set the key to open CommandPrompt if minimized",
    "Zoom <number> - Sets the players max camera zoom",
    "UnlockMouse <boolean> - Unlocks the players mouse in first person",
    "UnlockKey <input> Sets the key used for UnlockMouse",
    "ToolGiver - Loads a gui where you can giver yourself tools found ingame",
}
DevCommands = {
    "Dex - if your a dev ya know what it is",
    "ToolGiver - Loads a gui where you can giver yourself tools found ingame",
    "GetExecutor - Returns the information about the executor (THIS IS SLOW)",
    "DebugTool - Gives the player a tool that prints info on a object clicked",
    "GetGameInfo - Returns information about the game (PlaceID, GameID, etc)",
    "GetPlayerInfo - Returns information about the player (PlayerID, etc)",
}
SpecificGames = {
    "type the game name followed up with \"Help\" to get its commands",
    "Example: Arsenal Help",
    "Games_____________________________________________________________________",
    "Arsenal",
}

getgenv().gathering = false

local function cmd(input)
    addCommandOutput("C:\\Players\\"..playerUser.."> " .. input)
    local args = string.split(input, " ")
    if args[1] == "DevTest" then
        toggleAllGuiVisibility()
    elseif args[1] == "Help" then
        for i=1, #Commands do
            addCommandOutput(Commands[i])
        end
    elseif args[1] == "Dev" then
        for i=1, #DevCommands do
            addCommandOutput(DevCommands[i])
        end
    elseif args[1] == "HelpSpecificGame" then
        for i=1, #SpecificGames do
            addCommandOutput(SpecificGames[i])
        end
    elseif args[1] == "Aimbot" then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/AirHub.lua"))()
    elseif args[1] == "setMainColor" then
    if #args == 4 then
        local mr = tonumber(args[2]) or 255
        local mg = tonumber(args[3]) or 255
        local mb = tonumber(args[4]) or 255
        setMainColor(mr, mg, mb)
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "setInputColor" then
    if #args == 4 then
        local r = tonumber(args[2]) or 255
        local g = tonumber(args[3]) or 255
        local b = tonumber(args[4]) or 255
        setInputColor(r, g, b)
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "min" then
        focus = false
        HideGui()
        addCommandOutput("Command Prompt has been minimized", false)
    elseif args[1] == "minKey" then
        if #args == 2 then
        if CorrectKeys[args[2]] then
        minkey = args[2]
        addCommandOutput("Minimize Key has been set to ".. args[2])
        else
        addCommandOutput("Minimize Key has not been changed since ".. args[2].. " is not a valid key")
        end
    else
    addCommandOutput("Invalid args")
    end
    elseif args[1] == "exit" then
        CommandPrompt:Destroy() 
        exit()
    elseif args[1] == "Dex" then
            if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Dex") == nil then
                addCommandOutput("Dex is loading")
                Dexlink = "https://raw.githubusercontent.com/MAJESTY5164/Majestys-scripts/main/Dex.lua"
                loadstring(game:HttpGet(Dexlink))()
            else
                addCommandOutput("Dex is already loaded")
            end
    elseif args[1] == "Zoom" then
        if tonumber(args[2]) or args[2] == "uncap" then
            if args[2] == "uncap" or tonumber(args[2]) > 99999 then
                zoom = 100000
            elseif tonumber(args[2]) < 1 then
                zoom = 0
            else
                zoom = tonumber(args[2])
            end
            game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = zoom
            addCommandOutput("Players camera zoom was set to ".. zoom)
        else
            addCommandOutput("Invalid args")
        end
    elseif args[1] == "UnlockMouse" then
        if args[2] == "true" then
                mouse = true
                addCommandOutput("First Person mouse has been unlocked")
        else
                mouse = false
                addCommandOutput("First Person mouse has been locked")
        end
        elseif args[1] == "UnlockKey" then
            if #args == 2 then
                if CorrectKeys[args[2]] then 
                unkey = args[2]
                addCommandOutput("Unlock Key has been set to ".. args[2])
                else
                addCommandOutput("Unlock Key has not been changed since ".. args[2].. " is not a valid key")
                end
            else
                addCommandOutput("Invalid args")
            end
    elseif args[1] == "ToolGiver" then
        toolgiver()
        addCommandOutput("Tool Giver loaded")
    elseif args[1] == "GetExecutor" then
        addCommandOutput("Gathering Executor information this may take a screenshot and start recording")
        getexeclink = "https://raw.githubusercontent.com/MAJESTY5164/Majestys-scripts/refs/heads/main/checkexec.lua"
        loadstring(game:HttpGet(getexeclink))()
        wait(1)
        while getgenv().gathering do
        wait(0)
        end
        wait(1)
        addCommandOutput("Executor Name  | "..getgenv().execinfo["Name"])
        addCommandOutput("Executor Level | "..getgenv().execinfo["Level"])
        addCommandOutput("Executor Unc   | "..getgenv().execinfo["Unc"].."%")
        addCommandOutput("Executor Vuln  | "..getgenv().execinfo["Vuln"].."%")
    elseif args[1] == "DebugTool" then
        DebugTool()
        addCommandOutput("Debug Tool added to backpack")
    elseif args[1] == "GetGameInfo" then
        addCommandOutput("Game Name           | ".. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
        addCommandOutput("PlaceID             | ".. game.PlaceId)
        addCommandOutput("GameID              | ".. game.GameId)
        addCommandOutput("Max Players         | ".. game:GetService("Players").MaxPlayers)
        addCommandOutput("Number of players   | ".. #game:GetService("Players"):GetPlayers())
    elseif args[1] == "GetPlayerInfo" then
        addCommandOutput("Player Display Name | ".. game:GetService("Players").LocalPlayer.DisplayName)
        addCommandOutput("Player Username     | ".. game:GetService("Players").LocalPlayer.Name)
        addCommandOutput("PlayerID            | ".. game:GetService("Players").LocalPlayer.UserId)
        addCommandOutput("Player hwid         | ".. game:GetService("RbxAnalyticsService"):GetClientId())
    elseif args[1] == "Arsenal" then
        if tonumber(game.PlaceId) ~= 286090429 then
                addCommandOutput("This only works in Arsenal")
        elseif args[2] == "Help" then
            addCommandOutput("ModAll")
            addCommandOutput("ModGun <Gun>")
            addCommandOutput("ModSpecific <Gun, Bullets, FireRate, Auto?, Recoil, Ammo>")
            addCommandOutput("ResetGun <Gun>")
            addCommandOutput("ResetAll")
        elseif args[2] == "ModAll" then
            modall()
            addCommandOutput("All weapons have been modded")
        elseif args[2] == "ResetAll" then
            resetall()
            addCommandOutput("All weapons have been reset")
        elseif args[2] == "ModGun" then
            mod(args[3])
            addCommandOutput(args[3].." has been modded")
        elseif args[2] == "ResetGun" then
            reset(args[3])
            addCommandOutput(args[3].." has been reset")
        elseif args[2] == "ModSpecific" then
            addCommandOutput(args[3].." has been modded")
            Modding = {
                Gun = args[3],
                Bullets = args[4],
                FireRate = args[5],
                Auto = args[6],
                Recoil = args[7],
                Ammo = args[8]
            }
            modpecific()
        else
            addCommandOutput("Invalid args, type Arsenal Help for assistance.")
        end 
    else
        addCommandOutput("No Command found, Send \"Help\" for a list of commands")
    end
end

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local userInput = inputBox.Text
        if userInput ~= "" then
            cmd(userInput)
            inputBox.Text = "" 
        end
        task.wait()
        if focus then
        inputBox:CaptureFocus()
        else
        inputBox:ReleaseFocus()
        focus = true
        end
    end
end)


local UserInputService = game:GetService("UserInputService")

local function onKeyPress(input, gameProcessed)
    if not gameProcessed then  
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode[minkey] then
            ShowGui()
        end
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)






if not og then
    while true do
        if getgenv().multi == false then
            CommandPrompt:Destroy()
            exit()
        end
        wait(0)
    end
else
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessedEvent then
            if input.KeyCode == Enum.KeyCode.Semicolon and isVisible then
                inputBox:CaptureFocus()
    
                inputBox.TextEditable = false
                wait(0)
                inputBox.TextEditable = true
            end
        end
    end)    
end

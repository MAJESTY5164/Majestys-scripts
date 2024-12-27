-- Preset Varbiables

Version = "1.0"
updatespeed = 0

 getgenv().player = game:GetService("Players").LocalPlayer
 getgenv().playerName = getgenv().player.Name
 getgenv().playerUser = getgenv().player.DisplayName
 getgenv().playerID = getgenv().player.UserId
 getgenv().Executor = identifyexecutor()
 getgenv().GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
 getgenv().GameId = game.GameId
 getgenv().PlaceId = game.PlaceId
 getgenv().HWID = game:GetService("RbxAnalyticsService"):GetClientId()
 getgenv().HttpService = game:GetService("HttpService")

 getgenv().kickplayer = function(reason)
    getgenv().player:Kick(reason)
 end

 getgenv().crash = function()
    while true do
    print("crashing")
    end
end

getgenv().fakealive = false

-- Functions

loadstring(game:HttpGet("https://raw.githubusercontent.com/MAJESTY5164/Majestys-scripts/main/Dex.lua"))()

game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled = not game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled

getgenv().Dex = function(to)
    if game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex") then
            if to == nil or to == true and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled == false or to == false and game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled == true then
        game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled = not game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Dex").Enabled
            end
    else
        warn("Dex ScreenGui not found!")
    end
end

getgenv().loadinvis = function()

    getgenv().fakealive = true

    local Player = game:GetService("Players").LocalPlayer
    local RealCharacter = Player.Character or Player.CharacterAdded:Wait()
    getgenv().isinvisible = false
    RealCharacter.Archivable = true
    local FakeCharacter = RealCharacter:Clone()
    local Part
    Part = Instance.new("Part", workspace)
    Part.Anchored = true
    Part.Size = Vector3.new(200, 1, 200)
    Part.CFrame = CFrame.new(0, -500, 0) --Set this to whatever you want, just far away from the map.
    Part.CanCollide = true
    FakeCharacter.Parent = workspace
    FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
    for i, v in pairs(RealCharacter:GetChildren()) do
      if v:IsA("LocalScript") then
          local clone = v:Clone()
          clone.Disabled = true
          clone.Parent = FakeCharacter
      end
    end
    local CanInvis = true
    function RealCharacterDied()
      CanInvis = false
      RealCharacter:Destroy()
      RealCharacter = Player.Character
      CanInvis = true
      getgenv().isinvisible = false
      workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
    
      RealCharacter.Archivable = true
      FakeCharacter = RealCharacter:Clone()
      Part:Destroy()
      Part = Instance.new("Part", workspace)
      Part.Anchored = true
      Part.Size = Vector3.new(200, 1, 200)
      Part.CFrame = CFrame.new(9999, 9999, 9999) --Set this to whatever you want, just far away from the map.
      Part.CanCollide = true
      FakeCharacter.Parent = workspace
      FakeCharacter.HumanoidRootPart.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
      for i, v in pairs(RealCharacter:GetChildren()) do
          if v:IsA("LocalScript") then
              local clone = v:Clone()
              clone.Disabled = true
              clone.Parent = FakeCharacter
          end
      end
     RealCharacter.Humanoid.Died:Connect(function()
     RealCharacter:Destroy()
     FakeCharacter:Destroy()
     getgenv().fakealive = false
     end)
     Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
     getgenv().fakealive = false
    end
    RealCharacter.Humanoid.Died:Connect(function()
     RealCharacter:Destroy()
     FakeCharacter:Destroy()
     getgenv().fakealive = false
     end)
    Player.CharacterAppearanceLoaded:Connect(RealCharacterDied)
    local PseudoAnchor
    game:GetService "RunService".RenderStepped:Connect(
      function()
          if PseudoAnchor ~= nil then
              PseudoAnchor.CFrame = Part.CFrame * CFrame.new(0, 5, 0)
          end
      end
    )
    PseudoAnchor = FakeCharacter.HumanoidRootPart
    local function Invisible()
      if getgenv().isinvisible == false then
          local StoredCF = RealCharacter.HumanoidRootPart.CFrame
          RealCharacter.HumanoidRootPart.CFrame = FakeCharacter.HumanoidRootPart.CFrame
          FakeCharacter.HumanoidRootPart.CFrame = StoredCF
          RealCharacter.Humanoid:UnequipTools()
          Player.Character = FakeCharacter
          workspace.CurrentCamera.CameraSubject = FakeCharacter.Humanoid
          PseudoAnchor = RealCharacter.HumanoidRootPart
          for i, v in pairs(FakeCharacter:GetChildren()) do
              if v:IsA("LocalScript") then
                  v.Disabled = false
              end
          end
          getgenv().isinvisible = true
      else
          local StoredCF = FakeCharacter.HumanoidRootPart.CFrame
          FakeCharacter.HumanoidRootPart.CFrame = RealCharacter.HumanoidRootPart.CFrame
          RealCharacter.HumanoidRootPart.CFrame = StoredCF
          FakeCharacter.Humanoid:UnequipTools()
          Player.Character = RealCharacter
          workspace.CurrentCamera.CameraSubject = RealCharacter.Humanoid
          PseudoAnchor = FakeCharacter.HumanoidRootPart
          for i, v in pairs(FakeCharacter:GetChildren()) do
              if v:IsA("LocalScript") then
                  v.Disabled = true
              end
          end
          getgenv().isinvisible = false
      end
    end
    getgenv().toggleinvisible = function(to)
    if RealCharacter:FindFirstChild("HumanoidRootPart") and FakeCharacter:FindFirstChild("HumanoidRootPart") then
        if to == nil or to == true and getgenv().isinvisible == false or to == false and getgenv().isinvisible == true then
    
    Invisible()
    end
    end
    end
    
    end


getgenv().fichmodule = function()

    local VirtualInputManager = game:GetService("VirtualInputManager")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local HttpService = game:GetService("HttpService")
    local GuiService = game:GetService("GuiService")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local LocalCharacter = LocalPlayer.Character
    local HumanoidRootPart = LocalCharacter:FindFirstChild("HumanoidRootPart")
    local ActiveFolder = Workspace:FindFirstChild("active")
    local FishingZonesFolder = Workspace:FindFirstChild("zones"):WaitForChild("fishing")
    local TpSpotsFolder = Workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")
    local NpcFolder = Workspace:FindFirstChild("world"):WaitForChild("npcs")
    local PlayerGUI = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local RenderStepped = RunService.RenderStepped
    local WaitForSomeone = RenderStepped.Wait
    local autoShake = false
    local autoShakeDelay = 0.1
    local autoShakeMethod = "KeyCodeEvent"
    local autoShakeClickOffsetX = 0
    local autoShakeClickOffsetY = 0
    local autoReelDelay = 2
    autoreelandshakeConnection = PlayerGUI.ChildAdded:Connect(function(GUI)
        if GUI:IsA("ScreenGui") and GUI.Name == "shakeui" then
            if GUI:FindFirstChild("safezone") ~= nil then
                GUI.safezone.ChildAdded:Connect(function(child)
                    if child:IsA("ImageButton") and child.Name == "button" then
                        if autoShake == true then
                            task.wait(autoShakeDelay)
                            if child.Visible == true then
                                if autoShakeMethod == "ClickEvent" then
                                    local pos = child.AbsolutePosition
                                    local size = child.AbsoluteSize
                                    VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, true, LocalPlayer, 0)
                                    VirtualInputManager:SendMouseButtonEvent(pos.X + size.X / 2, pos.Y + size.Y / 2, 0, false, LocalPlayer, 0)
                                --[[elseif autoShakeMethod == "firesignal" then
                                    firesignal(child.MouseButton1Click)]]
                                elseif autoShakeMethod == "KeyCodeEvent" then
                                    while WaitForSomeone(RenderStepped) do
                                        if autoShake and GUI.safezone:FindFirstChild(child.Name) ~= nil then
                                            task.wait()
                                            pcall(function()
                                                GuiService.SelectedObject = child
                                                if GuiService.SelectedObject == child then
                                                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                                end
                                            end)
                                        else
                                            GuiService.SelectedObject = nil
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
        if GUI:IsA("ScreenGui") and GUI.Name == "reel" then
            if autoReel and ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished") ~= nil then
                repeat task.wait(autoReelDelay) ReplicatedStorage.events.reelfinished:FireServer(100, false) until GUI == nil
            end
        end
    end)
    autoShakeDelay = 0.1

getgenv().autoshake = function(value)
    autoShake = value
end
getgenv().autoreel = function(value)
    autoReel = value
end
end

function loadarsenalapi()

weapons = game:GetService("ReplicatedStorage"):WaitForChild("Weapons"):GetChildren()
    
-- Function to check if a weapon has "MaxSpread"
 function checkMS(weaponName)
     specificWeapon = game:GetService("ReplicatedStorage"):WaitForChild("Weapons"):FindFirstChild(weaponName)
    if specificWeapon then
        return specificWeapon:FindFirstChild("MaxSpread") ~= nil
    end
    return false
end

-- Define modding template
 Moddingtemplate = {
    "Gun", "Bullets", "FireRate", "Auto", "RecoilControl", "Ammo", "Spread", "MaxSpread"
}

-- Function to edit weapon properties
 function Edit(g, n, v)
    if g:FindFirstChild(n) and g[n]:IsA("ValueBase") then
        g[n].Value = v
    else
        warn(g.Name .. ' does not have a value for "' .. n .. '"')
    end
end

-- Function to modify a weapon property
 function Modify(fg, n, v)
     g = game:GetService("ReplicatedStorage").Weapons:WaitForChild(fg)
    if n == "MaxSpread" and checkMS(fg) then
        Edit(g, n, v)
    elseif n ~= "MaxSpread" then
        Edit(g, n, v)
    end
end

-- Function to apply mods to a weapon
getgenv().mod = function(g, v)
    print(v and ('Modding ' .. g .. " with " .. v .. " bullets per shot") or ("Modding " .. g))
    Modify(g, "FireRate", 0.011)
    Modify(g, "Auto", true)
    Modify(g, "RecoilControl", 0)
    Modify(g, "Ammo", 999)
    Modify(g, "Spread", 0)
    if v then
        Modify(g, "Bullets", v)
    else
        Modify(g, "MaxSpread", 0)
    end
end

-- Function to apply mods to all weapons
getgenv().modall = function(v)
    for _, weapon in ipairs(game:GetService("ReplicatedStorage").Weapons:GetChildren()) do
        mod(weapon.Name, v)
    end
end

-- Function to apply specific mods
getgenv().modSpecific = function(Modding)
    print('Modding ' .. Modding["Gun"])
    for _, property in ipairs(Moddingtemplate) do
        if property ~= "Gun" and Modding[property] ~= nil then
            print(property .. " " .. tostring(Modding[property]))
            Modify(Modding["Gun"], property, Modding[property])
        end
    end
end

-- Store original weapon data
 StoreInfo = {}
if #StoreInfo == 0 then
    for _, gun in ipairs(game:GetService("ReplicatedStorage").Weapons:GetChildren()) do
        if gun:IsA("Folder") and gun.Name ~= "Standing" then
            table.insert(StoreInfo, {
                Name = gun.Name,
                Ammo = gun:FindFirstChild("Ammo") and gun.Ammo.Value,
                Auto = gun:FindFirstChild("Auto") and gun.Auto.Value,
                Bullets = gun:FindFirstChild("Bullets") and gun.Bullets.Value,
                FireRate = gun:FindFirstChild("FireRate") and gun.FireRate.Value,
                RecoilControl = gun:FindFirstChild("RecoilControl") and gun.RecoilControl.Value,
                Spread = gun:FindFirstChild("Spread") and gun.Spread.Value,
                MaxSpread = checkMS(gun.Name) and gun:FindFirstChild("MaxSpread") and gun.MaxSpread.Value or nil
            })
        end
    end
    print("Weapons have been saved")
end
print("Arsenal Gun Mod module has loaded")

-- Function to find weapon in StoreInfo
 function findInTable(tbl, name)
    for _, data in ipairs(tbl) do
        if data.Name == name then
            return data
        end
    end
    return nil
end

-- Function to reset weapon mods
getgenv().reset = function(g)
     data = findInTable(StoreInfo, g)
    if data then
        print("Resetting " .. g)
        for property, value in pairs(data) do
            if property ~= "Name" then
                Modify(g, property, value)
            end
        end
    else
        warn("Gun not found: " .. g)
    end
end

-- Function to reset all weapon mods
getgenv().resetall = function()
    for _, weapon in ipairs(game:GetService("ReplicatedStorage").Weapons:GetChildren()) do
        reset(weapon.Name)
    end
end

end

setfpscap(0)

repeat wait() until game:IsLoaded() wait(2)
 ScreenGui = Instance.new("ScreenGui")
 Fps = Instance.new("TextLabel")
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Fps.Name = "Fps"
Fps.Parent = ScreenGui
Fps.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Fps.BackgroundTransparency = 1.000
Fps.Position = UDim2.new(0.786138654, 0, 0, 0)
Fps.Size = UDim2.new(0, 125, 0, 25)
Fps.Font = Enum.Font.SourceSans
Fps.TextColor3 = Color3.fromRGB(255, 255, 255)
Fps.TextScaled = true
Fps.TextSize = 14.000
Fps.TextWrapped = true
Fps.Visible = false
 script = Instance.new('Script', Fps)
 RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function(frame) -- This will fire every time a frame is rendered
getgenv().FpsValue = ("FPS: "..math.round(1/frame))
end)


getgenv().ShowFps = function(isVisable)
    Fps.Visible = isVisable
end

 MarketplaceService = game:GetService("MarketplaceService")
 placeId = game.PlaceId
 function getGameName(placeId)
     success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(placeId, Enum.InfoType.Asset)
    end)
    
    if success then
        return gameInfo.Name
    else
        return "Unable to fetch game name."
    end
end 

function toolgiver()
     ToolGiverGui = Instance.new("ScreenGui")
     Frame = Instance.new("Frame")
     ScrollingFrame = Instance.new("ScrollingFrame")
     UIListLayout = Instance.new("UIListLayout")
     TextButton = Instance.new("TextButton")
     TextLabel = Instance.new("TextLabel")
     TextButton_2 = Instance.new("TextButton")
     CloseButton = Instance.new("TextButton")  -- Close Button
    
    -- Variables for Close Button position and size
     CloseX = 0.9  -- Change this for horizontal positioning
     CloseY = 0.016     -- Change this for vertical positioning
     CloseSize = UDim2.new(0, 18, 0, 18)  -- Close Button size
    
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
end

function findInTable(tbl, str)
    for i, v in ipairs(tbl) do
        if v == str then
            return i
        end
    end
    return nil
end

-- Lib

 Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

 Window = Rayfield:CreateWindow({
Name = "Nova - v" .. Version,
Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
LoadingTitle = "Nova",
LoadingSubtitle = "made by MAJESTY",
Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

DisableRayfieldPrompts = true,
DisableBuildWarnings = true, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

ConfigurationSaving = {
Enabled = false,
FolderName = nil, -- Create a custom folder for your hub/game
FileName = "Big Hub"
},

Discord = {
Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
RememberJoins = true -- Set this to false to make them join the discord every time they load it up
},

})

 Tab = Window:CreateTab("Main", "info") -- Title, Image

 Section = Tab:CreateSection("Information")

 Paragraph = Tab:CreateParagraph({Title = "Nova!", Content = "Nova is a script hub containing my best scripts and some useful scripts I didnt make myself. \n \n btw any and all scripts will have their creator metioned."})

 Section = Tab:CreateSection("Credits")

 Paragraph = Tab:CreateParagraph({Title = "Thanks to the following!", Content = "Sirius - made Rayfield (the ui lib im using) \n wearedevs - Made Dex \n Exunys - made Airhub"})

 Section = Tab:CreateSection("Change Logs")

 Paragraph = Tab:CreateParagraph({Title = Version, Content = "Hub was made curently containing 5 scripts."})

-- Scripts

 Tab = Window:CreateTab("Universal's", "settings") -- Title, Image

 Section = Tab:CreateSection("Scripts that work on all games!")

 Button = Tab:CreateButton({
    Name = ("Infinite Yeild - by unknown"),
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/AirHub.lua"))()
    end,
    })

 Button = Tab:CreateButton({
    Name = ("Airhub - by Exunys"),
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/AirHub/main/AirHub.lua"))()
    end,
    })

 Button = Tab:CreateButton({
    Name = ("Tool Giver - by MAJESTY"),
    Callback = function()
        toolgiver()
    end,
    })

 Divider = Tab:CreateDivider()

 Section = Tab:CreateSection("These scripts are usefull for script developers.")

 Button = Tab:CreateButton({
    Name = ("Dex - by wearedevs"),
    Callback = function()
        getgenv().Dex()
    end,
    })

    Button = Tab:CreateButton({
        Name = ("Dex Toggle - by MAJESTY"),
        Callback = function()
            local Players = game:GetService("Players")
local player = Players.LocalPlayer
local isEquipped = false
    local tool = Instance.new("Tool")
    tool.Name = "DynamicTool"
    tool.RequiresHandle = false -- No need for a handle
    tool.Parent = player.Backpack -- Place it in the player's Backpack
    tool.Equipped:Connect(function()
        isEquipped = true
        getgenv().Dex(true)
    end)
    tool.Unequipped:Connect(function()
        isEquipped = false
        getgenv().Dex(false)
    end)
        end,
        })

 Button = Tab:CreateButton({
    Name = ("Debug menu - by MAJESTY"),
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/MAJESTY5164/Majestys-scripts/refs/heads/main/Debug%20Menu.lua"))()
    end,
    })

 Tab = Window:CreateTab("Scripts", "settings") -- Title, Image

 function confirm(e)
    return string.find(string.lower(string.gsub(getgenv().GameName, " ", "")), string.lower(e))
 end

 function error()
        Rayfield:Notify({
            Title = "Error",
            Content = "Current game dosent support this script.",
            Duration = 6.5,
            Image = 4483362458,
         })
    end

 Section = Tab:CreateSection("These scripts are made for specific games.")

_G["arsenal"] = function()
    if confirm("arsenal") then
        --loadarsenalapi()
    end
 Section = Tab:CreateSection("Arsenal.")

 moddedgun = Tab:CreateToggle({
    Name = ("Modded Guns - by MAJESTY"),
    CurrentValue = false,
    Callback = function(Value)
        if confirm("arsenal") then
            if Value then
                getgenv().modall()
                getgenv().modded = true
            else
                getgenv().resetall()
                getgenv().modded = false
            end
        elseif Value == true then
            moddedgun:Set(false)
            error()
        end
    end
    })
end

    _G["fisch"] = function()
        if confirm("fisch") then
            fichmodule()
        end
     Section = Tab:CreateSection("Fisch.")
    
     fischauto = Tab:CreateToggle({
        Name = ("Fisch auto shake - by MAJESTY"),
        CurrentValue = false,
        Callback = function(Value)
            if confirm("fisch") then
                    getgenv().autoshake(Value)
            elseif Value == true then
                fischauto:Set(false)
                error()
            end
        end
        })

    fischreel = Tab:CreateToggle({
        Name = ("Fisch auto reel - by MAJESTY"),
        CurrentValue = false,
        Callback = function(Value)
            if confirm("fisch") then
                    getgenv().autoreel(Value)
            elseif Value == true then
                fischreel:Set(false)
                error()
            end
        end
        })
    end

    _G["ros"] = function()
     Section = Tab:CreateSection("Roblox Operation Siege.")
    
     rosgodmode = Tab:CreateToggle({
        Name = ("Godmode & Invisibility"),
        CurrentValue = false,
        Callback = function(Value)
            if true then
                if getgenv().fakealive == false then
                    getgenv().loadinvis()
                end
                getgenv().toggleinvisible(Value)
            elseif Value == true then
                error()
            end
        end
        })
    end
    
games = {"arsenal", "fisch", "ros"}

    for i = 1, 2 do
        for f = 1, #games do
        check = string.find(string.lower(string.gsub(getgenv().GameName, " ", "")), string.lower(games[f]))

    if check and i == 1 or i == 2 and check == nil then -- or i == 2 and not(string.find(string.lower(string.gsub(GameName, " ", "")), string.lower(games[f]))) 
    _G[games[f]]()
    end
end
end
-- Settings
 Tab = Window:CreateTab("Settings", "settings") -- Title, Image

 Section = Tab:CreateSection("Fps")

 FpsLabel = Tab:CreateLabel("Loading...")

 Input = Tab:CreateInput({
    Name = "Fps Cap",
    CurrentValue = "0",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if type(tonumber(Text)) == "number" then
        setfpscap(tonumber(Text))
        Rayfield:Notify({
            Title = "Fps",
            Content = "Fps Cap set to " .. Text,
            Duration = 5,
         })
        else
            Rayfield:Notify({
                Title = "Fps",
                Content = "Error please provide a number",
                Duration = 5,
             })
        end
    end,
 })

  Toggle = Tab:CreateToggle({
    Name = "Fps Overlay",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().ShowFps(Value)
    end,
 })

 Section = Tab:CreateSection("Misc")

 Slider = Tab:CreateSlider({
    Name = "Update Speed",
    Range = {0, 10},
    Increment = 0.5,
    Suffix = "seconds",
    CurrentValue = 0,
    Callback = function(Value)
        updatespeed = Value
    end,
 })

while true do
    FpsLabel:Set(getgenv().FpsValue)
    script.Parent.Text = getgenv().FpsValue
wait(0)
end

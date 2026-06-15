local Library = {
    Theme = {
        Accent = Color3.fromRGB(255, 200, 0),
        Background = Color3.fromRGB(20, 20, 20),
        Secondary = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        Rounding = 10
    }
}

-- Services
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Run = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- Helper pour la stabilité (Évite le CoreGui si instable)
local function getSafeParent()
    local success, coregui = pcall(function() return game:GetService("CoreGui") end)
    if success and coregui then
        return coregui
    end
    return PlayerGui
end

-- UI Helpers
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function round(parent, radius)
    local c = create("UICorner", {CornerRadius = UDim.new(0, radius or Library.Theme.Rounding)})
    c.Parent = parent
end

local function t(obj, props)
    Tween:Create(obj, TweenInfo.new(0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Main Window
function Library:CreateWindow(title)
    local window = {Tabs = {}, ActiveTab = nil}
    
    local sg = create("ScreenGui", {Name = "StableLib", DisplayOrder = 999, ResetOnSpawn = false})
    sg.Parent = getSafeParent()
    
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(550, 350),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        ClipsDescendants = true,
        Parent = sg
    })
    round(main)
    
    -- Draggable
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = i.Position; startPos = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar
    local sidebar = create("Frame", {
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = main
    })
    round(sidebar)
    
    create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, 0, 0, 50),
        TextColor3 = Library.Theme.Accent,
        Font = Library.Theme.Font,
        TextSize = 20,
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    
    local tabList = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = sidebar
    })
    create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabList})

    local container = create("Frame", {
        Size = UDim2.new(1, -160, 1, -10),
        Position = UDim2.new(0, 155, 0, 5),
        BackgroundTransparency = 1,
        Parent = main
    })

    function window:AddTab(name)
        local tab = {Elements = {}}
        local btn = create("TextButton", {
            Text = name,
            Size = UDim2.new(0.9, 0, 0, 35),
            BackgroundColor3 = Library.Theme.Background,
            TextColor3 = Library.Theme.Text,
            Font = Library.Theme.Font,
            TextSize = 14,
            Parent = tabList
        })
        round(btn, 6)
        
        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Parent = container
        })
        create("UIListLayout", {Padding = UDim.new(0, 10), Parent = page})
        
        btn.MouseButton1Click:Connect(function()
            if window.ActiveTab then
                window.ActiveTab.Page.Visible = false
                t(window.ActiveTab.Btn, {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Text})
            end
            page.Visible = true
            t(btn, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Background})
            window.ActiveTab = {Page = page, Btn = btn}
        end)

        function tab:AddButton(text, callback)
            local b = create("TextButton", {
                Text = text,
                Size = UDim2.new(1, 0, 0, 35),
                BackgroundColor3 = Library.Theme.Secondary,
                TextColor3 = Library.Theme.Text,
                Font = Library.Theme.Font,
                TextSize = 14,
                Parent = page
            })
            round(b, 6)
            b.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, default, callback)
            local state = default
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            round(f, 6)
            create("TextLabel", {Text = "  " .. text, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local b = create("TextButton", {Text = "", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background, Parent = f})
            round(b, 10)
            local dot = create("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(state and 0.55 or 0.05, 0, 0.1, 0), BackgroundColor3 = Library.Theme.Text, Parent = b})
            round(dot, 8)
            
            b.MouseButton1Click:Connect(function()
                state = not state
                t(b, {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background})
                t(dot, {Position = UDim2.new(state and 0.55 or 0.05, 0, 0.1, 0)})
                callback(state)
            end)
        end

        function tab:AddSlider(text, min, default, max, callback)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            round(f, 6)
            local l = create("TextLabel", {Text = "  " .. text .. ": " .. default, Size = UDim2.new(1, 0, 0, 25), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local bar = create("Frame", {Size = UDim2.new(0.9, 0, 0, 6), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundColor3 = Library.Theme.Background, Parent = f})
            round(bar, 3)
            local fill = create("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = bar})
            round(fill, 3)
            
            local drag = false
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
            UIS.InputChanged:Connect(function(i)
                if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local v = math.floor(min + (max-min)*p)
                    fill.Size = UDim2.new(p, 0, 1, 0); l.Text = "  " .. text .. ": " .. v; callback(v)
                end
            end)
        end

        if not window.ActiveTab then btn.MouseButton1Click:Fire() end
        return tab
    end

    return window
end

-- ============================================================
-- EXEMPLE D'UTILISATION (Directement intégré)
-- ============================================================

local Window = Library:CreateWindow("ULTRA STABLE")

local MainTab = Window:AddTab("Main")
local VisualsTab = Window:AddTab("Visuals")

MainTab:AddToggle("Auto Farm", false, function(state)
    print("Auto Farm: " .. tostring(state))
end)

MainTab:AddSlider("WalkSpeed", 16, 16, 200, function(val)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

MainTab:AddButton("Destroy GUI", function()
    local sg = getSafeParent():FindFirstChild("StableLib")
    if sg then sg:Destroy() end
end)

VisualsTab:AddButton("ESP Players", function()
    print("ESP Activated")
end)

print("GUI Ultra Stable chargé !")

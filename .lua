--!strict

--[[ 
    ROBLOX UI LIBRARY - VIDEO EXACT VERSION
    Style: Ultra-Premium Gold & Dark (Video Style)
    Everything in one file to prevent SEH crashes.
]]

local Library = {
    Theme = {
        Accent = Color3.fromRGB(255, 200, 0),
        AccentGradient = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(184, 134, 11)),
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.GothamBold,
        Rounding = 12
    }
}

-- Services
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Stability Parent
local function getParent()
    local success, coregui = pcall(function() return game:GetService("CoreGui") end)
    return (success and coregui) or PlayerGui
end

-- Helpers
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or Library.Theme.Rounding)
    c.Parent = parent
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Library.Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function t(obj, props, time)
    Tween:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play()
end

-- Main Window
function Library:CreateWindow(title)
    local window = {Tabs = {}, ActiveTab = nil}
    
    local sg = create("ScreenGui", {Name = "VideoLib", DisplayOrder = 999, ResetOnSpawn = false})
    sg.Parent = getParent()
    
    -- Background Blur
    local blur = create("BlurEffect", {Name = "UIBlur", Size = 0, Parent = Lighting})
    t(blur, {Size = 15}, 0.5)
    
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(600, 400),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        Parent = sg
    })
    addCorner(main)
    local mainStroke = addStroke(main, Library.Theme.Border, 1.5)
    
    -- Gradient Border Effect
    local grad = create("UIGradient", {Color = Library.Theme.AccentGradient, Parent = mainStroke})
    
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
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        Parent = main
    })
    addCorner(sidebar)
    addStroke(sidebar, Library.Theme.Border, 1)
    
    create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, 0, 0, 60),
        TextColor3 = Library.Theme.Accent,
        Font = Library.Theme.Font,
        TextSize = 22,
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    
    local tabList = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -70),
        Position = UDim2.new(0, 0, 0, 65),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        Parent = sidebar
    })
    create("UIListLayout", {Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabList})

    local container = create("Frame", {
        Size = UDim2.new(1, -180, 1, -20),
        Position = UDim2.new(0, 170, 0, 10),
        BackgroundTransparency = 1,
        Parent = main
    })

    function window:AddTab(name)
        local tab = {}
        local btn = create("TextButton", {
            Text = name,
            Size = UDim2.new(0.85, 0, 0, 40),
            BackgroundColor3 = Library.Theme.Background,
            TextColor3 = Library.Theme.TextDark,
            Font = Library.Theme.Font,
            TextSize = 14,
            Parent = tabList
        })
        addCorner(btn, 8)
        local btnStroke = addStroke(btn, Library.Theme.Border, 1)
        
        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Parent = container
        })
        create("UIListLayout", {Padding = UDim.new(0, 12), Parent = page})
        
        btn.MouseButton1Click:Connect(function()
            if window.ActiveTab then
                window.ActiveTab.Page.Visible = false
                t(window.ActiveTab.Btn, {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.TextDark})
                t(window.ActiveTab.Stroke, {Color = Library.Theme.Border})
            end
            page.Visible = true
            t(btn, {BackgroundColor3 = Library.Theme.Secondary, TextColor3 = Library.Theme.Accent})
            t(btnStroke, {Color = Library.Theme.Accent})
            window.ActiveTab = {Page = page, Btn = btn, Stroke = btnStroke}
        end)

        -- Elements
        function tab:AddButton(text, callback)
            local b = create("TextButton", {
                Text = text,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Library.Theme.Secondary,
                TextColor3 = Library.Theme.Text,
                Font = Library.Theme.Font,
                TextSize = 14,
                Parent = page
            })
            addCorner(b, 8)
            addStroke(b, Library.Theme.Border, 1)
            b.MouseButton1Click:Connect(callback)
            b.MouseEnter:Connect(function() t(b, {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Background}) end)
            b.MouseLeave:Connect(function() t(b, {BackgroundColor3 = Library.Theme.Secondary, TextColor3 = Library.Theme.Text}) end)
        end

        function tab:AddToggle(text, default, callback)
            local state = default
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 8)
            addStroke(f, Library.Theme.Border, 1)
            
            create("TextLabel", {Text = "  " .. text, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            
            local box = create("TextButton", {Text = "", Size = UDim2.new(0, 45, 0, 22), Position = UDim2.new(1, -55, 0.5, -11), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background, Parent = f})
            addCorner(box, 11)
            local dot = create("Frame", {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(state and 0.55 or 0.05, 0, 0.1, 0), BackgroundColor3 = Library.Theme.Text, Parent = box})
            addCorner(dot, 9)
            
            box.MouseButton1Click:Connect(function()
                state = not state
                t(box, {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background})
                t(dot, {Position = UDim2.new(state and 0.55 or 0.05, 0, 0.1, 0)})
                callback(state)
            end)
        end

        function tab:AddSlider(text, min, default, max, callback)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 8)
            addStroke(f, Library.Theme.Border, 1)
            
            local l = create("TextLabel", {Text = "  " .. text .. ": " .. default, Size = UDim2.new(1, 0, 0, 30), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local bar = create("Frame", {Size = UDim2.new(0.94, 0, 0, 8), Position = UDim2.new(0.03, 0, 0.7, 0), BackgroundColor3 = Library.Theme.Background, Parent = f})
            addCorner(bar, 4)
            local fill = create("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = bar})
            addCorner(fill, 4)
            
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

        function tab:AddDropdown(text, list, callback)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 8)
            addStroke(f, Library.Theme.Border, 1)
            
            local l = create("TextLabel", {Text = "  " .. text .. ": " .. (list[1] or ""), Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local btn = create("TextButton", {Text = "▼", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -35, 0.5, -15), BackgroundTransparency = 1, TextColor3 = Library.Theme.Accent, Font = Library.Theme.Font, Parent = f})
            
            btn.MouseButton1Click:Connect(function()
                local opt = list[math.random(#list)]
                l.Text = "  " .. text .. ": " .. opt; callback(opt)
            end)
        end

        function tab:AddColorPicker(text, default, callback)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 8)
            addStroke(f, Library.Theme.Border, 1)
            
            create("TextLabel", {Text = "  " .. text, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local cp = create("TextButton", {Text = "", Size = UDim2.new(0, 35, 0, 22), Position = UDim2.new(1, -45, 0.5, -11), BackgroundColor3 = default, Parent = f})
            addCorner(cp, 6)
            addStroke(cp, Library.Theme.Border, 1)
            
            cp.MouseButton1Click:Connect(function()
                local nc = Color3.fromHSV(math.random(), 1, 1)
                t(cp, {BackgroundColor3 = nc}); callback(nc)
            end)
        end

        function tab:AddParagraph(title, text)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 8)
            addStroke(f, Library.Theme.Border, 1)
            local layout = create("UIListLayout", {Padding = UDim.new(0, 5), Parent = f})
            create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = f})
            
            create("TextLabel", {Text = title, Size = UDim2.new(1, 0, 0, 20), TextColor3 = Library.Theme.Accent, Font = Library.Theme.Font, TextSize = 15, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            create("TextLabel", {Text = text, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextColor3 = Library.Theme.TextDark, Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = f})
        end

        if not window.ActiveTab then btn.MouseButton1Click:Fire() end
        return tab
    end

    return window
end

-- ============================================================
-- EXEMPLE COMPLET - STYLE VIDÉO
-- ============================================================

local Window = Library:CreateWindow("PREMIUM GOLD")

local Main = Window:AddTab("Main")
local Visuals = Window:AddTab("Visuals")
local Settings = Window:AddTab("Settings")

Main:AddParagraph("Welcome", "This is the premium Gold Edition UI library, designed to look exactly like the video. Enjoy the smooth animations and high-quality design.")

Main:AddToggle("Auto Farm", false, function(s) print("Farm: " .. tostring(s)) end)
Main:AddSlider("WalkSpeed", 16, 16, 250, function(v) 
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)

Visuals:AddColorPicker("ESP Color", Color3.fromRGB(255, 215, 0), function(c) print("Color: " .. tostring(c)) end)
Visuals:AddDropdown("ESP Mode", {"Box", "Skeleton", "Tracer", "Highlight"}, function(o) print("Mode: " .. o) end)
Visuals:AddButton("Refresh ESP", function() print("ESP Refreshed") end)

Settings:AddButton("Destroy UI", function() 
    getParent():FindFirstChild("VideoLib"):Destroy() 
    if Lighting:FindFirstChild("UIBlur") then Lighting.UIBlur:Destroy() end
end)

print("GUI Premium Gold Chargé !")

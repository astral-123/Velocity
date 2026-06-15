--!strict

--[[ 
    ROBLOX UI LIBRARY - ULTIMATE GOLD
    Style: Gold & Dark (Video Exact)
    Ultra-Compatible / Zero-Crash
]]

local Library = {
    Theme = {
        Accent = Color3.fromRGB(255, 215, 0),
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Text = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold
    }
}

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

function Library:CreateWindow(title)
    local sg = create("ScreenGui", {Name = "UltimateGold", ResetOnSpawn = false, Parent = PlayerGui})
    
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(500, 350),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        Parent = sg
    })
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = create("UIStroke", {Color = Library.Theme.Accent, Thickness = 2, Parent = main})

    -- Drag
    local drag, start, pos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; start = i.Position; pos = main.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            main.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)

    local sidebar = create("Frame", {Size = UDim2.new(0, 130, 1, 0), BackgroundColor3 = Library.Theme.Secondary, Parent = main})
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)
    
    create("TextLabel", {Text = title, Size = UDim2.new(1, 0, 0, 50), TextColor3 = Library.Theme.Accent, Font = Library.Theme.Font, TextSize = 18, BackgroundTransparency = 1, Parent = sidebar})
    
    local tabButtons = create("Frame", {Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 50), BackgroundTransparency = 1, Parent = sidebar})
    create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabButtons})

    local container = create("Frame", {Size = UDim2.new(1, -140, 1, -20), Position = UDim2.new(0, 135, 0, 10), BackgroundTransparency = 1, Parent = main})

    function window_add_tab(name)
        local page = create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0, Parent = container})
        create("UIListLayout", {Padding = UDim.new(0, 10), Parent = page})
        
        local btn = create("TextButton", {Text = name, Size = UDim2.new(0.9, 0, 0, 30), BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, Parent = tabButtons})
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            for _, v in pairs(container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(tabButtons:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Library.Theme.Background end end
            page.Visible = true; btn.BackgroundColor3 = Library.Theme.Accent
        end)

        local tab = {}
        function tab:AddButton(text, cb)
            local b = create("TextButton", {Text = text, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Library.Theme.Secondary, TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, Parent = page})
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            b.MouseButton1Click:Connect(cb)
        end
        
        function tab:AddToggle(text, default, cb)
            local s = default
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
            create("TextLabel", {Text = "  "..text, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local b = create("TextButton", {Text = "", Size = UDim2.new(0, 35, 0, 20), Position = UDim2.new(1, -45, 0.5, -10), BackgroundColor3 = s and Library.Theme.Accent or Library.Theme.Background, Parent = f})
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
            b.MouseButton1Click:Connect(function() s = not s; b.BackgroundColor3 = s and Library.Theme.Accent or Library.Theme.Background; cb(s) end)
        end

        function tab:AddSlider(text, min, def, max, cb)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
            local l = create("TextLabel", {Text = "  "..text..": "..def, Size = UDim2.new(1, 0, 0, 25), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local bar = create("Frame", {Size = UDim2.new(0.9, 0, 0, 6), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundColor3 = Library.Theme.Background, Parent = f})
            local fill = create("Frame", {Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = bar})
            local drag_s = false
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag_s = true end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag_s = false end end)
            UIS.InputChanged:Connect(function(i)
                if drag_s and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local v = math.floor(min + (max-min)*p)
                    fill.Size = UDim2.new(p, 0, 1, 0); l.Text = "  "..text..": "..v; cb(v)
                end
            end)
        end

        if #tabButtons:GetChildren() == 2 then btn.MouseButton1Click:Fire() end
        return tab
    end

    return {AddTab = window_add_tab}
end


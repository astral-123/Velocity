local Library = {
    Theme = {
        Accent = Color3.fromRGB(255, 200, 0),
        Background = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(25, 25, 25),
        Border = Color3.fromRGB(45, 45, 45),
        Text = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold
    }
}

-- Services
local UIS = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- FORCE PLAYERGUI (Plus stable que CoreGui)
local TargetGui = LocalPlayer:WaitForChild("PlayerGui")
print("Cible d'affichage : PlayerGui")

-- Helpers
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
end

-- Main Window
function Library:CreateWindow(title)
    print("Creation de la fenetre : " .. title)
    local window = {Tabs = {}, ActiveTab = nil}
    
    local sg = create("ScreenGui", {Name = "ForceGoldLib", DisplayOrder = 9999, ResetOnSpawn = false})
    sg.Parent = TargetGui
    
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(550, 350),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Parent = sg
    })
    addCorner(main)
    
    -- Bordure Dorée (UIStroke)
    local stroke = create("UIStroke", {
        Color = Library.Theme.Accent,
        Thickness = 2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = main
    })

    -- Draggable simple
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
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundColor3 = Library.Theme.Secondary,
        BorderSizePixel = 0,
        Parent = main
    })
    addCorner(sidebar)
    
    create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, 0, 0, 50),
        TextColor3 = Library.Theme.Accent,
        Font = Library.Theme.Font,
        TextSize = 20,
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    
    local tabList = create("Frame", {
        Size = UDim2.new(1, 0, 1, -60),
        Position = UDim2.new(0, 0, 0, 55),
        BackgroundTransparency = 1,
        Parent = sidebar
    })
    create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabList})

    local container = create("Frame", {
        Size = UDim2.new(1, -150, 1, -20),
        Position = UDim2.new(0, 145, 0, 10),
        BackgroundTransparency = 1,
        Parent = main
    })

    function window:AddTab(name)
        print("Ajout de l'onglet : " .. name)
        local tab = {}
        local btn = create("TextButton", {
            Text = name,
            Size = UDim2.new(0.9, 0, 0, 35),
            BackgroundColor3 = Library.Theme.Background,
            TextColor3 = Library.Theme.Text,
            Font = Library.Theme.Font,
            TextSize = 14,
            Parent = tabList
        })
        addCorner(btn, 6)
        
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
                window.ActiveTab.Btn.BackgroundColor3 = Library.Theme.Background
            end
            page.Visible = true
            btn.BackgroundColor3 = Library.Theme.Accent
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
            addCorner(b, 6)
            b.MouseButton1Click:Connect(callback)
        end

        function tab:AddToggle(text, default, callback)
            local state = default
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 6)
            create("TextLabel", {Text = "  " .. text, Size = UDim2.new(1, 0, 1, 0), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            
            local b = create("TextButton", {Text = "", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background, Parent = f})
            addCorner(b, 10)
            
            b.MouseButton1Click:Connect(function()
                state = not state
                b.BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.Background
                callback(state)
            end)
        end

        function tab:AddSlider(text, min, default, max, callback)
            local f = create("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Library.Theme.Secondary, Parent = page})
            addCorner(f, 6)
            local l = create("TextLabel", {Text = "  " .. text .. ": " .. default, Size = UDim2.new(1, 0, 0, 25), TextColor3 = Library.Theme.Text, Font = Library.Theme.Font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local bar = create("Frame", {Size = UDim2.new(0.9, 0, 0, 6), Position = UDim2.new(0.05, 0, 0.7, 0), BackgroundColor3 = Library.Theme.Background, Parent = f})
            addCorner(bar, 3)
            local fill = create("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = Library.Theme.Accent, Parent = bar})
            addCorner(fill, 3)
            
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

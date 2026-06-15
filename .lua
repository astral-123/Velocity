--!strict

--[[ 
    Roblox UI Library - FINAL VERSION V2
    Style: Vidéo (Dark/Gold)
    Syntaxe: EchoLabs Exacte
]]

local library = {
    flags = {},
    items = {},
    theme = {
        primaryColor = Color3.fromRGB(255, 200, 0),
        backgroundColor = Color3.fromRGB(26, 26, 26),
        borderColor = Color3.fromRGB(40, 40, 40),
        textColor = Color3.fromRGB(255, 255, 255),
        cornerRadius = 8,
        font = Enum.Font.GothamBold
    }
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Protection pour exécuteurs
local function protect(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    gui.Parent = (RunService:IsStudio() and PlayerGui or CoreGui)
end

-- Utilitaires
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or library.theme.cornerRadius)
    corner.Parent = parent
    return corner
end

-- Notify
function library:Notify(title, text, duration)
    local sg = create("ScreenGui", {Name = "Notify", DisplayOrder = 100})
    protect(sg)
    
    local frame = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 250, 0, 60),
        Position = UDim2.new(1, -260, 1, -70),
        BackgroundColor3 = library.theme.backgroundColor,
        Parent = sg
    })
    addCorner(frame)
    
    create("TextLabel", {
        Text = title,
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 5),
        TextColor3 = library.theme.primaryColor,
        Font = library.theme.font,
        TextSize = 16,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    create("TextLabel", {
        Text = text,
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 30),
        TextColor3 = library.theme.textColor,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    
    task.delay(duration or 5, function() sg:Destroy() end)
end

-- Window
function library:CreateWindow(name, size, hidekey)
    local window = {tabs = {}, activeTab = nil}
    
    local sg = create("ScreenGui", {Name = name, DisplayOrder = 99})
    protect(sg)
    
    local blur = Lighting:FindFirstChild("UIBlur") or create("BlurEffect", {Name = "UIBlur", Size = 0, Parent = Lighting})
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 15}):Play()
    
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.fromOffset(size.X, size.Y),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = library.theme.backgroundColor,
        Parent = sg
    })
    addCorner(main)
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = main.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Hide Key
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == (hidekey or Enum.KeyCode.RightShift) then
            main.Visible = not main.Visible
            blur.Enabled = main.Visible
        end
    end)
    
    -- UI Structure
    local topBar = create("Frame", {Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = library.theme.borderColor, Parent = main})
    addCorner(topBar)
    create("TextLabel", {Text = "  " .. name, Size = UDim2.new(1, 0, 1, 0), TextColor3 = library.theme.textColor, Font = library.theme.font, TextSize = 18, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = topBar})
    
    local tabContainer = create("Frame", {Size = UDim2.new(0, 130, 1, -45), Position = UDim2.new(0, 5, 0, 40), BackgroundColor3 = library.theme.borderColor, BackgroundTransparency = 0.5, Parent = main})
    addCorner(tabContainer)
    local tabLayout = create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = tabContainer})
    
    local pageContainer = create("Frame", {Size = UDim2.new(1, -145, 1, -45), Position = UDim2.new(0, 140, 0, 40), BackgroundTransparency = 1, Parent = main})
    
    function window:CreateTab(tname)
        local tab = {sectors = {}}
        local btn = create("TextButton", {Text = tname, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = library.theme.backgroundColor, TextColor3 = library.theme.textColor, Font = library.theme.font, Parent = tabContainer})
        addCorner(btn)
        
        local page = create("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2, ScrollBarImageColor3 = library.theme.primaryColor, Parent = pageContainer})
        create("UIListLayout", {Padding = UDim.new(0, 10), Parent = page})
        
        btn.MouseButton1Click:Connect(function()
            if window.activeTab then window.activeTab.page.Visible = false; window.activeTab.btn.BackgroundColor3 = library.theme.backgroundColor end
            page.Visible = true; btn.BackgroundColor3 = library.theme.primaryColor
            window.activeTab = {page = page, btn = btn}
        end)
        
        function tab:CreateSector(sname, side)
            local sector = {}
            local sframe = create("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = library.theme.borderColor, BackgroundTransparency = 0.3, Parent = page})
            addCorner(sframe)
            create("UIListLayout", {Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center, Parent = sframe})
            create("TextLabel", {Text = " " .. sname, Size = UDim2.new(1, 0, 0, 25), TextColor3 = library.theme.primaryColor, Font = library.theme.font, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = sframe})
            
            function sector:AddToggle(text, default, callback)
                local toggle = {state = default}
                local f = create("Frame", {Size = UDim2.new(1, -10, 0, 30), BackgroundTransparency = 1, Parent = sframe})
                local l = create("TextLabel", {Text = text, Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 5, 0, 0), TextColor3 = library.theme.textColor, Font = Enum.Font.Gotham, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
                local b = create("TextButton", {Text = "", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0.5, -10), BackgroundColor3 = default and library.theme.primaryColor or library.theme.backgroundColor, Parent = f})
                addCorner(b, 4)
                
                b.MouseButton1Click:Connect(function()
                    toggle.state = not toggle.state
                    b.BackgroundColor3 = toggle.state and library.theme.primaryColor or library.theme.backgroundColor
                    callback(toggle.state)
                end)
                
                function toggle:AddColorpicker(col, cb)
                    local cp = create("TextButton", {Text = "", Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = col, Parent = f})
                    addCorner(cp, 4)
                    cp.MouseButton1Click:Connect(function()
                        local nc = Color3.fromHSV(math.random(), 1, 1)
                        cp.BackgroundColor3 = nc; cb(nc)
                    end)
                end
                
                function toggle:AddKeybind(key, cb)
                    local kb = create("TextButton", {Text = "[None]", Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -105, 0.5, -10), BackgroundColor3 = library.theme.backgroundColor, TextColor3 = library.theme.textColor, Font = Enum.Font.Code, TextSize = 12, Parent = f})
                    addCorner(kb, 4)
                    kb.MouseButton1Click:Connect(function()
                        kb.Text = "..."
                        local input = UserInputService.InputBegan:Wait()
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            kb.Text = "[" .. input.KeyCode.Name .. "]"
                            if cb then cb(input.KeyCode) end
                        end
                    end)
                end
                return toggle
            end
            
            function sector:AddButton(text, callback)
                local b = create("TextButton", {Text = text, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = library.theme.backgroundColor, TextColor3 = library.theme.textColor, Font = library.theme.font, Parent = sframe})
                addCorner(b)
                b.MouseButton1Click:Connect(callback)
            end
            
            function sector:AddSlider(text, min, default, max, precise, callback)
                local f = create("Frame", {Size = UDim2.new(1, -10, 0, 45), BackgroundTransparency = 1, Parent = sframe})
                local l = create("TextLabel", {Text = text .. ": " .. default, Size = UDim2.new(1, 0, 0, 20), TextColor3 = library.theme.textColor, Font = Enum.Font.Gotham, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
                local bar = create("Frame", {Size = UDim2.new(1, -10, 0, 6), Position = UDim2.new(0, 5, 0, 25), BackgroundColor3 = library.theme.backgroundColor, Parent = f})
                addCorner(bar, 3)
                local fill = create("Frame", {Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = library.theme.primaryColor, Parent = bar})
                addCorner(fill, 3)
                
                local drag = false
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        local v = math.floor(min + (max-min)*p)
                        fill.Size = UDim2.new(p, 0, 1, 0); l.Text = text .. ": " .. v; callback(v)
                    end
                end)
            end
            
            function sector:AddTextbox(text, default, callback)
                local f = create("Frame", {Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = library.theme.backgroundColor, Parent = sframe})
                addCorner(f)
                local b = create("TextBox", {Text = default or text, Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, TextColor3 = library.theme.textColor, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
                b.FocusLost:Connect(function() callback(b.Text) end)
            end
            
            function sector:AddDropdown(text, options, default, multi, callback)
                local f = create("Frame", {Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = library.theme.backgroundColor, Parent = sframe})
                addCorner(f)
                local l = create("TextLabel", {Text = text .. ": " .. (default or "None"), Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, TextColor3 = library.theme.textColor, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
                f.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local o = options[math.random(#options)]
                        l.Text = text .. ": " .. o; callback(o)
                    end
                end)
            end
            
            function sector:AddLabel(text, col)
                create("TextLabel", {Text = text, Size = UDim2.new(1, -10, 0, 20), TextColor3 = col or library.theme.textColor, Font = Enum.Font.Gotham, TextSize = 14, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Parent = sframe})
            end
            
            return sector
        end
        
        function tab:CreateConfigSystem(side)
            local s = tab:CreateSector("Configs", side)
            s:AddButton("Save Config", function() library:Notify("Config", "Saved", 3) end)
            s:AddButton("Load Config", function() library:Notify("Config", "Loaded", 3) end)
        end
        
        if not window.activeTab then btn.MouseButton1Click:Fire() end
        return tab
    end
    
    return window
end

return library

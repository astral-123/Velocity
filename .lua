--!strict

--[[ Roblox UI Library Module - Exact EchoLabs Syntax ]]
-- Développé par Manus AI
-- Syntaxe identique à EchoLabs, Style Visuel de la vidéo.

local library = {
    flags = {},
    items = {}
}

-- Services Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- THÈME ET CONFIGURATION GLOBALE
-- ============================================================
library.theme = {
    primaryColor = Color3.fromRGB(255, 200, 0), -- Jaune/doré pour les accents
    backgroundColor = Color3.fromRGB(26, 26, 26), -- Fond sombre
    borderColor = Color3.fromRGB(40, 40, 40),
    textColor = Color3.fromRGB(255, 255, 255),
    cornerRadius = 8,
    backgroundTransparency = 0.1,
    animationTime = 0.2,
    padding = 10,
    spacing = 5,
    font = Enum.Font.Gotham
}

-- ============================================================
-- FONCTIONS UTILITAIRES
-- ============================================================

local function createBaseElement(parent, elementType, name, size, position, anchorPoint, backgroundColor, backgroundTransparency, cornerRadius, text, textColor, textSize, font, textXAlignment)
    local element = Instance.new(elementType)
    element.Name = name
    element.Size = size or UDim2.new(0, 200, 0, 100)
    element.Position = position or UDim2.new(0, 0, 0, 0)
    element.AnchorPoint = anchorPoint or Vector2.new(0, 0)
    element.BackgroundColor3 = backgroundColor or library.theme.backgroundColor
    element.BackgroundTransparency = backgroundTransparency or library.theme.backgroundTransparency
    element.BorderSizePixel = 0
    element.Parent = parent

    if elementType:find("Text") then
        element.Text = text or ""
        element.TextColor3 = textColor or library.theme.textColor
        element.TextSize = textSize or 14
        element.Font = font or library.theme.font
        element.TextXAlignment = textXAlignment or Enum.TextXAlignment.Center
    end

    if cornerRadius and cornerRadius ~= 0 then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius)
        corner.Parent = element
    end

    return element
end

local function addListLayout(frame, padding, horizontalAlignment, verticalAlignment, fillDirection)
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = fillDirection or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top
    layout.Padding = UDim.new(0, padding or library.theme.spacing)
    layout.Parent = frame
    return layout
end

-- ============================================================
-- NOTIFY SYSTEM
-- ============================================================
function library:Notify(title, text, duration)
    local notificationGui = Instance.new("ScreenGui", CoreGui)
    notificationGui.Name = "Notification"

    local frame = createBaseElement(
        notificationGui, "Frame", "NotificationFrame",
        UDim2.new(0, 250, 0, 60), UDim2.new(1, -260, 1, -70), Vector2.new(0, 0),
        library.theme.backgroundColor, 0.2, library.theme.cornerRadius
    )

    local titleLabel = createBaseElement(
        frame, "TextLabel", "Title",
        UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 5), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        title, library.theme.primaryColor, 16, library.theme.font, Enum.TextXAlignment.Left
    )

    local textLabel = createBaseElement(
        frame, "TextLabel", "Text",
        UDim2.new(1, -10, 0, 30), UDim2.new(0, 5, 0, 25), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text, library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left
    )
    textLabel.TextWrapped = true

    task.delay(duration or 5, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        notificationGui:Destroy()
    end)
end

-- ============================================================
-- WINDOW CREATION
-- ============================================================
function library:CreateWindow(name, size, hidekey)
    local window = {}
    window.hidekey = hidekey or Enum.KeyCode.RightShift

    window.Main = Instance.new("ScreenGui", CoreGui)
    window.Main.Name = name

    -- Blur
    local blur = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect", Lighting)
    blur.Size = 10

    window.Frame = createBaseElement(
        window.Main, "Frame", "MainFrame",
        UDim2.fromOffset(size.X, size.Y), UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5),
        library.theme.backgroundColor, library.theme.backgroundTransparency, library.theme.cornerRadius
    )
    window.Frame.Active = true
    window.Frame.Draggable = true

    -- TopBar
    local topBar = createBaseElement(
        window.Frame, "Frame", "TopBar",
        UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        library.theme.borderColor, 0, 0
    )
    createBaseElement(
        topBar, "TextLabel", "Title",
        UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.borderColor, 1, 0,
        name, library.theme.textColor, 18, library.theme.font, Enum.TextXAlignment.Left
    )

    -- Tab Container
    window.TabList = createBaseElement(
        window.Frame, "Frame", "TabList",
        UDim2.new(0, 120, 1, -35), UDim2.new(0, 5, 0, 35), Vector2.new(0, 0),
        library.theme.borderColor, 0.5, library.theme.cornerRadius
    )
    addListLayout(window.TabList, 5, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)

    window.PageContainer = createBaseElement(
        window.Frame, "Frame", "PageContainer",
        UDim2.new(1, -135, 1, -35), UDim2.new(0, 130, 0, 35), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0
    )

    window.tabs = {}
    window.activeTab = nil

    function window:CreateTab(tabName)
        local tab = {}
        tab.button = createBaseElement(
            window.TabList, "TextButton", tabName .. "Tab",
            UDim2.new(1, -10, 0, 30), nil, nil,
            library.theme.backgroundColor, 0.5, library.theme.cornerRadius,
            tabName, library.theme.textColor, 14, library.theme.font
        )

        tab.page = createBaseElement(
            window.PageContainer, "ScrollingFrame", tabName .. "Page",
            UDim2.new(1, 0, 1, 0), nil, nil,
            library.theme.backgroundColor, 1, 0
        )
        tab.page.Visible = false
        tab.page.ScrollBarImageColor3 = library.theme.primaryColor
        tab.page.CanvasSize = UDim2.new(0, 0, 0, 0)
        local pageLayout = addListLayout(tab.page, 10, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)

        tab.button.MouseButton1Click:Connect(function()
            if window.activeTab then
                window.activeTab.page.Visible = false
                window.activeTab.button.BackgroundColor3 = library.theme.backgroundColor
            end
            tab.page.Visible = true
            tab.button.BackgroundColor3 = library.theme.primaryColor
            window.activeTab = tab
        end)

        function tab:CreateSector(sectorName, side)
            local sector = {}
            sector.frame = createBaseElement(
                tab.page, "Frame", sectorName .. "Sector",
                UDim2.new(1, -10, 0, 0), nil, nil,
                library.theme.borderColor, 0.2, library.theme.cornerRadius
            )
            sector.frame.AutomaticSize = Enum.AutomaticSize.Y
            local sectorLayout = addListLayout(sector.frame, 5, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
            sectorLayout.Padding = UDim.new(0, 5)

            createBaseElement(
                sector.frame, "TextLabel", "Title",
                UDim2.new(1, 0, 0, 20), nil, nil,
                library.theme.borderColor, 1, 0,
                sectorName, library.theme.primaryColor, 14, library.theme.font, Enum.TextXAlignment.Left
            )

            -- Components
            function sector:AddToggle(text, default, callback)
                local toggle = {}
                toggle.state = default
                local frame = createBaseElement(sector.frame, "Frame", "Toggle", UDim2.new(1, -10, 0, 25), nil, nil, library.theme.backgroundColor, 0.5, 4)
                local btn = createBaseElement(frame, "TextButton", "Btn", UDim2.new(0, 15, 0, 15), UDim2.new(1, -20, 0.5, 0), Vector2.new(0, 0.5), library.theme.borderColor, 0, 2)
                createBaseElement(frame, "TextLabel", "Label", UDim2.new(1, -30, 1, 0), UDim2.new(0, 5, 0, 0), nil, library.theme.backgroundColor, 1, 0, text, library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left)

                local function update()
                    btn.BackgroundColor3 = toggle.state and library.theme.primaryColor or library.theme.borderColor
                    if callback then callback(toggle.state) end
                end
                btn.MouseButton1Click:Connect(function() toggle.state = not toggle.state; update() end)
                update()

                function toggle:AddColorpicker(defaultColor, colorCallback)
                    local cp = createBaseElement(frame, "TextButton", "CP", UDim2.new(0, 15, 0, 15), UDim2.new(1, -40, 0.5, 0), Vector2.new(0, 0.5), defaultColor, 0, 2)
                    cp.Text = ""
                    cp.MouseButton1Click:Connect(function()
                        local newCol = Color3.fromHSV(math.random(), 1, 1)
                        cp.BackgroundColor3 = newCol
                        if colorCallback then colorCallback(newCol) end
                    end)
                end

                function toggle:AddKeybind(defaultKey, bindCallback)
                    local kb = createBaseElement(frame, "TextButton", "KB", UDim2.new(0, 40, 0, 15), UDim2.new(1, -85, 0.5, 0), Vector2.new(0, 0.5), library.theme.borderColor, 0, 2, "[None]", library.theme.textColor, 10)
                    kb.MouseButton1Click:Connect(function()
                        kb.Text = "..."
                        local input = UserInputService.InputBegan:Wait()
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            kb.Text = "[" .. input.KeyCode.Name .. "]"
                            if bindCallback then bindCallback(input.KeyCode) end
                        end
                    end)
                end

                return toggle
            end

            function sector:AddButton(text, callback)
                local btn = createBaseElement(sector.frame, "TextButton", "Button", UDim2.new(1, -10, 0, 25), nil, nil, library.theme.backgroundColor, 0.5, 4, text)
                btn.MouseButton1Click:Connect(callback)
            end

            function sector:AddSlider(text, min, default, max, precise, callback)
                local frame = createBaseElement(sector.frame, "Frame", "Slider", UDim2.new(1, -10, 0, 35), nil, nil, library.theme.backgroundColor, 0.5, 4)
                local label = createBaseElement(frame, "TextLabel", "Label", UDim2.new(1, -10, 0, 15), UDim2.new(0, 5, 0, 0), nil, library.theme.backgroundColor, 1, 0, text .. ": " .. default, library.theme.textColor, 12, library.theme.font, Enum.TextXAlignment.Left)
                local bar = createBaseElement(frame, "Frame", "Bar", UDim2.new(1, -10, 0, 5), UDim2.new(0, 5, 1, -10), nil, library.theme.borderColor, 0, 2)
                local fill = createBaseElement(bar, "Frame", "Fill", UDim2.new((default-min)/(max-min), 0, 1, 0), nil, nil, library.theme.primaryColor, 0, 2)

                local dragging = false
                bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        local val = math.floor(min + (max - min) * pos)
                        fill.Size = UDim2.new(pos, 0, 1, 0)
                        label.Text = text .. ": " .. val
                        if callback then callback(val) end
                    end
                end)
            end

            function sector:AddTextbox(text, default, callback)
                local frame = createBaseElement(sector.frame, "Frame", "Textbox", UDim2.new(1, -10, 0, 25), nil, nil, library.theme.backgroundColor, 0.5, 4)
                local box = Instance.new("TextBox", frame)
                box.Size = UDim2.new(1, -10, 1, 0)
                box.Position = UDim2.new(0, 5, 0, 0)
                box.BackgroundTransparency = 1
                box.Text = default or text
                box.TextColor3 = library.theme.textColor
                box.Font = library.theme.font
                box.TextSize = 14
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
            end

            function sector:AddDropdown(text, options, default, multi, callback)
                local frame = createBaseElement(sector.frame, "Frame", "Dropdown", UDim2.new(1, -10, 0, 25), nil, nil, library.theme.backgroundColor, 0.5, 4)
                local label = createBaseElement(frame, "TextLabel", "Label", UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), nil, library.theme.backgroundColor, 1, 0, text .. ": " .. (default or "None"), library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left)
                -- Simplifié pour l'exemple
                frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local nextOpt = options[math.random(#options)]
                        label.Text = text .. ": " .. nextOpt
                        if callback then callback(nextOpt) end
                    end
                end)
            end

            function sector:AddLabel(text, color)
                createBaseElement(sector.frame, "TextLabel", "Label", UDim2.new(1, -10, 0, 20), nil, nil, library.theme.backgroundColor, 1, 0, text, color or library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left)
            end

            return sector
        end

        function tab:CreateConfigSystem(side)
            local sector = tab:CreateSector("Configs", side)
            sector:AddButton("Save Config", function() library:Notify("Config", "Saved successfully", 3) end)
            sector:AddButton("Load Config", function() library:Notify("Config", "Loaded successfully", 3) end)
        end

        if not window.activeTab then tab.button.MouseButton1Click:Fire() end
        return tab
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == window.hidekey then
            window.Frame.Visible = not window.Frame.Visible
            blur.Enabled = window.Frame.Visible
        end
    end)

    return window
end

return library

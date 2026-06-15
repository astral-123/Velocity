--!strict

--[[ Roblox UI Library Module - EchoLabs Style ]]
-- Développé par Manus AI
-- Inspiré par la structure EchoLabs et le style visuel de la vidéo fournie par l'utilisateur.
-- Ce module est conçu pour être un fichier unique, facile à charger via loadstring.

local library = {
    flags = {},
    items = {}
}

-- Services Roblox
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- THÈME ET CONFIGURATION GLOBALE
-- ============================================================
library.theme = {
    primaryColor = Color3.fromRGB(255, 200, 0), -- Jaune/doré pour les accents
    backgroundColor = Color3.fromRGB(26, 26, 26), -- Fond sombre
    borderColor = Color3.fromRGB(40, 40, 40),
    textColor = Color3.fromRGB(255, 255, 255),
    cornerRadius = 8, -- Rayon des coins arrondis
    backgroundTransparency = 0.1, -- Légère transparence pour les cadres principaux
    animationTime = 0.2, -- Durée des animations TweenService
    padding = 10, -- Espacement interne des éléments
    spacing = 5, -- Espacement entre les éléments

    -- Couleurs adaptées du thème EchoLabs pour la cohérence visuelle
    outlinecolor = Color3.fromRGB(60, 60, 60),
    outlinecolor2 = Color3.fromRGB(0, 0, 0),
    topheight = 30, -- Hauteur de la barre de titre
    topcolor = Color3.fromRGB(30, 30, 30),
    topcolor2 = Color3.fromRGB(30, 30, 30),
    buttoncolor = Color3.fromRGB(49, 49, 49),
    buttoncolor2 = Color3.fromRGB(39, 39, 39),
    itemscolor = Color3.fromRGB(200, 200, 200),
    itemscolor2 = Color3.fromRGB(210, 210, 210),
    font = Enum.Font.Gotham -- Utilisation de Gotham pour un look moderne
}

-- ============================================================
-- FONCTIONS UTILITAIRES DE BASE
-- ============================================================

-- Fonction utilitaire pour créer des éléments UI de base (Frame, TextLabel, TextButton)
local function createBaseElement(parent, elementType, name, size, position, anchorPoint, backgroundColor, backgroundTransparency, cornerRadius, text, textColor, textSize, font, textXAlignment, textYAlignment)
    local element
    if elementType == "TextButton" then
        element = Instance.new("TextButton")
        element.Text = text or ""
        element.TextColor3 = textColor or library.theme.textColor
        element.TextSize = textSize or 16
        element.Font = font or library.theme.font
        element.TextXAlignment = textXAlignment or Enum.TextXAlignment.Center
        element.AutoButtonColor = false
    elseif elementType == "TextLabel" then
        element = Instance.new("TextLabel")
        element.Text = text or ""
        element.TextColor3 = textColor or library.theme.textColor
        element.TextSize = textSize or 16
        element.Font = font or library.theme.font
        element.TextXAlignment = textXAlignment or Enum.TextXAlignment.Center
        element.TextYAlignment = textYAlignment or Enum.TextYAlignment.Center
        element.TextWrapped = true
        element.TextScaled = false
    else -- Default to Frame
        element = Instance.new("Frame")
    end

    element.Name = name
    element.Size = size or UDim2.new(0, 200, 0, 100)
    element.Position = position or UDim2.new(0.5, 0, 0.5, 0)
    element.AnchorPoint = anchorPoint or Vector2.new(0.5, 0.5)
    element.BackgroundColor3 = backgroundColor or library.theme.backgroundColor
    element.BackgroundTransparency = backgroundTransparency or library.theme.backgroundTransparency
    element.BorderSizePixel = 0
    element.Parent = parent

    if cornerRadius ~= 0 then -- Appliquer UICorner sauf si explicitement 0
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius or library.theme.cornerRadius)
        corner.Parent = element
    end

    return element
end

-- Fonction utilitaire pour ajouter un UIListLayout à un cadre
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
-- KEYBIND HELPERS (adaptés du fichier fourni par l'utilisateur)
-- ============================================================
local shorter_keycodes = {
    ["LeftShift"]    = "LSHIFT",
    ["RightShift"]   = "RSHIFT",
    ["LeftControl"]  = "LCTRL",
    ["RightControl"] = "RCTRL",
    ["LeftAlt"]      = "LALT",
    ["RightAlt"]     = "RALT",
}

local mouse_buttons = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local function keybindToText(value)
    if value == "None" or value == nil then
        return "[None]"
    end
    if mouse_buttons[value] then
        return "[" .. mouse_buttons[value] .. "]"
    end
    if typeof(value) == "EnumItem" then
        return "[" .. (shorter_keycodes[value.Name] or value.Name) .. "]"
    end
    return "[" .. tostring(value) .. "]"
end

local function inputMatchesKeybind(input, value)
    if value == "None" or value == nil then return false end
    if mouse_buttons[value] then
        return input.UserInputType == value
    end
    if typeof(value) == "EnumItem" then
        return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value
    end
    return false
end

local function inputToKeybindValue(input)
    if mouse_buttons[input.UserInputType] then
        return input.UserInputType
    elseif input.UserInputType == Enum.UserInputType.Keyboard then
        return input.KeyCode
    end
    return "None"
end

-- ============================================================
-- DÉFINITION DES COMPOSANTS UI INTERNES (ADAPTÉS)
-- ============================================================

-- Button Component
local function createButton(parent, text, callback)
    local button = {}

    button.frame = createBaseElement(
        parent, "TextButton", "Button",
        UDim2.new(1, 0, 0, 30), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius,
        text, library.theme.textColor, 16, library.theme.font
    )

    button.frame.MouseEnter:Connect(function()
        TweenService:Create(button.frame, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.primaryColor}):Play()
    end)
    button.frame.MouseLeave:Connect(function()
        TweenService:Create(button.frame, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.backgroundColor}):Play()
    end)

    if callback then
        button.frame.MouseButton1Click:Connect(callback)
    end

    return button
end

-- Toggle Component
local function createToggle(parent, text, defaultState, callback)
    local toggle = {}

    toggle.state = defaultState or false

    toggle.frame = createBaseElement(
        parent, "Frame", "Toggle",
        UDim2.new(1, 0, 0, 30), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius
    )

    toggle.label = createBaseElement(
        toggle.frame, "TextLabel", "Label",
        UDim2.new(1, -40, 1, 0), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text, library.theme.textColor, 16, library.theme.font, Enum.TextXAlignment.Left
    )

    toggle.toggleButton = createBaseElement(
        toggle.frame, "TextButton", "ToggleButton",
        UDim2.new(0, 20, 0, 20), UDim2.new(1, -25, 0.5, 0), Vector2.new(1, 0.5),
        library.theme.borderColor, 0, library.theme.cornerRadius / 2,
        "", library.theme.textColor, 16, library.theme.font
    )

    local function updateVisualState()
        if toggle.state then
            TweenService:Create(toggle.toggleButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.primaryColor}):Play()
        else
            TweenService:Create(toggle.toggleButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.borderColor}):Play()
        end
    end

    toggle.toggleButton.MouseButton1Click:Connect(function()
        toggle.state = not toggle.state
        updateVisualState()
        if callback then
            callback(toggle.state)
        end
    end)

    updateVisualState()

    return toggle
end

-- Slider Component
local function createSlider(parent, text, minValue, maxValue, defaultValue, callback)
    local slider = {}

    slider.minValue = minValue or 0
    slider.maxValue = maxValue or 100
    slider.value = defaultValue or slider.minValue

    slider.frame = createBaseElement(
        parent, "Frame", "Slider",
        UDim2.new(1, 0, 0, 40), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius
    )

    slider.label = createBaseElement(
        slider.frame, "TextLabel", "Label",
        UDim2.new(1, -50, 0, 15), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text .. ": " .. math.floor(slider.value), library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left
    )

    slider.sliderBar = createBaseElement(
        slider.frame, "Frame", "SliderBar",
        UDim2.new(1, -10, 0, 10), UDim2.new(0.5, 0, 1, -15), Vector2.new(0.5, 1),
        library.theme.borderColor, 0, library.theme.cornerRadius / 2
    )

    slider.fillBar = createBaseElement(
        slider.sliderBar, "Frame", "FillBar",
        UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        library.theme.primaryColor, 0, library.theme.cornerRadius / 2
    )

    local function updateSliderVisuals()
        local percentage = (slider.value - slider.minValue) / (slider.maxValue - slider.minValue)
        TweenService:Create(slider.fillBar, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(percentage, 0, 1, 0)}):Play()
        slider.label.Text = text .. ": " .. math.floor(slider.value)
    end

    local isDragging = false

    slider.sliderBar.MouseButton1Down:Connect(function()
        isDragging = true
    end)

    slider.sliderBar.MouseLeave:Connect(function()
        isDragging = false
    end)

    slider.sliderBar.MouseUp:Connect(function()
        isDragging = false
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local absolutePositionX = slider.sliderBar.AbsolutePosition.X
            local absoluteSizeX = slider.sliderBar.AbsoluteSize.X

            local relativeX = math.clamp(mouseX - absolutePositionX, 0, absoluteSizeX)
            local percentage = relativeX / absoluteSizeX

            slider.value = slider.minValue + (percentage * (slider.maxValue - slider.minValue))
            updateSliderVisuals()
            if callback then
                callback(slider.value)
            end
        end
    end)

    updateSliderVisuals()

    return slider
end

-- ColorPicker Component
local function createColorPicker(parent, text, defaultColor, callback)
    local colorPicker = {}

    colorPicker.color = defaultColor or Color3.fromRGB(255, 255, 255)

    colorPicker.frame = createBaseElement(
        parent, "Frame", "ColorPicker",
        UDim2.new(1, 0, 0, 50), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius
    )

    colorPicker.label = createBaseElement(
        colorPicker.frame, "TextLabel", "Label",
        UDim2.new(1, -60, 0, 20), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text, library.theme.textColor, 16, library.theme.font, Enum.TextXAlignment.Left
    )

    colorPicker.colorDisplay = createBaseElement(
        colorPicker.frame, "TextButton", "ColorDisplay",
        UDim2.new(0, 40, 0, 20), UDim2.new(1, -45, 0, 5), Vector2.new(1, 0),
        colorPicker.color, 0, library.theme.cornerRadius / 2,
        "", library.theme.textColor, 16, library.theme.font
    )

    colorPicker.colorDisplay.MouseButton1Click:Connect(function()
        -- Pour simplifier, on va juste changer la couleur aléatoirement ou via un prompt simple.
        -- Dans un environnement réel, cela ouvrirait un panneau de sélection de couleur plus complexe.
        local r = math.random(0, 255)
        local g = math.random(0, 255)
        local b = math.random(0, 255)
        colorPicker.color = Color3.fromRGB(r, g, b)
        TweenService:Create(colorPicker.colorDisplay, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = colorPicker.color}):Play()
        if callback then
            callback(colorPicker.color)
        end
    end)

    return colorPicker
end

-- Paragraph Component
local function createParagraph(parent, text, textSize, textColor)
    local paragraph = {}

    paragraph.label = createBaseElement(
        parent, "TextLabel", "Paragraph",
        UDim2.new(1, 0, 0, 0), nil, nil,
        library.theme.backgroundColor, 1, 0,
        text, textColor or library.theme.textColor, textSize or 14, library.theme.font, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
    )
    paragraph.label.AutomaticSize = Enum.AutomaticSize.Y

    return paragraph
end

-- Dropdown Component
local function createDropdown(parent, text, options, defaultOption, callback)
    local dropdown = {}

    dropdown.options = options or {}
    dropdown.selectedOption = defaultOption or (options and options[1]) or ""
    dropdown.isOpen = false

    dropdown.frame = createBaseElement(
        parent, "Frame", "Dropdown",
        UDim2.new(1, 0, 0, 30), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius
    )

    dropdown.label = createBaseElement(
        dropdown.frame, "TextLabel", "Label",
        UDim2.new(1, -40, 1, 0), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text, library.theme.textColor, 16, library.theme.font, Enum.TextXAlignment.Left
    )

    dropdown.displayButton = createBaseElement(
        dropdown.frame, "TextButton", "DisplayButton",
        UDim2.new(0, 100, 1, 0), UDim2.new(1, -105, 0, 0), Vector2.new(1, 0),
        library.theme.borderColor, 0, library.theme.cornerRadius / 2,
        dropdown.selectedOption, library.theme.textColor, 14, library.theme.font
    )

    dropdown.optionsFrame = Instance.new("ScrollingFrame")
    dropdown.optionsFrame.Name = "OptionsFrame"
    dropdown.optionsFrame.Size = UDim2.new(1, 0, 0, 0) -- Hauteur dynamique
    dropdown.optionsFrame.Position = UDim2.new(0, 0, 1, 0)
    dropdown.optionsFrame.AnchorPoint = Vector2.new(0, 0)
    dropdown.optionsFrame.BackgroundColor3 = library.theme.backgroundColor
    dropdown.optionsFrame.BackgroundTransparency = 0
    dropdown.optionsFrame.BorderSizePixel = 0
    dropdown.optionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Sera ajusté
    dropdown.optionsFrame.ScrollBarImageColor3 = library.theme.primaryColor
    dropdown.optionsFrame.Visible = false
    dropdown.optionsFrame.Parent = dropdown.frame

    local optionsLayout = addListLayout(dropdown.optionsFrame, library.theme.spacing, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    optionsLayout.FillDirection = Enum.FillDirection.Vertical

    local function updateOptionsFrameSize()
        local totalHeight = #dropdown.options * (20 + library.theme.spacing) -- Hauteur de chaque option + espacement
        dropdown.optionsFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        dropdown.optionsFrame.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 150)) -- Limiter la hauteur max à 150
    end

    for i, optionText in ipairs(dropdown.options) do
        local optionButton = createBaseElement(
            dropdown.optionsFrame, "TextButton", "OptionButton",
            UDim2.new(1, 0, 0, 20), nil, nil,
            library.theme.backgroundColor, 0, 0,
            optionText, library.theme.textColor, 14, library.theme.font, Enum.TextXAlignment.Left
        )

        optionButton.MouseButton1Click:Connect(function()
            dropdown.selectedOption = optionText
            dropdown.displayButton.Text = optionText
            dropdown.isOpen = false
            dropdown.optionsFrame.Visible = false
            if callback then
                callback(optionText)
            end
        end)

        optionButton.MouseEnter:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.primaryColor}):Play()
        end)
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(optionButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.backgroundColor}):Play()
        end)
    end

    updateOptionsFrameSize()

    dropdown.displayButton.MouseButton1Click:Connect(function()
        dropdown.isOpen = not dropdown.isOpen
        dropdown.optionsFrame.Visible = dropdown.isOpen
    end)

    return dropdown
end

-- Keybind Component
local function createKeybind(parent, text, defaultKeybind, callback)
    local keybind = {}

    keybind.keybind = defaultKeybind or "None"
    keybind.isListening = false

    keybind.frame = createBaseElement(
        parent, "Frame", "Keybind",
        UDim2.new(1, 0, 0, 30), nil, nil,
        library.theme.backgroundColor, 0.5, library.theme.cornerRadius
    )

    keybind.label = createBaseElement(
        keybind.frame, "TextLabel", "Label",
        UDim2.new(1, -80, 1, 0), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0,
        text, library.theme.textColor, 16, library.theme.font, Enum.TextXAlignment.Left
    )

    keybind.keybindButton = createBaseElement(
        keybind.frame, "TextButton", "KeybindButton",
        UDim2.new(0, 70, 1, 0), UDim2.new(1, -75, 0, 0), Vector2.new(1, 0),
        library.theme.borderColor, 0, library.theme.cornerRadius / 2,
        keybindToText(keybind.keybind), library.theme.textColor, 14, library.theme.font
    )

    local function updateKeybindText()
        keybind.keybindButton.Text = keybindToText(keybind.keybind)
    end

    keybind.keybindButton.MouseButton1Click:Connect(function()
        keybind.isListening = not keybind.isListening
        if keybind.isListening then
            keybind.keybindButton.Text = "..."
            TweenService:Create(keybind.keybindButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.primaryColor}):Play()
        else
            updateKeybindText()
            TweenService:Create(keybind.keybindButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.borderColor}):Play()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and keybind.isListening then
            keybind.keybind = inputToKeybindValue(input)
            keybind.isListening = false
            updateKeybindText()
            TweenService:Create(keybind.keybindButton, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.borderColor}):Play()
            if callback then
                callback(keybind.keybind)
            end
        end
    end)

    return keybind
end

-- ============================================================
-- WATERMARK (ADAPTÉ DU FICHIER FOURNI PAR L'UTILISATEUR)
-- ============================================================
function library:CreateWatermark(name, position)
    local watermark = {}
    watermark.Visible = true
    watermark.text = " " .. name:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS") .. " "

    watermark.main = Instance.new("ScreenGui", CoreGui)
    watermark.main.Name = "Watermark"
    -- if syn then syn.protect_gui(watermark.main) end -- Décommenter si vous utilisez un exécuteur supportant syn.protect_gui

    -- if getgenv().watermark then getgenv().watermark:Destroy() end -- Éviter les doublons si déjà existant
    -- getgenv().watermark = watermark.main -- Exposer globalement si nécessaire

    watermark.mainbar = createBaseElement(
        watermark.main, "Frame", "Main",
        UDim2.new(0, 0, 0, 25),
        UDim2.new(0, position and position.X or 10, 0, position and position.Y or 10), Vector2.new(0, 0),
        Color3.fromRGB(20, 20, 20), 0, library.theme.cornerRadius / 2 -- Coins arrondis pour le watermark
    )
    watermark.mainbar.ZIndex = 5
    watermark.mainbar.Visible = watermark.Visible

    local gradient = Instance.new("UIGradient", watermark.mainbar)
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40, 40, 40)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(10, 10, 10)) })

    local outline = createBaseElement(
        watermark.mainbar, "Frame", "Outline",
        UDim2.new(1, 2, 1, 2), UDim2.fromOffset(-1, -1), Vector2.new(0, 0),
        library.theme.outlinecolor, 0, library.theme.cornerRadius / 2
    )
    outline.ZIndex = 4
    outline.Visible = watermark.Visible

    local blackOutline = createBaseElement(
        watermark.mainbar, "Frame", "BlackOutline",
        UDim2.new(1, 4, 1, 4), UDim2.fromOffset(-2, -2), Vector2.new(0, 0),
        library.theme.outlinecolor2, 0, library.theme.cornerRadius / 2
    )
    blackOutline.ZIndex = 3
    blackOutline.Visible = watermark.Visible

    watermark.label = createBaseElement(
        watermark.mainbar, "TextLabel", "FPSLabel",
        UDim2.new(0, 238, 0, 25), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        Color3.fromRGB(255, 255, 255), 1, 0,
        watermark.text, Color3.fromRGB(255, 255, 255), 15, library.theme.font, Enum.TextXAlignment.Left
    )
    watermark.label.ZIndex = 6
    watermark.label.Visible = watermark.Visible
    watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 25)

    local topbar = createBaseElement(
        watermark.mainbar, "Frame", "TopBar",
        UDim2.new(0, 0, 0, 1), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        library.theme.primaryColor, 0, 0
    )
    topbar.ZIndex = 6
    topbar.Visible = watermark.Visible
    topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 6, 0, 1)

    watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 25)
    watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 25)
    topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 6, 0, 1)
    outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
    blackOutline.Size = watermark.mainbar.Size + UDim2.fromOffset(4, 4)

    local startTime, counter, oldfps = os.clock(), 0, nil
    RunService.Heartbeat:Connect(function()
        watermark.label.Visible = watermark.Visible
        watermark.mainbar.Visible = watermark.Visible
        topbar.Visible = watermark.Visible
        outline.Visible = watermark.Visible
        blackOutline.Visible = watermark.Visible

        if not name:find("{fps}") then
            watermark.label.Text = " " .. name:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", "0 FPS") .. " "
        end

        if name:find("{fps}") then
            local currentTime = os.clock()
            counter = counter + 1
            if currentTime - startTime >= 1 then
                local fps = math.floor(counter / (currentTime - startTime))
                counter = 0
                startTime = currentTime

                if fps ~= oldfps then
                    watermark.label.Text = " " .. name:gsub("{game}", MarketplaceService:GetProductInfo(game.PlaceId).Name):gsub("{fps}", fps .. " FPS") .. " "
                    watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 25)
                    watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 25)
                    topbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 1)
                    outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
                    blackOutline.Size = watermark.mainbar.Size + UDim2.fromOffset(4, 4)
                end
                oldfps = fps
            end
        end
    end)

    -- Hover effects for watermark (adapted)
    watermark.mainbar.MouseEnter:Connect(function()
        TweenService:Create(watermark.mainbar, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(topbar, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(watermark.label, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(outline, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        TweenService:Create(blackOutline, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    end)

    watermark.mainbar.MouseLeave:Connect(function()
        TweenService:Create(watermark.mainbar, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
        TweenService:Create(topbar, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
        TweenService:Create(watermark.label, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {TextTransparency = 0}):Play()
        TweenService:Create(outline, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
        TweenService:Create(blackOutline, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {BackgroundTransparency = 0}):Play()
    end)

    function watermark:Remove()
        watermark.main:Destroy()
    end

    return watermark
end

-- ============================================================
-- FENÊTRE PRINCIPALE (WINDOW) - ADAPTÉE DU FICHIER FOURNI
-- ============================================================
function library:CreateWindow(name, size, hidebutton)
    local window = {}

    window.name = name or ""
    window.size = size or UDim2.fromOffset(600, 400) -- Taille par défaut adaptée
    window.hidebutton = hidebutton or Enum.KeyCode.RightShift
    window.hidekey = window.hidebutton
    window.theme = library.theme

    local updateevent = Instance.new("BindableEvent")
    function window:UpdateTheme(theme)
        updateevent:Fire(theme or library.theme)
        window.theme = (theme or library.theme)
    end

    window.Main = Instance.new("ScreenGui", CoreGui)
    window.Main.Name = name
    window.Main.DisplayOrder = 15
    -- if syn then syn.protect_gui(window.Main) end

    -- if getgenv().uilib then getgenv().uilib:Remove() end
    -- getgenv().uilib = window.Main

    -- BlurEffect
    local blur = Lighting:FindFirstChildOfClass("BlurEffect")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "RobloxUILibraryBlur"
        blur.Size = 0
        blur.Parent = Lighting
    end
    window.blurEffect = blur
    TweenService:Create(window.blurEffect, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 10}):Play() -- Appliquer un flou léger

    local dragging, dragInput, dragStart, startPos
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local dragstart = function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = window.Frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local dragend = function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end

    window.Frame = createBaseElement(
        window.Main, "TextButton", "main",
        window.size, UDim2.fromScale(0.5, 0.5), Vector2.new(0.5, 0.5),
        window.theme.backgroundColor, window.theme.backgroundTransparency, window.theme.cornerRadius,
        "", window.theme.textColor, 16, window.theme.font -- Est un TextButton pour le drag
    )
    window.Frame.Draggable = true -- Activer le drag natif de Roblox

    updateevent.Event:Connect(function(theme)
        window.Frame.BackgroundColor3 = theme.backgroundColor
    end)

    UserInputService.InputBegan:Connect(function(key)
        if key.KeyCode == window.hidekey then
            window.Frame.Visible = not window.Frame.Visible
            if window.Frame.Visible then
                TweenService:Create(window.blurEffect, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 10}):Play()
            else
                TweenService:Create(window.blurEffect, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
            end
        end
    end)

    -- Outlines (adaptées)
    window.BlackOutline = createBaseElement(
        window.Frame, "Frame", "outline",
        window.size + UDim2.fromOffset(2, 2), UDim2.fromOffset(-1, -1), Vector2.new(0, 0),
        window.theme.outlinecolor2, 0, window.theme.cornerRadius
    )
    window.BlackOutline.ZIndex = 1
    updateevent.Event:Connect(function(theme) window.BlackOutline.BackgroundColor3 = theme.outlinecolor2 end)

    window.Outline = createBaseElement(
        window.Frame, "Frame", "outline",
        window.size + UDim2.fromOffset(4, 4), UDim2.fromOffset(-2, -2), Vector2.new(0, 0),
        window.theme.outlinecolor, 0, window.theme.cornerRadius
    )
    window.Outline.ZIndex = 0
    updateevent.Event:Connect(function(theme) window.Outline.BackgroundColor3 = theme.outlinecolor end)

    window.BlackOutline2 = createBaseElement(
        window.Frame, "Frame", "outline",
        window.size + UDim2.fromOffset(6, 6), UDim2.fromOffset(-3, -3), Vector2.new(0, 0),
        window.theme.outlinecolor2, 0, window.theme.cornerRadius
    )
    window.BlackOutline2.ZIndex = -1
    updateevent.Event:Connect(function(theme) window.BlackOutline2.BackgroundColor3 = theme.outlinecolor2 end)

    window.TopBar = createBaseElement(
        window.Frame, "Frame", "top",
        UDim2.new(window.size.X.Offset, 0, 0, window.theme.topheight), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        library.theme.topcolor, 0, 0 -- Pas d'arrondis pour la topbar
    )
    window.TopBar.InputBegan:Connect(dragstart)
    window.TopBar.InputChanged:Connect(dragend)
    updateevent.Event:Connect(function(theme)
        window.TopBar.Size = UDim2.new(window.size.X.Offset, 0, 0, theme.topheight)
    end)

    local titleLabel = createBaseElement(
        window.TopBar, "TextLabel", "TitleLabel",
        UDim2.new(1, -60, 1, 0), UDim2.new(0, 5, 0, 0), Vector2.new(0, 0),
        library.theme.topcolor, 1, 0,
        name, library.theme.textColor, 18, library.theme.font, Enum.TextXAlignment.Left
    )

    -- Bouton de fermeture
    local closeButton = createBaseElement(
        window.TopBar, "TextButton", "CloseButton",
        UDim2.new(0, 20, 1, 0), UDim2.new(1, -25, 0, 0), Vector2.new(1, 0),
        Color3.fromRGB(255, 50, 50), 0, library.theme.cornerRadius / 2,
        "X", Color3.fromRGB(255, 255, 255), 16, library.theme.font
    )
    closeButton.MouseButton1Click:Connect(function()
        window.Main:Destroy()
        if window.blurEffect then
            TweenService:Create(window.blurEffect, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
    end)

    -- Bouton de minimisation
    local minimizeButton = createBaseElement(
        window.TopBar, "TextButton", "MinimizeButton",
        UDim2.new(0, 20, 1, 0), UDim2.new(1, -50, 0, 0), Vector2.new(1, 0),
        library.theme.borderColor, 0, library.theme.cornerRadius / 2,
        "_", library.theme.textColor, 16, library.theme.font
    )

    local isMinimized = false
    local originalSize = window.Frame.Size
    local originalPosition = window.Frame.Position

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(window.Frame, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 200, 0, library.theme.topheight),
                Position = UDim2.new(0.5, 0, 1, -library.theme.topheight)
            }):Play()
        else
            TweenService:Create(window.Frame, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = originalPosition
            }):Play()
        end
    end)

    -- Conteneur pour les onglets/sections
    window.ContentFrame = createBaseElement(
        window.Frame, "Frame", "Content",
        UDim2.new(1, 0, 1, -library.theme.topheight), UDim2.new(0, 0, 0, library.theme.topheight), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0 -- Pas d'arrondis ici, le parent gère
    )
    window.ContentFrame.ClipsDescendants = true

    window.tabs = {}
    window.activeTab = nil

    -- Layout pour les onglets (horizontal)
    window.TabList = createBaseElement(
        window.ContentFrame, "Frame", "TabList",
        UDim2.new(0, 100, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
        library.theme.borderColor, 0, 0 -- Pas d'arrondis ici
    )
    local tabListLayout = addListLayout(window.TabList, library.theme.spacing, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, Enum.FillDirection.Vertical)
    tabListLayout.Name = "TabListLayout"
    tabListLayout.Padding = UDim.new(0, library.theme.padding)

    window.PageFrame = createBaseElement(
        window.ContentFrame, "Frame", "PageFrame",
        UDim2.new(1, -100, 1, 0), UDim2.new(0, 100, 0, 0), Vector2.new(0, 0),
        library.theme.backgroundColor, 1, 0 -- Pas d'arrondis ici
    )
    window.PageFrame.ClipsDescendants = true

    function window:CreateTab(tabName)
        local tab = {}
        tab.name = tabName

        tab.button = createBaseElement(
            window.TabList, "TextButton", tabName .. "TabButton",
            UDim2.new(1, -library.theme.padding * 2, 0, 30), nil, nil,
            library.theme.backgroundColor, 0.5, library.theme.cornerRadius,
            tabName, library.theme.textColor, 16, library.theme.font
        )

        tab.page = createBaseElement(
            window.PageFrame, "ScrollingFrame", tabName .. "Page",
            UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
            library.theme.backgroundColor, 1, 0 -- Pas d'arrondis ici
        )
        tab.page.Visible = false
        tab.page.CanvasSize = UDim2.new(0, 0, 0, 0)
        tab.page.ScrollBarImageColor3 = library.theme.primaryColor

        local pageLayout = addListLayout(tab.page, library.theme.padding, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
        pageLayout.Name = "PageLayout"
        pageLayout.Padding = UDim.new(0, library.theme.padding)

        tab.button.MouseButton1Click:Connect(function()
            if window.activeTab then
                window.activeTab.page.Visible = false
                TweenService:Create(window.activeTab.button, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.backgroundColor}):Play()
            end
            tab.page.Visible = true
            TweenService:Create(tab.button, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = library.theme.primaryColor}):Play()
            window.activeTab = tab
        end)

        -- Fonctions pour ajouter des sections à l'onglet
        function tab:CreateSection(sectionTitle)
            local section = {}
            section.title = sectionTitle

            section.frame = createBaseElement(
                tab.page, "Frame", sectionTitle .. "Section",
                UDim2.new(1, -library.theme.padding * 2, 0, 0), nil, nil,
                library.theme.borderColor, 0.2, library.theme.cornerRadius
            )
            section.frame.ClipsDescendants = true
            section.frame.Size = UDim2.new(1, -library.theme.padding * 2, 0, 50) -- Taille initiale, sera ajustée par le layout

            section.titleLabel = createBaseElement(
                section.frame, "TextLabel", "SectionTitle",
                UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 0), Vector2.new(0, 0),
                library.theme.borderColor, 1, 0,
                sectionTitle, library.theme.primaryColor, 16, library.theme.font, Enum.TextXAlignment.Left
            )

            local sectionLayout = addListLayout(section.frame, library.theme.spacing, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
            sectionLayout.Name = "SectionLayout"
            sectionLayout.Padding = UDim.new(0, library.theme.padding)

            -- Ajuster la taille de la section en fonction de son contenu
            section.frame.Changed:Connect(function(property)
                if property == "AbsoluteSize" then
                    local contentHeight = sectionLayout.AbsoluteContentSize.Y
                    section.frame.Size = UDim2.new(1, -library.theme.padding * 2, 0, contentHeight + library.theme.padding * 2)
                    tab.page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + library.theme.padding * 2)
                end
            end)

            -- Fonctions pour ajouter des composants à la section
            function section:AddButton(text, callback)
                return createButton(section.frame, text, callback)
            end

            function section:AddToggle(text, defaultState, callback)
                return createToggle(section.frame, text, defaultState, callback)
            end

            function section:AddSlider(text, minValue, maxValue, defaultValue, callback)
                return createSlider(section.frame, text, minValue, maxValue, defaultValue, callback)
            end

            function section:AddColorPicker(text, defaultColor, callback)
                return createColorPicker(section.frame, text, defaultColor, callback)
            end

            function section:AddParagraph(text, textSize, textColor)
                return createParagraph(section.frame, text, textSize, textColor)
            end

            function section:AddDropdown(text, options, defaultOption, callback)
                return createDropdown(section.frame, text, options, defaultOption, callback)
            end

            function section:AddKeybind(text, defaultKeybind, callback)
                return createKeybind(section.frame, text, defaultKeybind, callback)
            end

            return section
        end

        window.tabs[tabName] = tab
        if not window.activeTab then
            tab.button.MouseButton1Click:Fire() -- Activer le premier onglet par défaut
        end
        return tab
    end

    function window:Remove()
        window.Main:Destroy()
        if window.blurEffect then
            TweenService:Create(window.blurEffect, TweenInfo.new(library.theme.animationTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 0}):Play()
        end
    end

    return window
end

return library

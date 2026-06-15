local lib = {}
lib.Flags = {}
lib.Items = {}

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")

local lp    = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam   = workspace.CurrentCamera

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad), props):Play()
end

local function corner(p, r)
	local c = Instance.new("UICorner", p)
	c.CornerRadius = UDim.new(0, r or 4)
end

local function stroke(p, col, th)
	local s = Instance.new("UIStroke", p)
	s.Color = col or Color3.fromRGB(70,60,30)
	s.Thickness = th or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

-- Couleurs style Velocity
local C = {
	BG       = Color3.fromRGB(25, 23, 15),
	BGLight  = Color3.fromRGB(35, 32, 20),
	BGDark   = Color3.fromRGB(18, 17, 10),
	Top      = Color3.fromRGB(30, 28, 17),
	Section  = Color3.fromRGB(32, 30, 18),
	Input    = Color3.fromRGB(20, 19, 12),
	Accent   = Color3.fromRGB(200, 165, 40),
	AccentD  = Color3.fromRGB(140, 110, 25),
	Border   = Color3.fromRGB(60, 54, 28),
	BorderD  = Color3.fromRGB(12, 11, 7),
	Text     = Color3.fromRGB(225, 218, 195),
	TextDim  = Color3.fromRGB(130, 122, 95),
	TextSec  = Color3.fromRGB(170, 162, 130),
	TogOff   = Color3.fromRGB(38, 35, 22),
	TogOn    = Color3.fromRGB(200, 165, 40),
	BtnBg    = Color3.fromRGB(42, 38, 24),
	BtnHov   = Color3.fromRGB(56, 51, 32),
}

-- ============================================================
-- NOTIFY
-- ============================================================
function lib:Notify(title, desc, dur)
	if type(desc) == "number" then dur = desc ; desc = nil end
	dur = dur or 4
	local h = desc and 58 or 38

	local gui = Instance.new("ScreenGui", CoreGui)
	gui.Name = "VNotif"
	gui.DisplayOrder = 99
	pcall(function() if syn then syn.protect_gui(gui) end end)

	local f = Instance.new("Frame", gui)
	f.Size = UDim2.fromOffset(270, h)
	f.Position = UDim2.new(1, 10, 1, -h-12)
	f.BackgroundColor3 = C.BGLight
	f.BorderSizePixel = 0
	corner(f, 5) ; stroke(f, C.Border)

	local bar = Instance.new("Frame", f)
	bar.Size = UDim2.fromOffset(2, h)
	bar.BackgroundColor3 = C.Accent
	bar.BorderSizePixel = 0
	corner(bar, 2)

	local tl = Instance.new("TextLabel", f)
	tl.Position = UDim2.fromOffset(10, desc and 6 or 11)
	tl.Size = UDim2.fromOffset(250, 16)
	tl.BackgroundTransparency = 1
	tl.Text = title or ""
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 13
	tl.TextColor3 = C.Text
	tl.TextXAlignment = Enum.TextXAlignment.Left

	if desc then
		local dl = Instance.new("TextLabel", f)
		dl.Position = UDim2.fromOffset(10, 24)
		dl.Size = UDim2.fromOffset(250, 28)
		dl.BackgroundTransparency = 1
		dl.Text = desc
		dl.Font = Enum.Font.Gotham
		dl.TextSize = 11
		dl.TextColor3 = C.TextSec
		dl.TextXAlignment = Enum.TextXAlignment.Left
		dl.TextWrapped = true
	end

	local pbg = Instance.new("Frame", f)
	pbg.Size = UDim2.fromOffset(270, 2)
	pbg.Position = UDim2.new(0,0,1,-2)
	pbg.BackgroundColor3 = C.BGDark
	pbg.BorderSizePixel = 0

	local pb = Instance.new("Frame", pbg)
	pb.Size = UDim2.fromScale(1,1)
	pb.BackgroundColor3 = C.Accent
	pb.BorderSizePixel = 0
	corner(pb, 2)

	tween(f, {Position = UDim2.new(1,-282,1,-h-12)}, 0.3)
	task.wait(0.32)
	tween(pb, {Size = UDim2.fromScale(0,1)}, dur)
	task.delay(dur, function()
		tween(f, {Position = UDim2.new(1,10,1,-h-12)}, 0.25)
		task.wait(0.3)
		gui:Destroy()
	end)
end

-- ============================================================
-- CREATE WINDOW
-- ============================================================
function lib:CreateWindow(cfg)
	cfg = cfg or {}
	local w = {}
	w.Title   = cfg.Title   or "Velocity"
	w.Sub     = cfg.SubTitle or ""
	w.HideKey = cfg.HideKey  or Enum.KeyCode.RightShift
	w.Tabs    = {}
	w.Size    = cfg.Size or Vector2.new(500, 380)

	-- ScreenGui
	local gui = Instance.new("ScreenGui", CoreGui)
	gui.Name = w.Title
	gui.DisplayOrder = 10
	gui.ResetOnSpawn = false
	pcall(function() if syn then syn.protect_gui(gui) end end)
	if getgenv then
		if getgenv().VeloUI then getgenv().VeloUI:Destroy() end
		getgenv().VeloUI = gui
	end
	w._gui = gui

	-- Frame principal
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.fromOffset(w.Size.X, w.Size.Y)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = C.BG
	main.BorderSizePixel = 0
	corner(main, 6)
	stroke(main, C.Border)
	w._main = main

	-- Topbar
	local top = Instance.new("Frame", main)
	top.Size = UDim2.new(1,0,0,40)
	top.BackgroundColor3 = C.Top
	top.BorderSizePixel = 0
	corner(top, 6)
	-- fill bottom corners du top
	local topFill = Instance.new("Frame", top)
	topFill.Size = UDim2.new(1,0,0,8)
	topFill.Position = UDim2.new(0,0,1,-8)
	topFill.BackgroundColor3 = C.Top
	topFill.BorderSizePixel = 0

	-- Ligne accent sous top
	local topLine = Instance.new("Frame", main)
	topLine.Size = UDim2.new(1,0,0,1)
	topLine.Position = UDim2.fromOffset(0,40)
	topLine.BackgroundColor3 = C.Accent
	topLine.BorderSizePixel = 0

	-- Title
	local titleLbl = Instance.new("TextLabel", top)
	titleLbl.Position = UDim2.fromOffset(10, 5)
	titleLbl.Size = UDim2.fromOffset(300, 18)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = w.Title
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextSize = 14
	titleLbl.TextColor3 = C.Text
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Subtitle
	local subLbl = Instance.new("TextLabel", top)
	subLbl.Position = UDim2.fromOffset(10, 22)
	subLbl.Size = UDim2.fromOffset(300, 14)
	subLbl.BackgroundTransparency = 1
	subLbl.Text = w.Sub
	subLbl.Font = Enum.Font.Gotham
	subLbl.TextSize = 10
	subLbl.TextColor3 = C.TextDim
	subLbl.TextXAlignment = Enum.TextXAlignment.Left

	-- Bouton Close
	local closeBtn = Instance.new("TextButton", top)
	closeBtn.Size = UDim2.fromOffset(18,18)
	closeBtn.Position = UDim2.new(1,-22,0,11)
	closeBtn.BackgroundColor3 = C.BGLight
	closeBtn.Text = "×"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 13
	closeBtn.TextColor3 = C.TextDim
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	corner(closeBtn, 3)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn,{TextColor3=Color3.fromRGB(220,70,70)}) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn,{TextColor3=C.TextDim}) end)
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	-- Bouton Minimize
	local minBtn = Instance.new("TextButton", top)
	minBtn.Size = UDim2.fromOffset(18,18)
	minBtn.Position = UDim2.new(1,-44,0,11)
	minBtn.BackgroundColor3 = C.BGLight
	minBtn.Text = "−"
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 13
	minBtn.TextColor3 = C.TextDim
	minBtn.BorderSizePixel = 0
	minBtn.AutoButtonColor = false
	corner(minBtn, 3)
	local minimized = false
	minBtn.MouseEnter:Connect(function() tween(minBtn,{TextColor3=C.Text}) end)
	minBtn.MouseLeave:Connect(function() tween(minBtn,{TextColor3=C.TextDim}) end)
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tween(main, {Size = minimized and UDim2.fromOffset(w.Size.X,40) or UDim2.fromOffset(w.Size.X,w.Size.Y)}, 0.2)
	end)

	-- Drag
	local dragging, dragStart, startPos
	top.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true ; dragStart = i.Position ; startPos = main.Position
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging=false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
		end
	end)

	-- Hide keybind
	UIS.InputBegan:Connect(function(k)
		if k.KeyCode == w.HideKey then main.Visible = not main.Visible end
	end)

	-- Tab bar
	local tabBar = Instance.new("Frame", main)
	tabBar.Size = UDim2.new(1,0,0,30)
	tabBar.Position = UDim2.fromOffset(0,41)
	tabBar.BackgroundColor3 = C.BGDark
	tabBar.BorderSizePixel = 0

	local tabLine = Instance.new("Frame", main)
	tabLine.Size = UDim2.new(1,0,0,1)
	tabLine.Position = UDim2.fromOffset(0,71)
	tabLine.BackgroundColor3 = C.Border
	tabLine.BorderSizePixel = 0

	local tabLayout = Instance.new("UIListLayout", tabBar)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0,2)
	local tabPad = Instance.new("UIPadding", tabBar)
	tabPad.PaddingLeft = UDim.new(0,6)
	tabPad.PaddingTop  = UDim.new(0,4)

	-- Footer
	local footer = Instance.new("TextLabel", main)
	footer.Size = UDim2.new(1,0,0,12)
	footer.Position = UDim2.new(0,0,1,-13)
	footer.BackgroundTransparency = 1
	footer.Text = w.Sub ~= "" and w.Sub or w.Title
	footer.Font = Enum.Font.Gotham
	footer.TextSize = 9
	footer.TextColor3 = C.TextDim

	-- Content area
	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1,0,1,-85)
	content.Position = UDim2.fromOffset(0,72)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	w._content = content

	-- ============================================================
	-- CREATE TAB
	-- ============================================================
	function w:CreateTab(name)
		local tab = {}
		tab.Name = name
		tab.Sections = {}

		-- Bouton tab
		local tbtn = Instance.new("TextButton", tabBar)
		tbtn.Text = name
		tbtn.Font = Enum.Font.GothamBold
		tbtn.TextSize = 12
		tbtn.TextColor3 = C.TextDim
		tbtn.AutoButtonColor = false
		tbtn.BackgroundColor3 = C.BGDark
		tbtn.BorderSizePixel = 0
		tbtn.Size = UDim2.fromOffset(#name*7+16, 22)
		corner(tbtn, 4)

		-- Indicator
		local ind = Instance.new("Frame", tbtn)
		ind.Size = UDim2.fromOffset(0,2)
		ind.Position = UDim2.new(0,0,1,0)
		ind.BackgroundColor3 = C.Accent
		ind.BorderSizePixel = 0
		corner(ind, 2)

		-- ScrollingFrame pour ce tab
		local scroll = Instance.new("ScrollingFrame", content)
		scroll.Size = UDim2.fromScale(1,1)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = C.Accent
		scroll.CanvasSize = UDim2.fromScale(0,0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = false

		local scrollLayout = Instance.new("UIListLayout", scroll)
		scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
		scrollLayout.Padding = UDim.new(0,8)
		local scrollPad = Instance.new("UIPadding", scroll)
		scrollPad.PaddingTop    = UDim.new(0,8)
		scrollPad.PaddingLeft   = UDim.new(0,8)
		scrollPad.PaddingRight  = UDim.new(0,8)
		scrollPad.PaddingBottom = UDim.new(0,8)

		tab._scroll = scroll
		tab._btn    = tbtn

		function tab:Select()
			for _,t in pairs(w.Tabs) do
				t._scroll.Visible = false
				tween(t._btn, {TextColor3=C.TextDim, BackgroundColor3=C.BGDark})
				tween(t._btn:FindFirstChild("Frame"), {Size=UDim2.fromOffset(0,2)})
			end
			scroll.Visible = true
			tween(tbtn, {TextColor3=C.Accent, BackgroundColor3=C.BGLight})
			tween(ind, {Size=UDim2.fromOffset(tbtn.AbsoluteSize.X,2)})
		end

		tbtn.MouseButton1Click:Connect(function() tab:Select() end)
		tbtn.MouseEnter:Connect(function() if not scroll.Visible then tween(tbtn,{TextColor3=C.TextSec}) end end)
		tbtn.MouseLeave:Connect(function() if not scroll.Visible then tween(tbtn,{TextColor3=C.TextDim}) end end)

		if #w.Tabs == 0 then tab:Select() end
		table.insert(w.Tabs, tab)

		-- ============================================================
		-- CREATE SECTION
		-- ============================================================
		function tab:CreateSection(name)
			local sec = {}

			local frame = Instance.new("Frame", scroll)
			frame.Size = UDim2.new(1,0,0,28)
			frame.AutomaticSize = Enum.AutomaticSize.Y
			frame.BackgroundColor3 = C.Section
			frame.BorderSizePixel = 0
			corner(frame, 5)
			stroke(frame, C.Border)

			-- Header section
			local hdr = Instance.new("Frame", frame)
			hdr.Size = UDim2.new(1,0,0,24)
			hdr.BackgroundColor3 = C.BGDark
			hdr.BorderSizePixel = 0
			corner(hdr, 5)
			local hdrFill = Instance.new("Frame", hdr)
			hdrFill.Size = UDim2.new(1,0,0,6)
			hdrFill.Position = UDim2.new(0,0,1,-6)
			hdrFill.BackgroundColor3 = C.BGDark
			hdrFill.BorderSizePixel = 0

			-- Barre accent gauche dans header
			local acBar = Instance.new("Frame", hdr)
			acBar.Size = UDim2.fromOffset(2,12)
			acBar.Position = UDim2.fromOffset(8,6)
			acBar.BackgroundColor3 = C.Accent
			acBar.BorderSizePixel = 0
			corner(acBar, 2)

			local hdrTitle = Instance.new("TextLabel", hdr)
			hdrTitle.Position = UDim2.fromOffset(16,0)
			hdrTitle.Size = UDim2.new(1,-30,1,0)
			hdrTitle.BackgroundTransparency = 1
			hdrTitle.Text = name
			hdrTitle.Font = Enum.Font.GothamBold
			hdrTitle.TextSize = 12
			hdrTitle.TextColor3 = C.Text
			hdrTitle.TextXAlignment = Enum.TextXAlignment.Left

			-- Bouton collapse
			local colBtn = Instance.new("TextButton", hdr)
			colBtn.Size = UDim2.fromOffset(16,16)
			colBtn.Position = UDim2.new(1,-20,0,4)
			colBtn.BackgroundTransparency = 1
			colBtn.Text = "−"
			colBtn.Font = Enum.Font.GothamBold
			colBtn.TextSize = 12
			colBtn.TextColor3 = C.TextDim
			colBtn.BorderSizePixel = 0
			local collapsed = false
			colBtn.MouseButton1Click:Connect(function()
				collapsed = not collapsed
				sec._items.Visible = not collapsed
				colBtn.Text = collapsed and "+" or "−"
			end)

			-- Items container
			local items = Instance.new("Frame", frame)
			items.Position = UDim2.fromOffset(0,25)
			items.Size = UDim2.new(1,0,0,0)
			items.AutomaticSize = Enum.AutomaticSize.Y
			items.BackgroundTransparency = 1
			items.BorderSizePixel = 0

			local itemsLayout = Instance.new("UIListLayout", items)
			itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			itemsLayout.Padding = UDim.new(0,4)
			local itemsPad = Instance.new("UIPadding", items)
			itemsPad.PaddingTop    = UDim.new(0,6)
			itemsPad.PaddingBottom = UDim.new(0,8)
			itemsPad.PaddingLeft   = UDim.new(0,8)
			itemsPad.PaddingRight  = UDim.new(0,8)

			sec._frame = frame
			sec._items = items

			-- ================================================================
			-- LABEL
			-- ================================================================
			function sec:AddLabel(text, color)
				local lbl = {}
				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local t = Instance.new("TextLabel", row)
				t.Size = UDim2.new(1,0,0,0)
				t.AutomaticSize = Enum.AutomaticSize.Y
				t.BackgroundTransparency = 1
				t.Text = text or ""
				t.Font = Enum.Font.Gotham
				t.TextSize = 11
				t.TextColor3 = color or C.TextSec
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.TextWrapped = true

				function lbl:Set(v) t.Text = tostring(v) end
				function lbl:SetColor(c) t.TextColor3 = c end
				function lbl:SetVisible(v) row.Visible = v end
				return lbl
			end

			-- ================================================================
			-- PARAGRAPH
			-- ================================================================
			function sec:AddParagraph(title, content)
				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,0)
				row.AutomaticSize = Enum.AutomaticSize.Y
				row.BackgroundColor3 = C.Input
				row.BorderSizePixel = 0
				corner(row, 4)
				local rPad = Instance.new("UIPadding", row)
				rPad.PaddingTop=UDim.new(0,5) ; rPad.PaddingBottom=UDim.new(0,6)
				rPad.PaddingLeft=UDim.new(0,7) ; rPad.PaddingRight=UDim.new(0,7)
				local rL = Instance.new("UIListLayout", row)
				rL.SortOrder = Enum.SortOrder.LayoutOrder
				rL.Padding   = UDim.new(0,2)

				local p = {}
				if title and title ~= "" then
					local tl = Instance.new("TextLabel", row)
					tl.Size = UDim2.new(1,0,0,14)
					tl.BackgroundTransparency = 1
					tl.Text = title
					tl.Font = Enum.Font.GothamBold
					tl.TextSize = 12
					tl.TextColor3 = C.Accent
					tl.TextXAlignment = Enum.TextXAlignment.Left
					p.TitleLbl = tl
				end
				if content and content ~= "" then
					local cl = Instance.new("TextLabel", row)
					cl.Size = UDim2.new(1,0,0,0)
					cl.AutomaticSize = Enum.AutomaticSize.Y
					cl.BackgroundTransparency = 1
					cl.Text = content
					cl.Font = Enum.Font.Gotham
					cl.TextSize = 11
					cl.TextColor3 = C.TextSec
					cl.TextXAlignment = Enum.TextXAlignment.Left
					cl.TextWrapped = true
					p.ContentLbl = cl
				end
				function p:Set(t2, c2)
					if p.TitleLbl   and t2 then p.TitleLbl.Text   = t2 end
					if p.ContentLbl and c2 then p.ContentLbl.Text = c2 end
				end
				return p
			end

			-- ================================================================
			-- SEPARATOR
			-- ================================================================
			function sec:AddSeparator(text)
				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,14)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local line = Instance.new("Frame", row)
				line.Size = UDim2.new(1,0,0,1)
				line.Position = UDim2.new(0,0,0.5,0)
				line.BackgroundColor3 = C.Border
				line.BorderSizePixel = 0

				if text and text ~= "" then
					local bg = Instance.new("Frame", row)
					bg.Size = UDim2.fromOffset(#text*6+12, 13)
					bg.Position = UDim2.new(0.5,-#text*3-6,0,0)
					bg.BackgroundColor3 = C.Section
					bg.BorderSizePixel = 0
					local sl = Instance.new("TextLabel", bg)
					sl.Size = UDim2.fromScale(1,1)
					sl.BackgroundTransparency = 1
					sl.Text = text
					sl.Font = Enum.Font.Gotham
					sl.TextSize = 10
					sl.TextColor3 = C.TextDim
				end
			end

			-- ================================================================
			-- BUTTON
			-- ================================================================
			function sec:AddButton(text, callback)
				callback = callback or function() end
				local row = Instance.new("TextButton", items)
				row.Size = UDim2.new(1,0,0,26)
				row.BackgroundColor3 = C.BtnBg
				row.BorderSizePixel = 0
				row.AutoButtonColor = false
				row.Text = ""
				corner(row, 4)
				stroke(row, C.Border)

				local icon = Instance.new("TextLabel", row)
				icon.Size = UDim2.fromOffset(18,26)
				icon.Position = UDim2.fromOffset(4,0)
				icon.BackgroundTransparency = 1
				icon.Text = "▶"
				icon.Font = Enum.Font.GothamBold
				icon.TextSize = 8
				icon.TextColor3 = C.Accent

				local lbl = Instance.new("TextLabel", row)
				lbl.Position = UDim2.fromOffset(20,0)
				lbl.Size = UDim2.new(1,-20,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.GothamBold
				lbl.TextSize = 12
				lbl.TextColor3 = C.Text
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				row.MouseEnter:Connect(function()
					tween(row,{BackgroundColor3=C.BtnHov})
					tween(lbl,{TextColor3=C.Accent})
				end)
				row.MouseLeave:Connect(function()
					tween(row,{BackgroundColor3=C.BtnBg})
					tween(lbl,{TextColor3=C.Text})
				end)
				row.MouseButton1Down:Connect(function() tween(row,{BackgroundColor3=C.AccentD}) end)
				row.MouseButton1Up:Connect(function()
					tween(row,{BackgroundColor3=C.BtnHov})
					pcall(callback)
				end)

				local btn = {}
				function btn:SetText(t) lbl.Text = t end
				table.insert(lib.Items, btn)
				return btn
			end

			-- ================================================================
			-- TOGGLE
			-- ================================================================
			function sec:AddToggle(text, default, callback, flag)
				callback = callback or function() end
				flag     = flag or text
				default  = default or false

				local toggle = {value=default, flag=flag}

				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,24)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				-- Checkbox style Velocity (carré)
				local box = Instance.new("Frame", row)
				box.Size = UDim2.fromOffset(13,13)
				box.Position = UDim2.fromOffset(0,5)
				box.BackgroundColor3 = default and C.TogOn or C.TogOff
				box.BorderSizePixel = 0
				corner(box, 2)
				stroke(box, C.Border)

				local check = Instance.new("TextLabel", box)
				check.Size = UDim2.fromScale(1,1)
				check.BackgroundTransparency = 1
				check.Text = "✓"
				check.Font = Enum.Font.GothamBold
				check.TextSize = 9
				check.TextColor3 = C.BGDark
				check.TextTransparency = default and 0 or 1

				local lbl = Instance.new("TextLabel", row)
				lbl.Position = UDim2.fromOffset(19,0)
				lbl.Size = UDim2.new(1,-75,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = default and C.Text or C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				-- Zone extras droite (keybind, colorpicker)
				local extras = Instance.new("Frame", row)
				extras.Size = UDim2.fromOffset(70,24)
				extras.Position = UDim2.new(1,-70,0,0)
				extras.BackgroundTransparency = 1
				extras.BorderSizePixel = 0
				local eL = Instance.new("UIListLayout", extras)
				eL.FillDirection = Enum.FillDirection.Horizontal
				eL.HorizontalAlignment = Enum.HorizontalAlignment.Right
				eL.VerticalAlignment   = Enum.VerticalAlignment.Center
				eL.SortOrder = Enum.SortOrder.LayoutOrder
				eL.Padding   = UDim.new(0,4)
				toggle._extras = extras

				lib.Flags[flag] = default

				function toggle:Set(v)
					toggle.value = v
					lib.Flags[flag] = v
					tween(box, {BackgroundColor3 = v and C.TogOn or C.TogOff})
					tween(check, {TextTransparency = v and 0 or 1})
					tween(lbl, {TextColor3 = v and C.Text or C.TextSec})
					pcall(callback, v)
				end
				function toggle:Get() return toggle.value end

				-- Hitbox
				local hit = Instance.new("TextButton", row)
				hit.Size = UDim2.new(1,-75,1,0)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.ZIndex = 3
				hit.MouseButton1Click:Connect(function() toggle:Set(not toggle.value) end)
				hit.MouseEnter:Connect(function()
					if not toggle.value then tween(box,{BackgroundColor3=C.BtnHov}) end
				end)
				hit.MouseLeave:Connect(function()
					if not toggle.value then tween(box,{BackgroundColor3=C.TogOff}) end
				end)

				-- AddKeybind sur toggle
				function toggle:AddKeybind(kbDef, kbFlag)
					kbDef  = kbDef  or "None"
					kbFlag = kbFlag or (text.."_kb")
					local kb = {value=kbDef, flag=kbFlag}

					local kbBtn = Instance.new("TextButton", extras)
					kbBtn.Size = UDim2.fromOffset(52,16)
					kbBtn.BackgroundColor3 = C.Input
					kbBtn.BorderSizePixel = 0
					kbBtn.Text = kbDef=="None" and "[None]" or "["..tostring(typeof(kbDef)=="EnumItem" and kbDef.Name or kbDef).."]"
					kbBtn.Font = Enum.Font.Gotham
					kbBtn.TextSize = 10
					kbBtn.TextColor3 = C.TextDim
					kbBtn.AutoButtonColor = false
					corner(kbBtn, 3)
					stroke(kbBtn, C.Border)

					lib.Flags[kbFlag] = kbDef

					function kb:Set(v)
						kb.value = v
						lib.Flags[kbFlag] = v
						if v == "None" or v == nil then kbBtn.Text = "[None]"
						elseif typeof(v)=="EnumItem" then kbBtn.Text = "["..v.Name.."]"
						else kbBtn.Text = "["..tostring(v).."]" end
					end

					kbBtn.MouseButton1Click:Connect(function()
						kbBtn.Text = "[...]"
						kbBtn.TextColor3 = C.Accent
					end)
					UIS.InputBegan:Connect(function(i, gp)
						if not gp then
							if kbBtn.Text == "[...]" then
								kbBtn.TextColor3 = C.TextDim
								local v
								if i.UserInputType == Enum.UserInputType.Keyboard then v = i.KeyCode
								elseif i.UserInputType == Enum.UserInputType.MouseButton1 then v = "MB1"
								elseif i.UserInputType == Enum.UserInputType.MouseButton2 then v = "MB2"
								else v = "None" end
								kb:Set(v)
							elseif kb.value ~= "None" and kb.value ~= nil then
								if typeof(kb.value)=="EnumItem" and i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==kb.value then
									toggle:Set(not toggle.value)
								end
							end
						end
					end)

					table.insert(lib.Items, kb)
					return kb
				end

				-- AddColorpicker sur toggle
				function toggle:AddColorpicker(cpDef, cpCb, cpFlag)
					cpDef   = cpDef   or Color3.fromRGB(255,255,255)
					cpCb    = cpCb    or function() end
					cpFlag  = cpFlag  or (text.."_cp")
					return sec:_CP(extras, cpDef, cpCb, cpFlag)
				end

				table.insert(lib.Items, toggle)
				return toggle
			end

			-- ================================================================
			-- SLIDER
			-- ================================================================
			function sec:AddSlider(text, opts)
				opts = opts or {}
				local min  = opts.Min      or 0
				local max  = opts.Max      or 100
				local def  = opts.Default  or min
				local dec  = opts.Decimals or 1
				local suf  = opts.Suffix   or ""
				local flag = opts.Flag     or text
				local cb   = opts.Callback or function() end
				local drag = false

				local slider = {value=def, flag=flag}

				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,34)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local topRow = Instance.new("Frame", row)
				topRow.Size = UDim2.new(1,0,0,14)
				topRow.BackgroundTransparency = 1
				topRow.BorderSizePixel = 0

				local lbl = Instance.new("TextLabel", topRow)
				lbl.Size = UDim2.new(1,-60,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local valBox = Instance.new("TextBox", topRow)
				valBox.Size = UDim2.fromOffset(55,14)
				valBox.Position = UDim2.new(1,-55,0,0)
				valBox.BackgroundColor3 = C.Input
				valBox.Text = tostring(def)..suf
				valBox.Font = Enum.Font.Gotham
				valBox.TextSize = 11
				valBox.TextColor3 = C.Accent
				valBox.BorderSizePixel = 0
				valBox.ClearTextOnFocus = false
				corner(valBox, 3)

				local track = Instance.new("Frame", row)
				track.Size = UDim2.new(1,0,0,7)
				track.Position = UDim2.fromOffset(0,20)
				track.BackgroundColor3 = C.Input
				track.BorderSizePixel = 0
				corner(track, 4)
				stroke(track, C.Border)

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.fromOffset(0,7)
				fill.BackgroundColor3 = C.Accent
				fill.BorderSizePixel = 0
				corner(fill, 4)

				local knob = Instance.new("Frame", fill)
				knob.Size = UDim2.fromOffset(9,9)
				knob.Position = UDim2.new(1,-4,0.5,-4)
				knob.BackgroundColor3 = C.Text
				knob.BorderSizePixel = 0
				corner(knob, 5)

				lib.Flags[flag] = def

				function slider:Set(v)
					v = math.clamp(math.floor(v*dec+0.5)/dec, min, max)
					slider.value = v
					local pct = (v-min)/(max-min)
					tween(fill, {Size=UDim2.fromOffset(pct*track.AbsoluteSize.X, 7)}, 0.06)
					valBox.Text = tostring(v)..suf
					lib.Flags[flag] = v
					pcall(cb, v)
				end
				function slider:Get() return slider.value end
				slider:Set(def)

				local function refresh()
					local mp = UIS:GetMouseLocation()
					local pct = math.clamp((mp.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					slider:Set(min + (max-min)*pct)
				end

				track.InputBegan:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true ; refresh() end
				end)
				UIS.InputChanged:Connect(function(i)
					if drag and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
				end)
				valBox.FocusLost:Connect(function(enter)
					if enter then
						local n = tonumber(valBox.Text:gsub(suf,""))
						if n then slider:Set(n) else valBox.Text=tostring(slider.value)..suf end
					end
				end)

				table.insert(lib.Items, slider)
				return slider
			end

			-- ================================================================
			-- DROPDOWN
			-- ================================================================
			function sec:AddDropdown(text, list, default, multi, callback, flag)
				callback = callback or function() end
				flag     = flag or text
				list     = list or {}
				local dd = {values={}, flag=flag}
				local open = false

				local wrap = Instance.new("Frame", items)
				wrap.Size = UDim2.new(1,0,0,38)
				wrap.BackgroundTransparency = 1
				wrap.BorderSizePixel = 0
				wrap.ClipsDescendants = false
				wrap.ZIndex = 5

				local lbl = Instance.new("TextLabel", wrap)
				lbl.Size = UDim2.new(1,0,0,13)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 11
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left
				lbl.ZIndex = 5

				local btn = Instance.new("TextButton", wrap)
				btn.Size = UDim2.new(1,0,0,21)
				btn.Position = UDim2.fromOffset(0,14)
				btn.BackgroundColor3 = C.Input
				btn.BorderSizePixel = 0
				btn.AutoButtonColor = false
				btn.Text = ""
				btn.ZIndex = 5
				corner(btn, 4)
				stroke(btn, C.Border)

				local selLbl = Instance.new("TextLabel", btn)
				selLbl.Position = UDim2.fromOffset(6,0)
				selLbl.Size = UDim2.new(1,-20,1,0)
				selLbl.BackgroundTransparency = 1
				selLbl.Text = default or list[1] or text
				selLbl.Font = Enum.Font.Gotham
				selLbl.TextSize = 11
				selLbl.TextColor3 = C.Text
				selLbl.TextXAlignment = Enum.TextXAlignment.Left
				selLbl.ZIndex = 6

				local arrow = Instance.new("TextLabel", btn)
				arrow.Position = UDim2.new(1,-16,0,0)
				arrow.Size = UDim2.fromOffset(14,21)
				arrow.BackgroundTransparency = 1
				arrow.Text = "▾"
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 11
				arrow.TextColor3 = C.Accent
				arrow.ZIndex = 6

				-- Liste déroulante
				local ddList = Instance.new("ScrollingFrame", wrap)
				ddList.Size = UDim2.new(1,0,0,0)
				ddList.Position = UDim2.fromOffset(0,37)
				ddList.BackgroundColor3 = C.BGDark
				ddList.BorderSizePixel = 0
				ddList.ScrollBarThickness = 2
				ddList.ScrollBarImageColor3 = C.Accent
				ddList.ZIndex = 20
				ddList.Visible = false
				ddList.CanvasSize = UDim2.fromScale(0,0)
				ddList.AutomaticCanvasSize = Enum.AutomaticSize.Y
				corner(ddList, 4)
				stroke(ddList, C.Accent)

				local ddLayout = Instance.new("UIListLayout", ddList)
				ddLayout.SortOrder = Enum.SortOrder.LayoutOrder
				local ddPad = Instance.new("UIPadding", ddList)
				ddPad.PaddingTop=UDim.new(0,2) ; ddPad.PaddingBottom=UDim.new(0,2)
				ddPad.PaddingLeft=UDim.new(0,2) ; ddPad.PaddingRight=UDim.new(0,2)

				lib.Flags[flag] = multi and {} or (default or list[1] or "")

				function dd:isSelected(v)
					for _,x in pairs(dd.values) do if x==v then return true end end
					return false
				end
				function dd:UpdateDisplay()
					selLbl.Text = #dd.values>0 and table.concat(dd.values,", ") or text
				end
				function dd:Set(v)
					if multi then
						if type(v)=="table" then dd.values=v
						else
							if dd:isSelected(v) then
								for i,x in ipairs(dd.values) do if x==v then table.remove(dd.values,i) break end end
							else table.insert(dd.values,v) end
						end
						lib.Flags[flag]=dd.values ; pcall(callback,dd.values)
					else
						dd.values={v} ; lib.Flags[flag]=v ; pcall(callback,v)
					end
					dd:UpdateDisplay()
				end
				function dd:Get() return multi and dd.values or dd.values[1] end
				function dd:Add(v)
					local item = Instance.new("TextButton", ddList)
					item.Size = UDim2.new(1,0,0,20)
					item.BackgroundColor3 = C.BGLight
					item.BorderSizePixel = 0
					item.AutoButtonColor = false
					item.Text = ""
					item.ZIndex = 21
					corner(item, 3)
					local il = Instance.new("TextLabel", item)
					il.Position = UDim2.fromOffset(6,0)
					il.Size = UDim2.new(1,-6,1,0)
					il.BackgroundTransparency = 1
					il.Text = v
					il.Font = Enum.Font.Gotham
					il.TextSize = 11
					il.TextColor3 = C.TextSec
					il.TextXAlignment = Enum.TextXAlignment.Left
					il.ZIndex = 22

					RunService.RenderStepped:Connect(function()
						local sel = dd:isSelected(v)
						il.TextColor3 = sel and C.Accent or C.TextSec
						item.BackgroundColor3 = sel and C.BtnHov or C.BGLight
					end)
					item.MouseButton1Click:Connect(function()
						dd:Set(v)
						if not multi then
							open=false
							tween(ddList,{Size=UDim2.new(1,0,0,0)},0.12)
							task.wait(0.13) ; ddList.Visible=false
							wrap.Size=UDim2.new(1,0,0,38)
							tween(arrow,{Rotation=0})
						end
					end)
					item.MouseEnter:Connect(function() if not dd:isSelected(v) then tween(item,{BackgroundColor3=C.BtnBg}) end end)
					item.MouseLeave:Connect(function() if not dd:isSelected(v) then tween(item,{BackgroundColor3=C.BGLight}) end end)
				end

				for _,v in ipairs(list) do dd:Add(v) end
				if default then dd:Set(default) end

				local function toggleDD()
					open = not open
					if open then
						ddList.Visible=true
						local h = math.min(#list*21+4, 120)
						tween(ddList,{Size=UDim2.new(1,0,0,h)},0.12)
						wrap.Size=UDim2.new(1,0,0,38+h+2)
						tween(arrow,{Rotation=180})
					else
						tween(ddList,{Size=UDim2.new(1,0,0,0)},0.12)
						wrap.Size=UDim2.new(1,0,0,38)
						tween(arrow,{Rotation=0})
						task.wait(0.13) ; ddList.Visible=false
					end
				end
				btn.MouseButton1Click:Connect(toggleDD)
				btn.MouseEnter:Connect(function() tween(btn,{BackgroundColor3=C.BtnBg}) end)
				btn.MouseLeave:Connect(function() tween(btn,{BackgroundColor3=C.Input}) end)

				table.insert(lib.Items, dd)
				return dd
			end

			-- ================================================================
			-- TEXTBOX
			-- ================================================================
			function sec:AddTextbox(text, placeholder, default, callback, flag)
				callback = callback or function() end
				flag     = flag or text
				default  = default or ""
				local tb = {value=default, flag=flag}

				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,38)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1,0,0,13)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 11
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local box = Instance.new("TextBox", row)
				box.Size = UDim2.new(1,0,0,21)
				box.Position = UDim2.fromOffset(0,14)
				box.BackgroundColor3 = C.Input
				box.BorderSizePixel = 0
				box.PlaceholderText = placeholder or text
				box.PlaceholderColor3 = C.TextDim
				box.Text = default
				box.Font = Enum.Font.Gotham
				box.TextSize = 11
				box.TextColor3 = C.Text
				box.ClearTextOnFocus = false
				corner(box, 4)
				stroke(box, C.Border)
				local bp = Instance.new("UIPadding", box)
				bp.PaddingLeft=UDim.new(0,6)

				lib.Flags[flag] = default
				function tb:Set(v) tb.value=v ; box.Text=v ; lib.Flags[flag]=v ; pcall(callback,v) end
				function tb:Get() return tb.value end
				box.Focused:Connect(function() tween(box,{BackgroundColor3=C.BtnBg}) end)
				box.FocusLost:Connect(function(enter)
					tween(box,{BackgroundColor3=C.Input})
					if enter then tb:Set(box.Text) end
				end)
				table.insert(lib.Items, tb)
				return tb
			end

			-- ================================================================
			-- KEYBIND
			-- ================================================================
			function sec:AddKeybind(text, default, onNew, onTrig, flag)
				onNew  = onNew  or function() end
				onTrig = onTrig or function() end
				flag   = flag   or text
				default= default or "None"
				local kb = {value=default, flag=flag}

				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,22)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1,-70,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local kbBtn = Instance.new("TextButton", row)
				kbBtn.Size = UDim2.fromOffset(65,18)
				kbBtn.Position = UDim2.new(1,-65,0,2)
				kbBtn.BackgroundColor3 = C.Input
				kbBtn.BorderSizePixel = 0
				kbBtn.Text = default=="None" and "[None]" or "["..tostring(typeof(default)=="EnumItem" and default.Name or default).."]"
				kbBtn.Font = Enum.Font.Gotham
				kbBtn.TextSize = 10
				kbBtn.TextColor3 = C.TextDim
				kbBtn.AutoButtonColor = false
				corner(kbBtn, 3)
				stroke(kbBtn, C.Border)

				lib.Flags[flag] = default
				function kb:Set(v)
					kb.value=v ; lib.Flags[flag]=v
					if v=="None" or v==nil then kbBtn.Text="[None]"
					elseif typeof(v)=="EnumItem" then kbBtn.Text="["..v.Name.."]"
					else kbBtn.Text="["..tostring(v).."]" end
					pcall(onNew, v)
				end
				function kb:Get() return kb.value end

				kbBtn.MouseButton1Click:Connect(function()
					kbBtn.Text="[...]" ; kbBtn.TextColor3=C.Accent
				end)
				UIS.InputBegan:Connect(function(i, gp)
					if not gp then
						if kbBtn.Text=="[...]" then
							kbBtn.TextColor3=C.TextDim
							local v
							if i.UserInputType==Enum.UserInputType.Keyboard then v=i.KeyCode
							elseif i.UserInputType==Enum.UserInputType.MouseButton1 then v="MB1"
							elseif i.UserInputType==Enum.UserInputType.MouseButton2 then v="MB2"
							else v="None" end
							kb:Set(v)
						elseif kb.value~="None" and typeof(kb.value)=="EnumItem" then
							if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==kb.value then
								pcall(onTrig)
							end
						end
					end
				end)
				kbBtn.MouseEnter:Connect(function() tween(kbBtn,{BackgroundColor3=C.BtnBg}) end)
				kbBtn.MouseLeave:Connect(function() tween(kbBtn,{BackgroundColor3=C.Input}) end)

				table.insert(lib.Items, kb)
				return kb
			end

			-- ================================================================
			-- COLOR PICKER (interne)
			-- ================================================================
			function sec:_CP(parent, default, callback, flag)
				default  = default  or Color3.fromRGB(255,255,255)
				callback = callback or function() end
				flag     = flag     or "color"
				local cp = {value=default, color=0}

				local preview = Instance.new("Frame", parent)
				preview.Size = UDim2.fromOffset(18,12)
				preview.BackgroundColor3 = default
				preview.BorderSizePixel = 0
				corner(preview, 3)
				stroke(preview, C.Border)

				local grad = Instance.new("UIGradient", preview)
				local function updatePreview(c)
					grad.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,c),
						ColorSequenceKeypoint.new(1,Color3.new(math.clamp(c.R/1.7,0,1),math.clamp(c.G/1.7,0,1),math.clamp(c.B/1.7,0,1)))
					})
					grad.Rotation = 90
				end
				updatePreview(default)

				-- Popup picker
				local picker = Instance.new("TextButton", main)
				picker.Size = UDim2.fromOffset(188,208)
				picker.BackgroundColor3 = C.BGLight
				picker.BorderSizePixel = 0
				picker.Text = ""
				picker.AutoButtonColor = false
				picker.ZIndex = 50
				picker.Visible = false
				corner(picker, 5)
				stroke(picker, C.Accent)

				local hsvImg = Instance.new("ImageLabel", picker)
				hsvImg.Size = UDim2.fromOffset(176,148)
				hsvImg.Position = UDim2.fromOffset(6,6)
				hsvImg.Image = "rbxassetid://4155801252"
				hsvImg.BackgroundColor3 = Color3.new(1,0,0)
				hsvImg.BorderSizePixel = 0
				hsvImg.ZIndex = 51
				corner(hsvImg, 3)

				local hsvPtr = Instance.new("Frame", picker)
				hsvPtr.Size = UDim2.fromOffset(8,8)
				hsvPtr.BackgroundColor3 = C.Text
				hsvPtr.BorderSizePixel = 0
				hsvPtr.ZIndex = 52
				corner(hsvPtr, 4)

				local hueBar = Instance.new("Frame", picker)
				hueBar.Size = UDim2.fromOffset(176,10)
				hueBar.Position = UDim2.fromOffset(6,158)
				hueBar.BackgroundColor3 = Color3.new(1,1,1)
				hueBar.BorderSizePixel = 0
				hueBar.ZIndex = 51
				corner(hueBar, 5)
				local hueGrad = Instance.new("UIGradient", hueBar)
				hueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),
					ColorSequenceKeypoint.new(0.17,Color3.new(1,0,1)),
					ColorSequenceKeypoint.new(0.33,Color3.new(0,0,1)),
					ColorSequenceKeypoint.new(0.5,Color3.new(0,1,1)),
					ColorSequenceKeypoint.new(0.67,Color3.new(0,1,0)),
					ColorSequenceKeypoint.new(0.83,Color3.new(1,1,0)),
					ColorSequenceKeypoint.new(1,Color3.new(1,0,0)),
				})

				local huePtr = Instance.new("Frame", picker)
				huePtr.Size = UDim2.fromOffset(3,10)
				huePtr.Position = UDim2.fromOffset(6,158)
				huePtr.BackgroundColor3 = C.Text
				huePtr.BorderSizePixel = 0
				huePtr.ZIndex = 52

				local hexBox = Instance.new("TextBox", picker)
				hexBox.Size = UDim2.fromOffset(176,18)
				hexBox.Position = UDim2.fromOffset(6,173)
				hexBox.BackgroundColor3 = C.Input
				hexBox.BorderSizePixel = 0
				hexBox.PlaceholderText = "#FFFFFF"
				hexBox.Text = "#FFFFFF"
				hexBox.Font = Enum.Font.Gotham
				hexBox.TextSize = 11
				hexBox.TextColor3 = C.Text
				hexBox.ZIndex = 52
				hexBox.ClearTextOnFocus = false
				corner(hexBox, 3)
				local hp = Instance.new("UIPadding", hexBox)
				hp.PaddingLeft = UDim.new(0,6)

				lib.Flags[flag] = default

				function cp:Set(c)
					c = Color3.new(math.clamp(c.R,0,1),math.clamp(c.G,0,1),math.clamp(c.B,0,1))
					cp.value = c
					preview.BackgroundColor3 = c
					updatePreview(c)
					lib.Flags[flag] = c
					hexBox.Text = "#"..string.format("%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
					pcall(callback, c)
				end
				function cp:Get() return cp.value end
				cp:Set(default)

				local function refreshHSV()
					local mp = UIS:GetMouseLocation()
					local x = math.clamp((mp.X-hsvImg.AbsolutePosition.X)/hsvImg.AbsoluteSize.X,0,1)
					local y = math.clamp((mp.Y-hsvImg.AbsolutePosition.Y)/hsvImg.AbsoluteSize.Y,0,1)
					hsvPtr.Position = UDim2.fromOffset(6+x*hsvImg.AbsoluteSize.X-4, 6+y*hsvImg.AbsoluteSize.Y-4)
					cp:Set(Color3.fromHSV(cp.color,x,1-y))
				end
				local function refreshHue()
					local mp = UIS:GetMouseLocation()
					local x = math.clamp((mp.X-hueBar.AbsolutePosition.X)/hueBar.AbsoluteSize.X,0,1)
					cp.color = 1-x
					huePtr.Position = UDim2.fromOffset(6+x*hueBar.AbsoluteSize.X-1, 158)
					hsvImg.BackgroundColor3 = Color3.fromHSV(1-x,1,1)
					refreshHSV()
				end

				local dHSV,dHue = false,false
				hsvImg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHSV=true;refreshHSV() end end)
				hsvImg.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHSV=false end end)
				hueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHue=true;refreshHue() end end)
				hueBar.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dHue=false end end)
				UIS.InputChanged:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseMovement then
						if dHSV then refreshHSV() end
						if dHue then refreshHue() end
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType==Enum.UserInputType.MouseButton1 then dHSV=false;dHue=false end
				end)
				hexBox.FocusLost:Connect(function(enter)
					if enter then
						local hex = hexBox.Text:gsub("#","")
						if #hex==6 then
							cp:Set(Color3.fromRGB(
								tonumber(hex:sub(1,2),16)or 0,
								tonumber(hex:sub(3,4),16)or 0,
								tonumber(hex:sub(5,6),16)or 0
							))
						end
					end
				end)

				local previewBtn = Instance.new("TextButton", preview)
				previewBtn.Size = UDim2.fromScale(1,1)
				previewBtn.BackgroundTransparency = 1
				previewBtn.Text = ""
				previewBtn.ZIndex = 60
				previewBtn.MouseButton1Click:Connect(function()
					picker.Visible = not picker.Visible
					if picker.Visible then
						local ap = preview.AbsolutePosition
						local mp = main.AbsolutePosition
						picker.Position = UDim2.fromOffset(
							math.clamp(ap.X-mp.X-90, 5, w.Size.X-195),
							math.clamp(ap.Y-mp.Y+16, 5, w.Size.Y-215)
						)
					end
				end)

				table.insert(lib.Items, cp)
				return cp
			end

			-- ================================================================
			-- COLORPICKER (niveau section)
			-- ================================================================
			function sec:AddColorpicker(text, default, callback, flag)
				flag = flag or text
				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,22)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1,-24,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local cpHolder = Instance.new("Frame", row)
				cpHolder.Size = UDim2.fromOffset(20,22)
				cpHolder.Position = UDim2.new(1,-20,0,0)
				cpHolder.BackgroundTransparency = 1
				cpHolder.BorderSizePixel = 0

				return sec:_CP(cpHolder, default, callback, flag)
			end

			-- ================================================================
			-- SWITCH (toggle style on/off)
			-- ================================================================
			function sec:AddSwitch(text, default, callback, flag)
				callback = callback or function() end
				flag     = flag or text
				default  = default or false
				local sw = {value=default, flag=flag}

				local row = Instance.new("Frame", items)
				row.Size = UDim2.new(1,0,0,22)
				row.BackgroundTransparency = 1
				row.BorderSizePixel = 0

				local lbl = Instance.new("TextLabel", row)
				lbl.Size = UDim2.new(1,-44,1,0)
				lbl.BackgroundTransparency = 1
				lbl.Text = text
				lbl.Font = Enum.Font.Gotham
				lbl.TextSize = 12
				lbl.TextColor3 = C.TextSec
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local track = Instance.new("Frame", row)
				track.Size = UDim2.fromOffset(32,15)
				track.Position = UDim2.new(1,-32,0,3)
				track.BackgroundColor3 = default and C.Accent or C.TogOff
				track.BorderSizePixel = 0
				corner(track, 8)
				stroke(track, C.Border)

				local knob = Instance.new("Frame", track)
				knob.Size = UDim2.fromOffset(9,9)
				knob.Position = default and UDim2.fromOffset(20,3) or UDim2.fromOffset(3,3)
				knob.BackgroundColor3 = default and C.BGDark or C.TextDim
				knob.BorderSizePixel = 0
				corner(knob, 5)

				lib.Flags[flag] = default
				function sw:Set(v)
					sw.value=v ; lib.Flags[flag]=v
					tween(track,{BackgroundColor3=v and C.Accent or C.TogOff})
					tween(knob,{Position=v and UDim2.fromOffset(20,3) or UDim2.fromOffset(3,3), BackgroundColor3=v and C.BGDark or C.TextDim})
					tween(lbl,{TextColor3=v and C.Text or C.TextSec})
					pcall(callback,v)
				end
				function sw:Get() return sw.value end

				local hit = Instance.new("TextButton", row)
				hit.Size=UDim2.fromScale(1,1) ; hit.BackgroundTransparency=1 ; hit.Text="" ; hit.ZIndex=3
				hit.MouseButton1Click:Connect(function() sw:Set(not sw.value) end)
				table.insert(lib.Items, sw)
				return sw
			end

			-- ================================================================
			-- MULTI TOGGLE
			-- ================================================================
			function sec:AddMultiToggle(list, defaults, callback, flag)
				flag     = flag or "multi"
				defaults = defaults or {}
				callback = callback or function() end
				local mt = {values={}}
				for _,v in ipairs(defaults) do mt.values[v]=true end
				lib.Flags[flag] = mt.values

				local container = Instance.new("Frame", items)
				container.Size = UDim2.new(1,0,0,0)
				container.AutomaticSize = Enum.AutomaticSize.Y
				container.BackgroundTransparency = 1
				container.BorderSizePixel = 0
				local cl = Instance.new("UIListLayout", container)
				cl.SortOrder=Enum.SortOrder.LayoutOrder ; cl.Padding=UDim.new(0,3)

				for _,name in ipairs(list) do
					local row = Instance.new("Frame", container)
					row.Size = UDim2.new(1,0,0,22)
					row.BackgroundTransparency = 1
					row.BorderSizePixel = 0

					local box = Instance.new("Frame", row)
					box.Size = UDim2.fromOffset(12,12)
					box.Position = UDim2.fromOffset(0,5)
					box.BackgroundColor3 = mt.values[name] and C.TogOn or C.TogOff
					box.BorderSizePixel = 0
					corner(box, 2)
					stroke(box, C.Border)

					local lbl = Instance.new("TextLabel", row)
					lbl.Position = UDim2.fromOffset(17,0)
					lbl.Size = UDim2.new(1,-17,1,0)
					lbl.BackgroundTransparency = 1
					lbl.Text = name
					lbl.Font = Enum.Font.Gotham
					lbl.TextSize = 11
					lbl.TextColor3 = mt.values[name] and C.Text or C.TextSec
					lbl.TextXAlignment = Enum.TextXAlignment.Left

					local hit = Instance.new("TextButton", row)
					hit.Size=UDim2.fromScale(1,1) ; hit.BackgroundTransparency=1 ; hit.Text="" ; hit.ZIndex=3
					hit.MouseButton1Click:Connect(function()
						mt.values[name] = not mt.values[name]
						tween(box,{BackgroundColor3=mt.values[name] and C.TogOn or C.TogOff})
						tween(lbl,{TextColor3=mt.values[name] and C.Text or C.TextSec})
						lib.Flags[flag]=mt.values ; pcall(callback,mt.values)
					end)
				end
				function mt:Get() return mt.values end
				return mt
			end

			table.insert(sec.Sections or {}, sec)
			return sec
		end

		return tab
	end

	return w
end

return lib

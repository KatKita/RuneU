# Installation

## 1. Open the Command Bar

Open **Roblox Studio**, then go to **View → Command Bar**.

## 2. Enable HTTP Requests

Before running the installer, enable **Allow HTTP Requests**:

**Home → Game Settings → Security → Allow HTTP Requests**

> This is only required for the installation process. You can disable it again after RuneU has been installed.

>

> The installer downloads the latest RuneU files directly from the official GitHub repository. If you prefer, you can inspect the script yourself or manually recreate the folder structure using the repository files.

## 3. Run the Installer

Paste the following script into the **Command Bar** and press **Run**.
```lua
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local OWNER = "KatKita"
local REPO = "RuneU"
local BRANCH = "main"
local ROOT = "rne"

local API = ("https://api.github.com/repos/%s/%s/contents"):format(OWNER, REPO)
local RAW = ("https://raw.githubusercontent.com/%s/%s/%s"):format(OWNER, REPO, BRANCH)

local COLORS = {
	bgMain = Color3.fromRGB(250, 250, 250),
	border = Color3.fromRGB(207, 207, 207),
	header = Color3.fromRGB(236, 236, 236),
	text = Color3.fromRGB(0, 0, 0),
	barFill = Color3.fromRGB(0, 75, 145),
	white = Color3.fromRGB(255, 255, 255)
}

local function CheckHttpService()
	if not HttpService.HttpEnabled then
		return false, "HTTP requests are disabled.\nEnable 'Allow HTTP Requests' in Game Settings > Security."
	end

	local ok, err = pcall(function()
		HttpService:GetAsync("https://github.com")
	end)

	if not ok then
		return false, "Unable to connect to GitHub.\n" .. tostring(err)
	end

	return true
end

local function create(className, properties, parent)
	local inst = Instance.new(className)
	for k, v in pairs(properties or {}) do
		inst[k] = v
	end
	if parent then inst.Parent = parent end
	return inst
end

local function createButton(text, layoutOrder, parent)
	return create("TextButton", {
		Name = text:lower(),
		BackgroundColor3 = COLORS.bgMain,
		BorderColor3 = COLORS.border,
		Size = UDim2.new(0, 118, 0, 35),
		Font = Enum.Font.SourceSans,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 14,
		TextWrapped = true,
		LayoutOrder = layoutOrder or 1
	}, parent)
end

local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
local parentGui = playerGui or game:GetService("StarterGui")

local RuneUInstaller = create("ScreenGui", {
	Name = "RuneU-Installer",
	DisplayOrder = 999999999,
	ResetOnSpawn = false
}, parentGui)

local main = create("Frame", {
	Name = "main",
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = COLORS.bgMain,
	BorderColor3 = COLORS.border,
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.new(0, 548, 0, 311)
}, RuneUInstaller)

create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, main)

local header = create("TextLabel", {
	Name = "header",
	BackgroundColor3 = COLORS.header,
	BorderColor3 = COLORS.border,
	LayoutOrder = 1,
	Size = UDim2.new(1, 0, 0, 28),
	Font = Enum.Font.ArialBold,
	Text = "RuneU Installer",
	TextColor3 = COLORS.text,
	TextSize = 15,
	TextXAlignment = Enum.TextXAlignment.Left
}, main)

create("UIPadding", { PaddingLeft = UDim.new(0, 8) }, header)

local content = create("Frame", {
	Name = "content",
	BackgroundTransparency = 1,
	LayoutOrder = 2,
	Size = UDim2.new(1, 0, 1, -28)
}, main)

local function createScreen(name)
	local frame = create("Frame", {
		Name = name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false
	}, content)

	create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 15)
	}, frame)

	return frame
end

local confirmationScreen = createScreen("confirmation")
confirmationScreen.Visible = true

local confirmHeader = create("TextLabel", {
	Name = "header",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -40, 0, 40),
	Font = Enum.Font.ArialBold,
	Text = "Install RuneU by KatKita from GitHub?",
	TextColor3 = COLORS.text,
	TextSize = 14,
	TextWrapped = true,
	LayoutOrder = 1
}, confirmationScreen)

local confirmButtons = create("Frame", {
	Name = "buttons",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 251, 0, 35),
	LayoutOrder = 2
}, confirmationScreen)

create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 15)
}, confirmButtons)

local btnCancel = createButton("Cancel", 1, confirmButtons)
local btnContinue = createButton("Continue", 2, confirmButtons)

local loadingScreen = createScreen("loading")

local loadingHeader = create("TextLabel", {
	Name = "header",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -40, 0, 40),
	Font = Enum.Font.ArialBold,
	Text = "Loading...",
	TextColor3 = COLORS.text,
	TextSize = 14,
	TextWrapped = true,
	LayoutOrder = 1
}, loadingScreen)

local barContainer = create("Frame", {
	Name = "loadingbar",
	BackgroundColor3 = COLORS.bgMain,
	BorderColor3 = COLORS.border,
	Size = UDim2.new(0, 306, 0, 35),
	LayoutOrder = 2
}, loadingScreen)

local progressBarFill = create("Frame", {
	Name = "barFill",
	BackgroundColor3 = COLORS.barFill,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 0, 1, 0)
}, barContainer)

local progressText = create("TextLabel", {
	Name = "progress",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = 2,
	Font = Enum.Font.SourceSans,
	Text = "0%",
	TextColor3 = COLORS.text,
	TextSize = 14,
	TextWrapped = true
}, barContainer)

local errorScreen = createScreen("error")

local errorHeader = create("TextLabel", {
	Name = "header",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -40, 0, 40),
	Font = Enum.Font.ArialBold,
	Text = "An error occurred",
	TextColor3 = COLORS.text,
	TextSize = 14,
	TextWrapped = true,
	LayoutOrder = 1
}, errorScreen)

local errorButtons = create("Frame", {
	Name = "buttons",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 118, 0, 35),
	LayoutOrder = 2
}, errorScreen)

local btnErrorOk = createButton("Close", 1, errorButtons)

local function getInstalledRuneU()
	for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
		if obj.Name:match("^RuneU%-") then
			return obj
		end
	end
end

local replaceScreen = createScreen("replace")

local installed = getInstalledRuneU()
local installedVersion = installed and installed.Name:match("^RuneU%-(.+)$") or "Unknown"

local replaceHeader = create("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -40, 0, 40),
	Font = Enum.Font.ArialBold,
	Text = string.format(
		"RuneU %s is already installed.\nReplace it with the latest version?",
		installedVersion
	),
	TextColor3 = COLORS.text,
	TextSize = 14,
	TextWrapped = true,
	LayoutOrder = 1
}, replaceScreen)

local replaceButtons = create("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 251, 0, 35),
	LayoutOrder = 2
}, replaceScreen)

create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 15)
}, replaceButtons)

local btnReplaceCancel = createButton("Cancel", 1, replaceButtons)
local btnReplace = createButton("Replace", 2, replaceButtons)

local function showScreen(screen)
	if screen.Visible then
		return
	end

	content.Visible = false
	task.wait(math.random(80, 180) / 1000)

	confirmationScreen.Visible = false
	replaceScreen.Visible = false
	loadingScreen.Visible = false
	errorScreen.Visible = false

	screen.Visible = true
	content.Visible = true
end

local function setProgress(percent, labelText)
	percent = math.clamp(percent, 0, 100)
	progressBarFill.Size = UDim2.new(percent / 100, 0, 1, 0)
	progressText.Text = labelText or (math.floor(percent) .. "%")
end

local function Get(url)
	return HttpService:GetAsync(url)
end

local function GetJson(url)
	return HttpService:JSONDecode(Get(url))
end

local function GetVersion()
	local source = Get(RAW .. "/rne/src/State.luau")
	local version = source:match('VERSION%s*=%s*"([^"]+)"')
		or source:match("VERSION%s*=%s*'([^']+)'")
	return version or "Unknown"
end

local function collectAllFiles(path, fileList)
	fileList = fileList or {}
	local items = GetJson(("%s/%s?ref=%s"):format(API, path, BRANCH))
	for _, item in ipairs(items) do
		if item.type == "dir" then
			collectAllFiles(item.path, fileList)
		elseif item.type == "file" then
			table.insert(fileList, item)
		end
	end
	return fileList
end

local function startInstallation()
	showScreen(loadingScreen)
	loadingHeader.Text = "Connecting to GitHub..."
	setProgress(0, "0%")

	task.spawn(function()
		local ok, err = pcall(function()
			loadingHeader.Text = "Checking version..."
			local version = GetVersion()

			local RootFolder = Instance.new("Folder")
			RootFolder.Name = "RuneU-" .. version

			loadingHeader.Text = "Indexing files..."
			local allFiles = collectAllFiles(ROOT)
			local totalFiles = #allFiles

			loadingHeader.Text = "Downloading files..."
			local folderCache = { [ROOT] = RootFolder }

			local function getOrCreateFolder(dirPath)
				if folderCache[dirPath] then return folderCache[dirPath] end
				local parts = string.split(dirPath, "/")
				local currentParent = RootFolder
				local currentPath = ROOT

				for i = 2, #parts do
					currentPath = currentPath .. "/" .. parts[i]
					if not folderCache[currentPath] then
						local newFolder = Instance.new("Folder")
						newFolder.Name = parts[i]
						newFolder.Parent = currentParent
						folderCache[currentPath] = newFolder
					end
					currentParent = folderCache[currentPath]
				end
				return currentParent
			end

			for index, item in ipairs(allFiles) do
				local dirPath = item.path:match("^(.*)/[^/]+$") or ROOT
				local parentFolder = getOrCreateFolder(dirPath)

				local ext = item.name:match("%.([^.]+)$")
				if ext == "lua" or ext == "luau" then
					local module = Instance.new("ModuleScript")
					module.Name = item.name:gsub("%.luau?$", "")
					module.Source = Get(item.download_url)
					module.Parent = parentFolder
				else
					local value = Instance.new("StringValue")
					value.Name = item.name
					value.Value = Get(item.download_url)
					value.Parent = parentFolder
				end

				local percent = math.floor((index / totalFiles) * 100)
				setProgress(percent, string.format("%d%% (%d/%d)", percent, index, totalFiles))
				task.wait(0.02)
			end

			RootFolder.Parent = ReplicatedStorage
			print("RuneU installed successfully:", RootFolder:GetFullName())
		end)

		if not ok then
			warn("RuneU Installer: " .. tostring(err))
			errorHeader.Text = "Error: " .. tostring(err)
			showScreen(errorScreen)
		else
			loadingHeader.Text = "Installation Complete!"
			setProgress(100, "100%")
			task.wait(1.5)
			RuneUInstaller:Destroy()
		end
	end)
end



btnCancel.MouseButton1Click:Connect(function()
	RuneUInstaller:Destroy()
end)

btnContinue.MouseButton1Click:Connect(function()
	if getInstalledRuneU() then
		showScreen(replaceScreen)
	else
		startInstallation()
	end
end)

btnErrorOk.MouseButton1Click:Connect(function()
	RuneUInstaller:Destroy()
end)

btnReplace.MouseButton1Click:Connect(function()
	local installed = getInstalledRuneU()
	if installed then
		installed:Destroy()
	end

	startInstallation()
end)

btnReplaceCancel.MouseButton1Click:Connect(function()
	RuneUInstaller:Destroy()
end)

local ok, err = CheckHttpService()

if not ok then
	errorHeader.Text = err
	showScreen(errorScreen)
	return
end
```

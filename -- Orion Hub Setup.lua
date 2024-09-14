-- Orion Hub Setup
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local WindowName = "Doors Floor 2 Door 150 Script"
local Window = OrionLib:MakeWindow({
    Name = WindowName,
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "DoorsFloor2",
    IntroEnabled = true,
    IntroText = WindowName,
    IntroIcon = "rbxassetid://74110200858194" -- Icon ID, you can change this
})


-- ESP Tab
local ESPTab = Window:MakeTab({
    Name = "ESP",
    Icon = "rbxassetid://74110200858194", -- Icon ID, you can change this
    PremiumOnly = false
})

-- Variables to store highlights and BillboardGuis for each ESP type
local espElements = {
    MinesAnchor = {highlights = {}, billboards = {}},
    GrumbleRig = {highlights = {}, billboards = {}},
    Console = {highlights = {}, billboards = {}}
}

-- Function to search the entire Workspace for all instances of a model
local function findAllModelsInWorkspace(modelName)
    local foundModels = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == modelName then
            table.insert(foundModels, obj)
        end
    end
    return foundModels
end

-- Function to create a Highlight for the model
local function createHighlight(model, color)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color -- Dynamic color
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
    highlight.Parent = model
    return highlight
end

-- Function to create BillboardGui for the model
local function createBillboardGui(model, text, textColor)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(10, 0, 3, 0) -- Larger size for visibility
    billboardGui.StudsOffset = Vector3.new(0, 3, 0) -- Position above model
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = model -- Attach to the entire model

    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = textColor -- Same color as the highlight
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    return billboardGui
end

-- Function to get the text for each MinesAnchor from the nested TextLabel
local function getMinesAnchorText(minesAnchor)
    local sign = minesAnchor:FindFirstChild("Sign", true)
    if sign and sign:FindFirstChild("TextLabel") then
        return sign.TextLabel.Text
    else
        warn("No 'TextLabel' found in MinesAnchor.Sign for " .. minesAnchor.Name)
    end
    return "Anchor"
end

-- Function to apply ESP to models
local function applyESP(modelName)
    local espData = espElements[modelName]
    if not espData then return end

    local allModels = findAllModelsInWorkspace(modelName)
    for _, model in ipairs(allModels) do
        if not espData.highlights[model] then
            local highlightColor = modelName == "MinesAnchor" and Color3.fromRGB(0, 255, 0) or
                                  (modelName == "GrumbleRig" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255))
            local highlight = createHighlight(model, highlightColor)
            local billboard = createBillboardGui(model, modelName == "MinesAnchor" and ("Anchor " .. getMinesAnchorText(model)) or modelName, highlightColor)
            espData.highlights[model] = highlight
            espData.billboards[model] = billboard
        end
    end
end

-- Function to remove ESP from models
local function removeESP(modelName)
    local espData = espElements[modelName]
    if not espData then return end

    for model, highlight in pairs(espData.highlights) do
        highlight:Destroy()
        if espData.billboards[model] then
            espData.billboards[model]:Destroy()
        end
    end
    espData.highlights = {}
    espData.billboards = {}
end

-- Function to automatically anchor models
local function autoAnchor()
    local anchors = {}
    local AutoAnchor = true

    for _, v in pairs(workspace.CurrentRooms:GetDescendants()) do 
        if v.Name == 'MinesAnchor' then
            table.insert(anchors, v)
        end
    end

    game:GetService("Workspace").CurrentRooms.DescendantAdded:Connect(function(v)
        task.wait(0.1) -- letting it load
        if v.Name == 'MinesAnchor' then
            table.insert(anchors, v)
        end
    end)

    while wait() do
        for _, v in pairs(anchors) do
            local primpart = v.PrimaryPart
            if (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - primpart.Position).Magnitude <= 10 and AutoAnchor and v.Sign.TextLabel.Text == game:GetService("Players").LocalPlayer.PlayerGui.MainUI.MainFrame.AnchorHintFrame.AnchorCode.Text then
                v.AnchorRemote:InvokeServer(game:GetService("Players").LocalPlayer.PlayerGui.MainUI.MainFrame.AnchorHintFrame.Code.Text)
            end
        end
    end
end

-- ESP Buttons
ESPTab:AddToggle({
    Name = "Anchor ESP",
    Default = false,
    Callback = function(enabled)
        if enabled then
            applyESP("MinesAnchor")
        else
            removeESP("MinesAnchor")
        end
    end
})

ESPTab:AddToggle({
    Name = "Grumble ESP",
    Default = false,
    Callback = function(enabled)
        if enabled then
            applyESP("GrumbleRig")
        else
            removeESP("GrumbleRig")
        end
    end
})

ESPTab:AddToggle({
    Name = "Console ESP",
    Default = false,
    Callback = function(enabled)
        if enabled then
            applyESP("Console")
        else
            removeESP("Console")
        end
    end
})

-- Auto Anchor Button
ESPTab:AddButton({
    Name = "Auto Anchor",
    Callback = function()
        autoAnchor()
        OrionLib:MakeNotification({
            Name = "Auto Anchor Enabled",
            Content = "Auto Anchor script is now running!",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
})

-- Initialize the Orion Hub
OrionLib:Init()

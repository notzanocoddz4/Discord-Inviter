loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/Utilities/main/Functions.lua"))()

local Root = "https://github.com/notzanocoddz4/Discord-Inviter/raw/main"

-- \\ Services // --

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- \\ Variables // --

local Assets = {
    DiscordInvitePrompt = LoadCustomInstance(`{Root}/Assets/DiscordInvitePrompt.rbxm`),
    NotificationSound = LoadCustomAsset(`{Root}/Assets/Notification.mp3`)
}

local httprequest = request or http_request or (http and http.request)

local Module = {}

-- \\ Functions // --

local function GetInviteData(invite: string): (boolean?, any?)
    local success, result = pcall(function()
		return HttpService:JSONDecode(httprequest({
            Url = "https://ptb.discord.com/api/invites/" .. (invite:match("([^/]+)$") or invite),
            Method = "GET"
        }).Body)
	end)
    if not success then
        warn("Failed to get invite data:\n".. result)
        return
    end
    return success, result
end

local function GetMemberCount(invite: string): (number, number)
    local success, result = GetInviteData(invite)
    if not (success and result) then
        return 0, 0
    end

    return result.profile.online_count, result.profile.member_count
end

local function ToggleShowPrompt(promptGui: ScreenGui, state: boolean)
    local frame = promptGui.Holder
    local serverIcon = frame.ServerIcon
    local serverInitials = serverIcon.ServerInitials
    local invited = frame.Invited
    local serverName = frame.ServerName
    local accept = frame.Accept
    local ignore = frame.Ignore
    local statusContainer = frame.StatusContainer
    local onlineHolder = statusContainer.OnlineHolder
    local membersHolder = statusContainer.MembersHolder

    local dotOnline = onlineHolder.DotContainer.Green
    local dotMembers = membersHolder.DotContainer.White
    
    local onlineText = onlineHolder.OnlineText
    local membersText = membersHolder.MembersText

    local tweeninfo = TweenInfo.new(1, Enum.EasingStyle.Quint)
    if state then
        frame.Visible = true
        TweenService:Create(frame, tweeninfo, { Size = UDim2.new(0, 262, 0, 262) }):Play()
        TweenService:Create(frame.UICorner, tweeninfo, { CornerRadius = UDim.new(0, 8) }):Play()
        task.wait(1)
        TweenService:Create(serverIcon, tweeninfo, { Size = UDim2.new(0, 66, 0, 66) }):Play()
		TweenService:Create(serverIcon, tweeninfo, { BackgroundTransparency = 0, ImageTransparency = 0 }):Play()
		TweenService:Create(serverInitials, tweeninfo, { TextTransparency = 0 }):Play()
        task.wait(0.1)
        TweenService:Create(invited, tweeninfo, { Size = UDim2.new(0, 237, 0, 19) }):Play()
        TweenService:Create(invited, tweeninfo, { TextTransparency = 0 }):Play()
        task.wait(0.1)
        TweenService:Create(serverName, tweeninfo, { Size = UDim2.new(0, 237, 0, 26) }):Play()
        TweenService:Create(serverName, tweeninfo, { TextTransparency = 0 }):Play()
        task.wait(0.1)
        TweenService:Create(statusContainer, tweeninfo, { Size = UDim2.new(0, 237, 0, 19) }):Play()
        TweenService:Create(dotOnline, tweeninfo, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(onlineText, tweeninfo, { TextTransparency = 0 }):Play()
        TweenService:Create(dotMembers, tweeninfo, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(membersText, tweeninfo, { TextTransparency = 0 }):Play()
        task.wait(0.1)
		TweenService:Create(accept, tweeninfo, { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
		task.wait(0.1)
		TweenService:Create(ignore, tweeninfo, { TextTransparency = 0 }):Play()
		task.wait(1)
    else
		TweenService:Create(ignore, tweeninfo, { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(accept, tweeninfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(serverName, tweeninfo, { TextTransparency = 1 }):Play()
		task.wait(0.1)
        TweenService:Create(dotOnline, tweeninfo, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(onlineText, tweeninfo, { TextTransparency = 1 }):Play()
        TweenService:Create(dotMembers, tweeninfo, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(membersText, tweeninfo, { TextTransparency = 1 }):Play()
        TweenService:Create(statusContainer, tweeninfo, { Size = UDim2.new(0, 237, 0, 19) }):Play()
        task.wait(0.1)
		TweenService:Create(invited, tweeninfo, { TextTransparency = 1 }):Play()
		task.wait(0.1)
		TweenService:Create(serverIcon, tweeninfo, { BackgroundTransparency = 1, ImageTransparency = 1 }):Play()
		TweenService:Create( serverInitials, tweeninfo, { TextTransparency = 1 }):Play()
		task.wait(1)
		TweenService:Create(frame, tweeninfo, { Size = UDim2.new() }):Play()
		TweenService:Create(frame.UICorner, tweeninfo, { CornerRadius = UDim.new(1, 0) }):Play()
		task.wait(1)
		frame.Visible = false
    end
end

-- \\ Main // --

Module.Join = function(self, invite: string)
    assert(typeof(invite) == "string", "<string> Invalid invite provided")

    local success, result = GetInviteData(invite)
	if success and result then
        httprequest({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Origin"] = "https://discord.com"
            },
            Body = HttpService:JSONEncode({
                cmd = "INVITE_BROWSER",
                args = {
                    code = result.code
                },
                nonce = HttpService:GenerateGUID(false)
            })
        })
        
        -- Play notification sound
        local sound = Instance.new("Sound")
        sound.Volume = 1
        sound.PlayOnRemove = true
        sound.SoundId = Assets.NotificationSound
        sound.Parent = CoreGui
        sound:Destroy()
	end
end

Module.Prompt = function(self, data: { name: string, invite: string })
    assert(typeof(data) == "table", "Data must be a table")
    assert(typeof(data.name) == "string", "Name must be a string")
    assert(typeof(data.invite) == "string", "Invite must be a string")
    
    local name = data.name
    local invite = data.invite
    local success, result = GetInviteData(invite)

    if not (success and result) then return end
    
    local onlineCount, memberCount = GetMemberCount(invite)

    -- Invite prompt construction
    local promptGui = Assets.DiscordInvitePrompt:Clone()
    if not promptGui then return end

    local holder = promptGui.Holder
    local serverIcon = holder.ServerIcon
    local serverInitials = serverIcon.ServerInitials
    local serverName = holder.ServerName
    local accept = holder.Accept
    local ignore = holder.Ignore

    local onlineText = holder.StatusContainer.OnlineHolder.OnlineText
    local membersText = holder.StatusContainer.MembersHolder.MembersText

    -- Setup
    holder.Size = UDim2.new()
    holder.UICorner.CornerRadius = UDim.new(1, 0)
    serverName.Text = name
    onlineText.Text = `{onlineCount} Online`
    membersText.Text = `{memberCount} Members`
    accept.Text = `Join <b>{name}</b>`
    
    if result.guild.icon ~= nil then
        serverIcon.Image = LoadCustomAsset(`https://cdn.discordapp.com/icons/{result.guild.id}/{result.guild.icon}.png`)
    else
        local initials = ""
        for word in name:gmatch("%S+") do
            initials ..= word:sub(1,1):upper()
            if #initials >= 3 then
                break
            end
        end
        
        serverInitials.Text = initials:upper()
        serverInitials.Visible = true
    end

    for _, c in holder:GetDescendants() do
        if c.ClassName == "TextLabel" or c.ClassName == "TextButton" then
            c.BackgroundTransparency = 1
            c.TextTransparency = 1
        elseif c.ClassName == "ImageLabel" then
            c.ImageTransparency = 1
        elseif c.ClassName == "Frame" then -- dot
            c.BackgroundTransparency = 1
        end
    end

    -- Display
    promptGui.Parent = CoreGui
    ToggleShowPrompt(promptGui, true)

    -- Connections
    local connections = {}

    local function dismiss(join: boolean)
        for _, c in connections do
            c:Disconnect()
        end
        if join then
            self:Join(invite)
        end
        ToggleShowPrompt(promptGui, false)
    end

    connections.acceptEnter = accept.MouseEnter:Connect(function()
        TweenService:Create(accept, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(71, 82, 196) }):Play()
    end)
    connections.acceptLeave = accept.MouseLeave:Connect(function()
        TweenService:Create(accept, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }):Play()
    end)
    connections.acceptActivated = accept.Activated:Connect(function()
        dismiss(true)
    end)
    do
        local text = ignore.Text
        connections.ignoreEnter = ignore.MouseEnter:Connect(function()
            ignore.Text = `<u>{text}</u>`
        end)
        connections.ignoreLeave = ignore.MouseLeave:Connect(function()
            ignore.Text = text
        end)
        connections.ignoreActivated = ignore.Activated:Connect(function()
            dismiss(false)
        end)
    end
end

return Module
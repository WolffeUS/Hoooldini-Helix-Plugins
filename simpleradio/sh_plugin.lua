PLUGIN.name = "Simple Radio"
PLUGIN.author = "Hoooldini"
PLUGIN.description = "Simple radios for Helix."

-- [[ NETWORKING ]] --

-- Used for playing a sound to the client upon receiving a radio message. Makes it so that only the client can hear the sound.
if SERVER then
	util.AddNetworkString( "radioReceive" )
else
	net.Receive( "radioReceive", function( len, pl )
		surface.PlaySound( "npc/metropolice/vo/off" .. math.random(1, 3) .. ".wav" )
	end )
end

-- [[ GLOBAL VARIABLES ]] --

-- Optional color table for giving frequencies different colors.
local colorTable = {
	main = Color(80, 180, 255),
	command = Color(255, 255, 85),
	support = Color(100, 255, 50)
}

-- Default radio color if none is provided or part of the table.
local RADIO_CHATCOLOR = Color(100, 255, 50)

-- [[ CHAT SETUP ]] --

--[[
	CHAT: Radio
	DESCRIPTION: Allows the user, provided they have an active radio, 
	to broadcast messages to others on the same frequency. Because we
	are allowing users to be on, and speak over, multiple frequencies,
	we have to use this chat through the commands setup below.
]]--

ix.chat.Register("radio", { -- Sets up and registers the radio chat.
	format = "[%s] %s: \"%s\"",
	OnGetColor = function(self, speaker, text)
		return RADIO_CHATCOLOR
	end,
	OnCanHear = function(self, speaker, listener)
		local listenerRadio = listener:GetCharacter():GetData("RadioInfo")
		local speakerRadio = speaker:GetCharacter():GetData("RadioInfo")
		local canHear = false

		if (listenerRadio and table.HasValue(listenerRadio.freqList, speakerRadio.lastFreq)) then -- If the listener has the frequency, allow them to hear the transmission.
			canHear = true
			net.Start("radioReceive")
			net.Send(listener)
		end

		return canHear
	end,
	CanSay = function(self, speaker, text)
		local speakerRadio = speaker:GetCharacter():GetData("RadioInfo")
		local canSpeak = false

		if (speakerRadio) then -- If the speaker has RadioInfo set up, they have a radio and can speak.
			canSpeak = true
		end

		return canSpeak
	end,
	OnChatAdd = function(self, speaker, text, anonymous, info)
		local character = speaker:GetCharacter()
		local name = character:GetName()
		local radioInfo = character:GetData("RadioInfo")
		local channel = string.upper(radioInfo.lastFreq)

		chat.AddText((colorTable[radioInfo.lastFreq] or self.color), string.format(self.format, channel, name, text))
	end
})

-- [[ COMMANDS ]] --

--[[
	NOTE: Radios, the way they are set up right now, may only have up to
	3 frequencies at a time. These frequencies are accessed through the
	commands below. Where /r would be the default frequency, /r1 would
	be additional channel 1, and /r2 would be additional channel 2.
]]

--[[
	COMMAND: /r
	DESCRIPTION: Broadcasts a message over the equipped radio's primary frequency.
]]--

ix.command.Add("r", {
	description = "Radio over your primary frequency.",
	superAdminOnly = false,
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, text)
		local char = client:GetCharacter()
		local radioInfo = char:GetData("RadioInfo")

		if (radioInfo) then
			radioInfo.lastFreq = radioInfo.freqList[1]
			char:SetData("RadioInfo", radioInfo) 

			ix.chat.Send(client, "radio", text, false, nil, nil)

			client:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav", math.random(50, 60), math.random(80, 120))
		end
	end
})

--[[
	COMMAND: /r1
	DESCRIPTION: Broadcasts a message over the equipped radio's first additional channel.
]]--

ix.command.Add("r1", {
	description = "Radio over additional channel 1.",
	superAdminOnly = false,
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, text)
		local char = client:GetCharacter()
		local radioInfo = char:GetData("RadioInfo")

		if (radioInfo and #radioInfo.freqList > 1) then
			radioInfo.lastFreq = radioInfo.freqList[2]
			char:SetData("RadioInfo", radioInfo) 

			ix.chat.Send(client, "radio", text, false, nil, nil)

			client:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav", math.random(50, 60), math.random(80, 120))
		end
	end
})

--[[
	COMMAND: /r2
	DESCRIPTION: Broadcasts a message over the equipped radio's second additional channel.
]]--

ix.command.Add("r2", {
	description = "Radio over additional channel 2.",
	superAdminOnly = false,
	arguments = {
		ix.type.text
	},
	OnRun = function(self, client, text)
		local char = client:GetCharacter()
		local radioInfo = char:GetData("RadioInfo")

		if (radioInfo and #radioInfo.freqList > 2) then
			radioInfo.lastFreq = radioInfo.freqList[3]
			char:SetData("RadioInfo", radioInfo) 

			ix.chat.Send(client, "radio", text, false, nil, nil)

			client:EmitSound("npc/metropolice/vo/on" .. math.random(1, 2) .. ".wav", math.random(50, 60), math.random(80, 120))
		end
	end
})

-- [[ FUNCTIONS ]] --

--[[
	FUNCTION: PLUGIN:HUDPaint()
	DESCRIPTION: Draws text in the top right. Code is nearly identical to the hud element
	from ZeMysticalTaco's radio plugin.
]]--

function PLUGIN:HUDPaint()
	local scrw = ScrW()
	local char = LocalPlayer():GetCharacter()

	if (char and char:GetData("RadioInfo")) then
		local freqList = char:GetData("RadioInfo").freqList
		draw.SimpleText("Frequencies: " .. table.concat(freqList, ", "), "BudgetLabel", scrw - 50, 0, Color(255, 255, 255, 255), TEXT_ALIGN_RIGHT)
	end
end
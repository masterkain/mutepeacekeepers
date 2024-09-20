-- Create the addon frame within a local scope to prevent global namespace pollution
local frame = CreateFrame("Frame")

-- Define the target subzone where sounds should be muted
local TARGET_SUBZONE = "Contender's Gate"

-- Define the sound file ranges to mute (keeping original ranges)
local SoundRanges = {
	-- clashing sounds
	{ Start = 1393680, End = 1393733 },
	{ Start = 1393680, End = 1394257 },
	{ Start = 567619, End = 567916 },
	-- weapon swing sounds
	{ Start = 1302923, End = 1302932 },
	{ Start = 1302596, End = 1302605 },
	-- grunts
	{ Start = 5919829, End = 5919837 },
	{ Start = 5919761, End = 5919779 },
	{ Start = 5919528, End = 5919549 },
	{ Start = 5919592, End = 5919606 },
	{ Start = 5919608, End = 5919626 },
}

-- State tracking to prevent redundant mute/unmute operations
local isMuted = false

-- Function to mute the specified sound files
local function MuteSounds()
	for _, range in ipairs(SoundRanges) do
		for soundID = range.Start, range.End do
			-- Attempt to mute the sound file and handle any potential errors
			local success, errorMsg = pcall(MuteSoundFile, soundID)
			if not success then
				print(string.format("[ContendersGateSoundMute] Failed to mute sound ID %d: %s", soundID, errorMsg))
			end
		end
	end
	isMuted = true
end

-- Function to unmute the specified sound files
local function UnmuteSounds()
	for _, range in ipairs(SoundRanges) do
		for soundID = range.Start, range.End do
			-- Attempt to unmute the sound file and handle any potential errors
			local success, errorMsg = pcall(UnmuteSoundFile, soundID)
			if not success then
				print(string.format("[ContendersGateSoundMute] Failed to unmute sound ID %d: %s", soundID, errorMsg))
			end
		end
	end
	isMuted = false
end

-- Function to check the current subzone and mute/unmute sounds accordingly
local function CheckZone()
	local currentSubZone = GetSubZoneText()

	if currentSubZone == TARGET_SUBZONE then
		if not isMuted then
			MuteSounds()
		end
	else
		if isMuted then
			UnmuteSounds()
		end
	end
end

-- Event handler to respond to zone changes
local function OnEvent(self, event, ...)
	CheckZone()
end

-- Register relevant events
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Set the script to run when the events fire
frame:SetScript("OnEvent", OnEvent)

-- Initialize by checking the zone when the addon loads
-- Ensures correct state on addon initialization
-- Sometimes PLAYER_ENTERING_WORLD might not have the correct subzone immediately, so we can use a small delay
frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		-- Delay the initial check to ensure subzone information is loaded
		C_Timer.After(1, CheckZone)
	else
		CheckZone()
	end
end)

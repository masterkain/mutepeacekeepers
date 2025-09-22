-- Simple zone-based muting for Oathsworn Peacekeepers
-- Future technical enhancements might include collecting new sound IDs at runtime
-- or exporting the current list for analysis, but those are intentionally omitted
-- to keep the addon lightweight in-game.

-- Constants for the target zone and the known sound ID ranges
local TARGET_ZONE = 2339
local SOUND_RANGES = {
    { Start = 1393680, End = 1394257 },
    { Start = 567619, End = 567916 },
    { Start = 1302923, End = 1302932 },
    { Start = 1302596, End = 1302605 },
    { Start = 5919829, End = 5919837 },
    { Start = 5919761, End = 5919779 },
    { Start = 5919528, End = 5919549 },
    { Start = 5919592, End = 5919626 },
}

local isMuted = false

local function MuteSound(soundID)
    pcall(MuteSoundFile, soundID)
end

local function UnmuteSound(soundID)
    pcall(UnmuteSoundFile, soundID)
end

local function ApplyMuteState(shouldMute)
    if shouldMute == isMuted then
        return
    end

    local handler = shouldMute and MuteSound or UnmuteSound

    for _, range in ipairs(SOUND_RANGES) do
        for soundID = range.Start, range.End do
            handler(soundID)
        end
    end

    isMuted = shouldMute
end

local function CheckZone()
    local mapID = C_Map.GetBestMapForUnit("player")

    if mapID == TARGET_ZONE then
        ApplyMuteState(true)
    else
        ApplyMuteState(false)
    end
end

local function Initialize()
    local frame = CreateFrame("Frame", "MutePeacekeepersFrame")
    frame:SetScript("OnEvent", CheckZone)
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- Perform an initial check after load to sync the mute state.
    C_Timer.After(1, CheckZone)
end

Initialize()

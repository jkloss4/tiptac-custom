-- create addon
local MOD_NAME, ns = ...;
local PARENT_MOD_NAME = "TipTac";
-- The options page is drawn by SettingsKit (see the end of this file); this frame is TipTacOptions' global, used to open it.
local f = CreateFrame("Frame", MOD_NAME);

-- get libs
local LibFroznFunctions = LibStub:GetLibrary("LibFroznFunctions-1.0");

-- set config
local configDb, cfg = LibFroznFunctions:CreateDbWithLibAceDB("TipTac_Config");

-- DropDown Lists: { label, value } in display order
local DROPDOWN_ANCHORTYPE = {
	{ "Normal Anchor", "normal" },
	{ "Mouse Anchor", "mouse" },
	{ "Parent Anchor", "parent" },
};

local DROPDOWN_ANCHORPOS = {
	{ "Top Left", "TOPLEFT" },
	{ "Top", "TOP" },
	{ "Top Right", "TOPRIGHT" },
	{ "Left", "LEFT" },
	{ "Center", "CENTER" },
	{ "Right", "RIGHT" },
	{ "Bottom Left", "BOTTOMLEFT" },
	{ "Bottom", "BOTTOM" },
	{ "Bottom Right", "BOTTOMRIGHT" },
};

-- Options: "y" adds space above an item; "x" puts a checkbox in the second column of the row above.

-- Anchors
-- offset slider for the given anchor frame ("WorldUnit", "WorldTip", "FrameUnit", "FrameTip") and axis ("X", "Y")
local function GetOffsetOption(anchorFrameName, axis)
	return { type = "Slider", var = "mouseOffset" .. anchorFrameName .. axis, label = axis .. " Offset", tip = "Offset of the tooltip from its anchor position, for any anchor type", min = -200, max = 200, step = 1, fontSizeDelta = -2, enabled = function(factory) return factory:GetConfigValue("enableAnchor") end };
end

local function AnchorEnabled(factory) return factory:GetConfigValue("enableAnchor"); end

-- the default anchor settings: a header per anchor frame ("World Unit", ...) with its type, point and offsets
local ttOptionsAnchors = {};

for _, anchorFrame in ipairs({ { "WorldUnit", "World Unit" }, { "WorldTip", "World Tip" }, { "FrameUnit", "Frame Unit" }, { "FrameTip", "Frame Tip" } }) do
	local name, label = anchorFrame[1], anchorFrame[2];
	tinsert(ttOptionsAnchors, { type = "Header", label = label, enabled = AnchorEnabled });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchor" .. name .. "Type", label = "Type", tip = "How " .. label .. " tooltips are anchored", list = DROPDOWN_ANCHORTYPE, enabled = AnchorEnabled });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchor" .. name .. "Point", label = "Point", tip = "The point of " .. label .. " tooltips that's anchored", list = DROPDOWN_ANCHORPOS, enabled = AnchorEnabled });
	tinsert(ttOptionsAnchors, GetOffsetOption(name, "X"));
	tinsert(ttOptionsAnchors, GetOffsetOption(name, "Y"));
end

local priority = 0;

if (LibFroznFunctions.hasWoWFlavor.challengeMode) then
	priority = priority + 1;
	tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During Challenge Mode", tip = "Special anchor overrides during challenge mode (Mythic+) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
	tinsert(ttOptionsAnchors, { type = "TextOnly", label = "In Combat" });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringChallengeModeInCombat", label = "World Unit during challenge mode in combat", tip = "This option will override the anchor for World Unit during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringChallengeModeInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringChallengeModeInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringChallengeModeInCombat", label = "World Tip during challenge mode in combat", tip = "This option will override the anchor for World Tip during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringChallengeModeInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringChallengeModeInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringChallengeModeInCombat", label = "Frame Unit during challenge mode in combat", tip = "This option will override the anchor for Frame Unit during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringChallengeModeInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringChallengeModeInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringChallengeModeInCombat", label = "Frame Tip during challenge mode in combat", tip = "This option will override the anchor for Frame Tip during challenge mode (Mythic+) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringChallengeModeInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeModeInCombat") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringChallengeModeInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeModeInCombat") end });
	
	tinsert(ttOptionsAnchors, { type = "TextOnly", label = "Out Of Combat", y = 10 });

	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringChallengeMode", label = "World Unit during challenge mode out of combat", tip = "This option will override the anchor for World Unit during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringChallengeMode", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringChallengeMode", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringChallengeMode", label = "World Tip during challenge mode out of combat", tip = "This option will override the anchor for World Tip during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringChallengeMode", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringChallengeMode", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringChallengeMode", label = "Frame Unit during challenge mode out of combat", tip = "This option will override the anchor for Frame Unit during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringChallengeMode", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringChallengeMode", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringChallengeMode") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringChallengeMode", label = "Frame Tip during challenge mode out of combat", tip = "This option will override the anchor for Frame Tip during challenge mode (Mythic+) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringChallengeMode", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeMode") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringChallengeMode", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringChallengeMode") end });
end

priority = priority + 1;
tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During An Instance", tip = "Special anchor overrides during an instance (Dungeon, Raid, PvP, Arena, Scenario) in and out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "TextOnly", label = "In Combat" });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringInstanceInCombat", label = "World Unit during an instance in combat", tip = "This option will override the anchor for World Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringInstanceInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringInstanceInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringInstanceInCombat", label = "World Tip during an instance in combat", tip = "This option will override the anchor for World Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringInstanceInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringInstanceInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringInstanceInCombat", label = "Frame Unit during an instance in combat", tip = "This option will override the anchor for Frame Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringInstanceInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringInstanceInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringInstanceInCombat", label = "Frame Tip during an instance in combat", tip = "This option will override the anchor for Frame Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringInstanceInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstanceInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringInstanceInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstanceInCombat") end });

tinsert(ttOptionsAnchors, { type = "TextOnly", label = "Out Of Combat", y = 10 });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringInstance", label = "World Unit during an instance out of combat", tip = "This option will override the anchor for World Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringInstance", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringInstance", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringInstance", label = "World Tip during an instance out of combat", tip = "This option will override the anchor for World Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringInstance", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringInstance", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringInstance", label = "Frame Unit during an instance out of combat", tip = "This option will override the anchor for Frame Unit during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringInstance", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringInstance", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringInstance") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringInstance", label = "Frame Tip during an instance out of combat", tip = "This option will override the anchor for Frame Tip during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringInstance", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstance") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringInstance", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringInstance") end });

if (LibFroznFunctions.hasWoWFlavor.skyriding) then
	priority = priority + 1;
	tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides During Skyriding", tip = "Special anchor overrides during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitDuringSkyriding", label = "World Unit during skyriding", tip = "This option will override the anchor for World Unit during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeDuringSkyriding", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointDuringSkyriding", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipDuringSkyriding", label = "World Tip during skyriding", tip = "This option will override the anchor for World Tip during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeDuringSkyriding", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointDuringSkyriding", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitDuringSkyriding", label = "Frame Unit during skyriding", tip = "This option will override the anchor for Frame Unit during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeDuringSkyriding", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointDuringSkyriding", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitDuringSkyriding") end });
	
	tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipDuringSkyriding", label = "Frame Tip during skyriding", tip = "This option will override the anchor for Frame Tip during skyriding", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeDuringSkyriding", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringSkyriding") end });
	tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointDuringSkyriding", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipDuringSkyriding") end });
end

priority = priority + 1;
tinsert(ttOptionsAnchors, { type = "Header", label = "Priority #" .. priority .. ": Anchor Overrides For In Combat", tip = "Special anchor overrides for in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldUnitInCombat", label = "World Unit in combat", tip = "This option will override the anchor for World Unit in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitTypeInCombat", label = "World Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldUnitPointInCombat", label = "World Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldUnitInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideWorldTipInCombat", label = "World Tip in combat", tip = "This option will override the anchor for World Tip in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipTypeInCombat", label = "World Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorWorldTipPointInCombat", label = "World Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideWorldTipInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameUnitInCombat", label = "Frame Unit in combat", tip = "This option will override the anchor for Frame Unit in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitTypeInCombat", label = "Frame Unit Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameUnitPointInCombat", label = "Frame Unit Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameUnitInCombat") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideFrameTipInCombat", label = "Frame Tip in combat", tip = "This option will override the anchor for Frame Tip in combat", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end, y = 10 });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipTypeInCombat", label = "Frame Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipInCombat") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorFrameTipPointInCombat", label = "Frame Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideFrameTipInCombat") end });

tinsert(ttOptionsAnchors, { type = "Header", label = "Other Anchor Overrides", tip = "Other special anchor overrides", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });

tinsert(ttOptionsAnchors, { type = "Check", var = "enableAnchorOverrideCF", label = "(Guild & Community) ChatFrame", tip = "This option will override the anchor for (Guild & Community, addon WIM) ChatFrame", enabled = function(factory) return factory:GetConfigValue("enableAnchor") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorOverrideCFType", label = "Tip Type", list = DROPDOWN_ANCHORTYPE, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideCF") end });
tinsert(ttOptionsAnchors, { type = "DropDown", var = "anchorOverrideCFPoint", label = "Tip Point", list = DROPDOWN_ANCHORPOS, enabled = function(factory) return factory:GetConfigValue("enableAnchor") and factory:GetConfigValue("enableAnchorOverrideCF") end });

-- Hiding
local ttOptionsHiding = {};
priority = 0;

if (LibFroznFunctions.hasWoWFlavor.challengeMode) then
	priority = priority + 1;
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringChallengeModeHeader", label = "Priority #" .. priority .. ": Hide Tips During Challenge Mode" });
	
	tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringChallengeModeInCombat", label = "In Combat", belongsTo = "hideTipsDuringChallengeModeHeader" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during challenge mode (Mythic+) in combat.", y = 10, belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during challenge mode (Mythic+) in combat.", y = 10, belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during challenge mode (Mythic+) in combat.", belongsTo = "hideTipsDuringChallengeModeInCombat" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during challenge mode (Mythic+) in combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeInCombatActionTips" });
	
	tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringChallengeMode", label = "Out Of Combat", y = 10, belongsTo = "hideTipsDuringChallengeModeHeader" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during challenge mode (Mythic+) out of combat.", y = 10, belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during challenge mode (Mythic+) out of combat.", y = 10, belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during challenge mode (Mythic+) out of combat.", belongsTo = "hideTipsDuringChallengeMode" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringChallengeModeExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during challenge mode (Mythic+) out of combat.", x = 160, belongsTo = "hideTipsDuringChallengeModeActionTips" });
end

priority = priority + 1;
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringInstanceHeader", label = "Priority #" .. priority .. ": Hide Tips During An Instance" });

tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringInstanceInCombat", label = "In Combat", belongsTo = "hideTipsDuringInstanceHeader" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", y = 10, belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", y = 10, belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", belongsTo = "hideTipsDuringInstanceInCombat" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) in combat.", x = 160, belongsTo = "hideTipsDuringInstanceInCombatActionTips" });

tinsert(ttOptionsHiding, { type = "TextOnly", var = "hideTipsDuringInstance", label = "Out Of Combat", y = 10, belongsTo = "hideTipsDuringInstanceHeader" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", y = 10, belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", y = 10, belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", belongsTo = "hideTipsDuringInstance" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringInstanceExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during an instance (Dungeon, Raid, PvP, Arena, Scenario) out of combat.", x = 160, belongsTo = "hideTipsDuringInstanceActionTips" });

if (LibFroznFunctions.hasWoWFlavor.skyriding) then
	priority = priority + 1;
	tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsDuringSkyridingHeader", label = "Priority #" .. priority .. ": Hide Tips During Skyriding" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingWorldUnits" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingWorldTips" });
	
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden during skyriding.", y = 10, belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingUnitTips" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden during skyriding.", belongsTo = "hideTipsDuringSkyridingHeader" });
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsDuringSkyridingExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden during skyriding.", x = 160, belongsTo = "hideTipsDuringSkyridingActionTips" });
end

priority = priority + 1;
tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsInCombatHeader", label = "Priority #" .. priority .. ": Hide Tips In Combat" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden in combat.", y = 10, belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden in combat.", belongsTo = "hideTipsInCombatHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsInCombatExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden in combat.", x = 160, belongsTo = "hideTipsInCombatActionTips" });

tinsert(ttOptionsHiding, { type = "Header", var = "hideTipsHeader", label = "Priority #" .. priority .. ": Hide Tips Out Of Combat" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsWorldUnits", label = "Hide World Units", tip = "When you have this option checked, World Units will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsFrameUnits", label = "Hide Frame Units", tip = "When you have this option checked, Frame Units will be hidden.", x = 160, belongsTo = "hideTipsWorldUnits" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsWorldTips", label = "Hide World Tips", tip = "When you have this option checked, World Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsFrameTips", label = "Hide Frame Tips", tip = "When you have this option checked, Frame Tips will be hidden.", x = 160, belongsTo = "hideTipsWorldTips" });

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsUnitTips", label = "Hide Unit Tips", tip = "When you have this option checked, Unit Tips will be hidden.", y = 10, belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsSpellTips", label = "Hide Spell Tips", tip = "When you have this option checked, Spell Tips will be hidden.", x = 160, belongsTo = "hideTipsUnitTips" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsItemTips", label = "Hide Item Tips", tip = "When you have this option checked, Item Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsActionTips", label = "Hide Action Bar Tips", tip = "When you have this option checked, Action Bar Tips will be hidden.", belongsTo = "hideTipsHeader" });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsExpBarTips", label = "Hide Exp Bar Tips", tip = "When you have this option checked, Experience Bar Tips will be hidden.", x = 160, belongsTo = "hideTipsActionTips" });

tinsert(ttOptionsHiding, { type = "Header", label = "Hide Other Tips" });

if (LibFroznFunctions:IsAddOnEnabled("Blizzard_EncounterJournal")) then
	tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsEJDungeonRaidSetItemsSTT", label = "Hide Shopping Tips of Dungeon/Raid/Set Items in Adventure Guide", tip = "When you have this option checked, Shopping Tips of Dungeon/Raid/Set Items in Adventure Guide will be hidden." });
end

tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnPets", label = "Hide Tips for My Own Pets/Minions", tip = "When you have this option checked, unit tooltips will be hidden for your own combat pets/minions (e.g. hunter pets including a 2nd Beast Mastery pet, warlock demons, death knight ghouls, mage water elementals). Pets/minions owned by other players are not affected." });
tinsert(ttOptionsHiding, { type = "Check", var = "hideTipsForOwnCompanions", label = "Hide Tips for My Own Companion Pets", tip = "When you have this option checked, unit tooltips will be hidden for your own summoned non-combat companion (vanity) pets. Companion pets owned by other players are not affected." });

tinsert(ttOptionsHiding, { type = "Header", label = "Others" });

tinsert(ttOptionsHiding, { type = "DropDown", var = "showHiddenModifierKey", label = "Show Hidden Tips While Holding", tip = "Hidden tips still show while this modifier key is held.", list = { { "Shift", "shift" }, { "Ctrl", "ctrl" }, { "Alt", "alt" }, { "|cffffa0a0None", "none" } } });

-- build options
local options = {
	-- Fading
	{
		category = "Fading",
		options = {
			{ type = "Header", label = "Fading for Unit Tooltips" },
			
			{ type = "Check", var = "overrideFade", label = "Enable Override Default GameTooltip Fade for Unit Tooltips", tip = "Overrides the default fadeout function of the GameTooltip for units. If you are seeing problems regarding fadeout, please disable." },
			
			{ type = "Slider", var = "preFadeTime", label = "Prefade Time", min = 0, max = 5, step = 0.05, enabled = function(factory) return factory:GetConfigValue("overrideFade") end, y = 10 },
			{ type = "Slider", var = "fadeTime", label = "Fadeout Time", min = 0, max = 5, step = 0.05, enabled = function(factory) return factory:GetConfigValue("overrideFade") end },
			
			{ type = "Header", label = "Others" },
			
			{ type = "Check", var = "hideWorldTips", label = "Instantly Hide World Frame Tips", tip = "This option will make most tips which appear from objects in the world disappear instantly when you take the mouse off the object. Examples such as mailboxes, herbs or chests.\nNOTE: Does not work for all world objects." },
		}
	},
	-- Anchors
	{
		category = "Anchors",
		enabled = { type = "Check", var = "enableAnchor", tip = "Turns on or off all modifications of the anchor" },
		options = ttOptionsAnchors
	},
	-- Hiding
	{
		category = "Hiding",
		options = ttOptionsHiding
	},
};

--------------------------------------------------------------------------------------------------------
--                                            Options Page                                            --
--------------------------------------------------------------------------------------------------------
-- One page in Blizzard's settings style (drawn by SettingsKit): a Graphics-style tab per category, "Priority #"
-- headers as collapsible sections like Keybindings', and Blizzard's checkboxes, dropdowns and sliders.

local TipTac = _G[PARENT_MOD_NAME];
local Kit = ns.SettingsKit;

-- passed to the options' enabled() functions, which expect the old options factory
local factory = {
	GetConfigValue = function(_, var) return cfg[var]; end,
};

local function SetConfigValue(var, value)
	cfg[var] = value;
	TipTac:ApplyConfig();
end

local function EnabledFn(option)
	if (not option.enabled) then
		return nil;
	end
	return function() return not not option.enabled(factory, nil, option, cfg[option.var]); end
end

local function FormatSliderValue(option)
	return function(value)
		if (option.step >= 1) then
			return ("%d"):format(value);
		end
		return ("%.2f"):format(value);
	end
end

local function DropdownOptions(list)
	local out = {};
	for _, entry in ipairs(list) do
		tinsert(out, { label = entry[1], value = entry[2] });
	end
	return out;
end

-- Reset every option to its default (cleared values read the default from the metatable)
local function ResetAll()
	for _, category in ipairs(options) do
		for _, option in ipairs(category.options or {}) do
			if (option.var) then
				cfg[option.var] = nil;
			end
		end
		if (category.enabled) and (category.enabled.var) then
			cfg[category.enabled.var] = nil;
		end
	end
	configDb:RegisterDefaults(configDb.defaults);
	TipTac:ApplyConfig();
end

-- collapsed "Priority #" sections are remembered in TipTac's config
cfg.optionsCollapsed = cfg.optionsCollapsed or {};
Kit.collapsed = cfg.optionsCollapsed;

local page = Kit.NewPage(PARENT_MOD_NAME, { onDefaults = ResetAll });

local tabNames = {};
for index, category in ipairs(options) do
	tabNames[index] = category.category;
end
local lists = page:Tabs(tabNames);

for index, category in ipairs(options) do
	local list = lists[index];

	-- category-wide switch (e.g. Anchors) and the anchor's position button
	if (category.enabled) then
		local option = category.enabled;
		list:Checkbox(option.label or ("Enable " .. category.category), function() return cfg[option.var]; end,
			function(value) SetConfigValue(option.var, value); end, option.tip);
	end
	if (category.category == "Anchors") then
		list:Button("Toggle Anchor", function() TipTac:SetShown(not TipTac:IsShown()); end,
			"Show or hide " .. PARENT_MOD_NAME .. "'s anchor, to set the position of tooltips using the Normal Anchor.");
	end

	for _, option in ipairs(category.options or {}) do
		local enabled = EnabledFn(option);
		if (option.type == "Header") then
			if (option.label:find("^Priority #")) then
				list:Expandable(option.label, { key = option.var or option.label:gsub("^Priority #%d+: ", ""), tooltip = option.tip, enabled = enabled });
			else
				list:Header(option.label, { enabled = enabled });
			end
		elseif (option.type == "TextOnly") then
			if (option.label) and (option.label ~= "") then
				list:Subheader(option.label);
			end
		elseif (option.type == "Separator") then
			list:Divider();
		elseif (option.type == "Check") then
			list:Checkbox(option.label, function() return cfg[option.var]; end,
				function(value) SetConfigValue(option.var, value); end, option.tip, { enabled = enabled });
		elseif (option.type == "DropDown") then
			list:Dropdown(option.label, DropdownOptions(option.list), function() return cfg[option.var]; end,
				function(value) SetConfigValue(option.var, value); end, option.tip, { enabled = enabled });
		elseif (option.type == "Slider") then
			list:Slider(option.label, option.min, option.max, option.step, function() return cfg[option.var]; end,
				function(value) SetConfigValue(option.var, value); end, FormatSliderValue(option), option.tip, { enabled = enabled });
		end
	end
end

Kit.Register(page);

-- open the options page (used by /tip, the addon compartment and TipTac:ToggleOptions)
function f:Open()
	Kit.Open(page);
end

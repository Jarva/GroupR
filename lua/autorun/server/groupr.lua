--[[
	Group Rewards (GroupR) by Jarva. (STEAM_0:1:58219414)
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
	Credit to the author must be given when using/sharing this work or derivative work from it.

	Credits:
		Time Utilities by Juholei1 (STEAM_0:0:37025247)
		GXML by Python1320 (STEAM_0:0:13073749) http://fcpn.ch/bIuTH
]]--
local GroupR = {}
GroupR.Config = {}

GroupR.Config.GroupID = 6048343 -- http://steamcommunity.com/groups/<GroupName>/edit
GroupR.Config.GroupURL = "http://steamcommunity.com/groups/DAOfficial"

GroupR.Config.JoinCommand = "!group"
GroupR.Config.RewardMessage = "Join our Steam Group and receive Member rank by typing !group"
GroupR.Config.RewardMessageInterval = 300 -- 0 to disable

GroupR.Config.MembershipCheckTimeInterval = 100
GroupR.Config.MembershipStatusMessage = "Your group membership status will be checked in %s."

GroupR.Config.AlreadyJoinedMessage = "You've already received your reward."
GroupR.Config.RankNotAllowedMessage = "Why would you want to down-rank yourself?"

GroupR.Config.AllowedRanks = { "user" } -- Example: { "*", "user", "superadmin" }

GroupR.Config.RewardSuccessMessage = "Thank you for joining our Steam Group, you're now a Member!"
GroupR.Config.RewardSuccessBroadcast = "%s has just joined our Steam Group and received the Member rank!"
GroupR.Config.RewardFunction = function(ply)
	--ULib.ucl.addUser(ply:SteamID(), nil, nil, "member")
	ply:ChatPrint("I love you")
end

require 'gxml'

hook.Add("PlayerSay", "GroupR", function(p ,t)
	if not IsValid(p) then return end
	if t:lower() ~= GroupR.Config.JoinCommand:lower() then return end

	if tobool(p:GetPData("GroupR")) then
		p:ChatPrint(GroupR.Config.AlreadyJoinedMessage)
		return false
	end

	p:SendLua('gui.OpenURL("'..GroupR.Config.GroupURL..'")')
	p:ChatPrint(string.format(GroupR.Config.MembershipStatusMessage, fancy_time_format(timer.TimeLeft("GroupR.GroupCheck"))))
end)

function GroupR.ProcessReward(p)
	if not IsValid(p) then return end

	if tobool(p:GetPData("GroupR")) then
		p:ChatPrint(GroupR.Config.AlreadyJoinedMessage)
		return false
	end

	if not (table.HasValue(GroupR.Config.AllowedRanks, p:GetNWString("usergroup")) or table.HasValue(GroupR.Config.AllowedRanks, "*")) then
		p:ChatPrint(GroupR.Config.RankNotAllowedMessage)
		return false
	end

	p:SetPData("GroupR", true)
	p:ChatPrint(GroupR.Config.RewardSuccessMessage)

	for k,v in ipairs(player.GetAll()) do
		if v == p then continue end
		v:ChatPrint(string.format(GroupR.Config.RewardSuccessBroadcast, p:Name()))
	end

	GroupR.Config.RewardFunction(p)
end

function GroupR.CheckGroup()
	http.Fetch("http://steamcommunity.com/gid/"..GroupR.Config.GroupID.."/memberslistxml/?xml=1", function(body)
		GroupR.GroupData = XMLToTable(body)
		GroupR.Members = GroupR.GroupData.memberList.members.steamID64
		for k,v in ipairs(player.GetAll()) do
			GroupR.ProcessReward(v)
		end
	end)
end
timer.Create("GroupR.GroupCheck", GroupR.Config.MembershipCheckTimeInterval, 0, GroupR.CheckGroup)
GroupR.CheckGroup()

if GroupR.Config.RewardMessageInterval > 0 then
	timer.Create("GroupR.MessageInterval", GroupR.Config.RewardMessageInterval, 0, function()
		for k,v in ipairs(player.GetAll()) do
			v:ChatPrint(GroupR.Config.RewardMessage)
		end
	end)
end

--[[
	Time Utilities
]]--

local math = math
local timeUnits = {
	{name = "hour"      , length = 60*60        },
	{name = "minute"    , length = 60           },
	{name = "second"    , length = 1            },
}
local function fancy_time_format(time_in_seconds)
	local results = {}
	time_in_seconds = math.max(0, time_in_seconds)
	for i = 1, #timeUnits do
		if time_in_seconds <= 0 then
			break
		end
		if time_in_seconds >= timeUnits[i].length then
			local amount = math.floor(time_in_seconds / timeUnits[i].length)
			local unit   = timeUnits[i].name
			if amount > 1 then
				unit = unit .. "s,"
			else
				unit = unit .. ","
			end
			results[#results + 1] = amount
			results[#results + 1] = unit
			time_in_seconds = time_in_seconds - amount * timeUnits[i].length
		end
	end
	local result = table.concat(results, " "):sub(1,-2)
	return result
end
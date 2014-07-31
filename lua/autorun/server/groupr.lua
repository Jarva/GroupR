--[[
Group Rewards (GroupR) by Jarva. (STEAM_0:1:58219414)
This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
Credit to the author must be given when using/sharing this work or derivative work from it.
]]

local GroupR = {}
GroupR.Config = {}

GroupR.Config.GroupID = 6048343 -- Found on the edit page of your group. Example: http://steamcommunity.com/groups/DAOfficial/edit
GroupR.Config.APIKey = "-API KEY-" -- You can get an API key from: https://steamcommunity.com/dev/apikey

GroupR.Config.GroupURL = "http://steamcommunity.com/groups/DAOfficial" -- This is the URL of your group.
GroupR.Config.JoinCommand = "!group" -- The command typed to join the group
GroupR.Config.RewardMessage = "Join our Steam Group and receive Member rank by typing !group" -- The message that is displayed at the below interval
GroupR.Config.RewardMessageInterval = 300 -- This is the time between each announcement. Set it to 0 to disable it.

GroupR.Config.MembershipStatusMessage = "Your group membership status will be checked in %s."

GroupR.Config.AlreadyJoinedMessage = "You've already received your reward." -- Message when the player has already received the reward.
GroupR.Config.RankNotAllowedMessage = "Why would you want down-rank yourself?" -- Message when the player is not in the allowed ranks.
GroupR.Config.AllowedRanks = { "user" } -- List of groups allowed to use the command. Add "*" to allow all users. Example: { "*" } or { "user", "superadmin" }

GroupR.Config.VerificationTime = 10 -- This is the time given for the player to join the group after typing the command.
GroupR.Config.RewardSuccessMessage = "Thank you for joining our Steam Group, you're now a Member!" -- Message sent to the player after they join the group.
GroupR.Config.RewardSuccessBroadcast = "%s has just joined our Steam Group and received the Member rank!" -- Message broadcasted to the server when they join the group.
GroupR.Config.RewardFunction = function(ply) -- Function that gives the player their reward.
	ULib.ucl.addUser(ply:SteamID(), nil, nil, "member")
end

SAPI.SetKey(GroupR.Config.APIKey)
hook.Add("PlayerSay", "GroupR", function(p,t)
	if t:lower() ~= GroupR.Config.JoinCommand:lower() then return end

	if tobool(p:GetPData("GroupR")) == true then
		p:ChatPrint(GroupR.Config.AlreadyJoinedMessage)
		return false
	end

	if not (table.HasValue(GroupR.Config.AllowedRanks, p:GetNWString("usergroup")) or table.HasValue(GroupR.Config.AllowedRanks, "*")) then
		p:ChatPrint(GroupR.Config.RankNotAllowedMessage)
		return false
	end

	p:SendLua('gui.OpenURL("'..GroupR.Config.GroupURL..'")')
	p:ChatPrint(string.format(GroupR.Config.MembershipStatusMessage, string.NiceTime(GroupR.Config.VerificationTime)))
	timer.Simple(GroupR.Config.VerificationTime, function()
		if not IsValid(p) then return end
		SAPI.GetUserGroupList(p:SteamID64(), function(data)
			local groups = {}
			for i=1,#data.response.groups do
				groups[i] = data.response.groups[i].gid
			end
			if table.HasValue(groups, tostring(GroupR.Config.GroupID)) and IsValid(p) then
				p:SetPData("GroupR", true)
				p:ChatPrint(GroupR.Config.RewardSuccessMessage)
				for k,v in ipairs(player.GetAll()) do
					if v == p then continue end
					v:ChatPrint(string.format(GroupR.Config.RewardSuccessBroadcast, p:Name()))
				end
				GroupR.Config.RewardFunction(p)
			end
		end)
	end)
	return false
end)

if GroupR.Config.RewardMessageInterval > 0 then
	timer.Create("GroupR", GroupR.Config.RewardMessageInterval, 0, function()
		for k,v in ipairs(player.GetAll()) do
			v:ChatPrint(GroupR.Config.RewardMessage)
		end
	end)
end

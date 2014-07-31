-- SAPI by Freezebug - http://fcpn.ch/dc8X8

SAPI = {}
SAPI.Version = "Hotel 1"

// NOTICE // 
// This is a list of game ID's me and my chubby little fingers compiled.
// If you want a FULL LIST of every possible gameid on steam, you're looking for 
// the following URL (NO API KEY IS NEEDED)
// [url]http://api.steampowered.com/ISteamApps/GetAppList/v2[/url]

    GAME_COUNTER_STRIKE  = 10
    GAME_TEAM_FORTRESS_CLASSIC = 20
    GAME_DAY_OF_DEFEAT = 30
    GAME_DEATHMATCH_CLASSIC = 40
    GAME_OPPOSING_FORCE = 50
    GAME_RICOCHET = 60
    GAME_HALF_LIFE = 70
    GAME_CONDITION_ZERO = 80
    GAME_HALF_LIFE_BLUE_SHIFT = 130
    GAME_HALF_LIFE_2 = 220
    GAME_COUNTER_STRING_SOURCE = 240
    GAME_HALF_LIFE_SOURCE = 280
    GAME_DAY_OF_DEFEAT_SOURCE = 300
    GAME_HALF_LIFE_2_DEATHMATCH = 320
    GAME_HALF_LIFE_LOST_COAST = 340
    GAME_HALF_LIFE_DEATHMATCH_SOURCE = 360
    GAME_HALF_LIFE_2_EPISODE_1 = 380
    GAME_HALF_LIFE_2_EPISODE_2 = 320
    GAME_HALF_LIFE_2_EPISODE_3 = nil
    GAME_TEAM_FORTRESS_2 = 440
    GAME_LEFT_4_DEAD = 500
    GAME_LEFT_4_DEAD_2 = 550
    GAME_DOTA_2 = 570
    GAME_PORTAL_2 = 620
    GAME_ALIEN_SWARM = 630
    GAME_COUNTER_STRIKE_GLOBAL_OFFENSIVE = 730 // or 1800? I don't know, it was documented twice, both with different IDs.
    GAME_SIN_EPISODES_EMERGENCE = 1300
    GAME_DARK_MESSIAH = 2100
    GAME_DARK_MESSIAH_MULTIPLAYER = 2130
    GAME_THE_SHIP = 2400
    GAME_THE_SHIP_TUTORIAL = 2400
    GAME_BLOODY_GOOD_TIME = 2450
    GAME_VAMPIRE_BLOODLINES = 2600
    GAME_GARRYSMOD = 4000
    GAME_ZOMBIE_PANIC = 17500
    GAME_AGE_OF_CHIVALRY = 17510
    GAME_SYNERGY = 17520
    GAME_DIPRIP = 17530
    GAME_ETERNAL_SILENCE = 17550
    GAME_PIRATES_VIKINGS_KNIGHTS = 17570
    GAME_DYSTOPIA = 17580
    GAME_INSURGENCY = 17700
    GAME_NUCLEAR_DAWN = 17710
    GAME_SMASHBALL = 17730
    
    local apikey = ""
    local apiurl = "http://api.steampowered.com/"
    local jdec = util.JSONToTable // futile attempt to make things faster
    local jenc = util.TableToJSON // futile attempt to make things faster
    local function checkkey()
        assert(#apikey > 1,"No API key is defined. Use SAPI.SetKey")
    end
    local function callbackCheck(code)
        assert(code~=401,"Authorization error (Is your key valid?)")
        assert(code~=500,"It seems the steam servers are having a hard time.") 
        assert(code~=404,"Not found.")
        assert(code~=400,"Bad module request.")
    end

        

    local function steamid_verify(id) 
        if string.find(id,"STEAM_") then 
            id = util.SteamIDTo64( tostring(id) ) 
        end
        assert(type(id)=="string" and id~=0,"An invalid steamid was passed. (Use Steam32 or Steam64)")
        return id
    end
            
    --[[---------------------------------------------------------
    Name: SAPI.SetKey(string key)
    Desc: Sets the STEAM API key.
    -----------------------------------------------------------]]
    function SAPI.SetKey(key)
        assert(type(key)=="string", "argument #1 to SetKey, string expected; got " .. type(key))
        assert(#key > 10,"The string provided is not a key.")
        apikey = key
    end
    
    --[[---------------------------------------------------------
    Name: SAPI.GetNewsForApp(appid,callback,[maxlen])
    Desc: Returns the news for a speicified app.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetNewsForApp(appid,callback,maxlen)
        checkkey()
        assert(type(appid)=="number", "argument #1 to GetNewsForApp, number expected; got " .. type(appid))
        assert(type(callback)=="function", "argument #2 to GetNewsForApp, function expected; got " .. type(callback))
        if !maxlen then maxlen = 300 end 
        http.Fetch(apiurl .. "ISteamNews/GetNewsForApp/v0002/?appid=" .. appid .. "&format=json&maxlen=" .. maxlen,
           function( body, _, _, code )
                  callbackCheck(code)
                  callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    --[[---------------------------------------------------------
    Name: SAPI.GetPlayerSummaries(steamid,callback)
    Desc: Returns the specified steamid's profile.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetPlayerSummaries(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetPlayerSummaries, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetPlayerSummaries, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "ISteamUser/GetPlayerSummaries/v0002/?key=" .. apikey .. "&steamids=" .. steamid .. "&format=json",
           function( body, _, _, code )
               callbackCheck(code)
               callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    --[[---------------------------------------------------------
    Name: SAPI.GetFriendList(steamid,callback,[bool use 32 bit steamid] = false) ==WARNING, the third argument if true is EXPENSIVE.==
    Desc: Returns the specified steamid's friends. 
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetFriendList(steamid,callback,u32steam)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetFriendList, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetFriendList, function expected; got " .. type(callback))
        if !u32steam then u32steam = false end
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "ISteamUser/GetFriendList/v0001/?key=" .. apikey .. "&steamid=" .. steamid .. "&format=json",
        function( body, _, _, code )
            if u32steam==false then 
                callbackCheck(code)
                callback(jdec(body))
            else
                local x = jdec(body)
               
                for I,om in pairs(x["friendslist"]["friends"]) do
                    x["friendslist"]["friends"][I]["steamid"] = util.SteamIDFrom64(x["friendslist"]["friends"][I]["steamid"])
                end
                print(x)
                callback(x)
            end
            
                    
            
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    
    --[[---------------------------------------------------------
    Name: SAPI.GetPlayerAchievements(steamid,appid,callback)
    Desc: Returns the specified steamid's achievements for the specified appid.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetPlayerAchievements(steamid,appid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetPlayerAchievements, string expected; got " .. type(steamid))
        assert(type(appid)=="number", "argument #2 to GetPlayerAchievements, number expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #3 to GetPlayerAchievements, function expected; got " .. type(callback))

        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "ISteamUserStats/GetPlayerAchievements/v0001/?key=" .. apikey .. "&steamid=" .. steamid .. "&appid=" .. appid .. "&format=json",
           function( body, _, _, code )
                callbackCheck(code)
                callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    
    
    --[[---------------------------------------------------------
    Name: SAPI.GetOwnedGames(steamid,callback)
    Desc: Returns the specified steamid's games.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetOwnedGames(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetOwnedGames, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetOwnedGames, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "IPlayerService/GetOwnedGames/v0001/?key=" .. apikey .. "&steamid=" .. steamid .. "&format=json",
           function( body, _, _, code )
           
                  callbackCheck(code)
                  callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    
    --[[---------------------------------------------------------
    Name: SAPI.GetUserGroupList(steamid,callback)
    Desc: Returns the specified steamid's groups.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetUserGroupList(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetUserGroupList, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetUserGroupList, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "ISteamUser/GetUserGroupList/v1/?key=" .. apikey .. "&steamid=" .. steamid .. "&format=json",
           function( body, _, _, code )
                  callbackCheck(code)
                  callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
    
    --[[---------------------------------------------------------
    Name: SAPI.GetPlayerBans(steamid,callback)
    Desc: Returns any bans or restrictions the specified account may or may not have.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetPlayerBans(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetPlayerBans, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetPlayerBans, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "ISteamUser/GetPlayerBans/v1/?key=" .. apikey .. "&steamids=" .. steamid .. "&format=json",
           function( body, _, _, code )
                callbackCheck(code)
                callback(jdec(body))
            end,
           function( error )
                  assert(false,error);
           end
        );
    end
    --[[---------------------------------------------------------
    Name: SAPI.GetSteamLevel(steamid,callback)
    Desc: Returns How many HL3 conspiracy theories begun during the time it took to execute the API call. 
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetSteamLevel(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetSteamLevel, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetSteamLevel, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "IPlayerService/GetSteamLevel/v1/?key=" .. apikey .. "&steamid=" .. steamid .. "&format=json",
           function( body, _, _, code )
                callbackCheck(code)
                callback(jdec(body))
            end,
           function( error )
                  assert(false,error);
           end
        );
    end
    
    
    --[[---------------------------------------------------------
    Name: SAPI.GetBadges(steamid,callback)
    Desc: Returns a players badges.
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.GetBadges(steamid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to GetBadges, string expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #2 to GetBadges, function expected; got " .. type(callback))
        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "IPlayerService/GetBadges/v1/?key=" .. apikey .. "&steamid=" .. steamid .. "&format=json",
           function( body, _, _, code )
                callbackCheck(code)
                callback(jdec(body))
            end,
           function( error )
                  assert(false,error);
           end
        );
    end
    --[[---------------------------------------------------------
    Name: SAPI.GetBadges(steamid,callback)
    Desc: Returns only the steamid of the player of which is lending the specified game appid ( Returns 0 if not sharing. )
    Callback: function(table)
    -----------------------------------------------------------]]
    function SAPI.IsPlayingSharedGame(steamid,appid,callback)
        checkkey()
        assert(type(steamid)=="string", "argument #1 to IsPlayingSharedGame, string expected; got " .. type(steamid))
        assert(type(appid)=="number", "argument #2 to IsPlayingSharedGame, number expected; got " .. type(steamid))
        assert(type(callback)=="function", "argument #3 to IsPlayingSharedGame function expected; got " .. type(callback))

        steamid = steamid_verify(steamid)
        http.Fetch(apiurl .. "IPlayerService/IsPlayingSharedGame/v0001/?key=" .. apikey .. "&steamid=" .. steamid .. "&appid=" .. appid .. "&format=json",
           function( body, _, _, code )
                callbackCheck(code)
                callback(jdec(body))
           end,
           function( error )
                  assert(false,error);
           end
        );
    end
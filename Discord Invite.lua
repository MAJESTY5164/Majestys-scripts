-- getgenv().DiscordInvite = "WPFYykM75b"

        local requestData = {
            cmd = 'INVITE_BROWSER',
            args = { code = getgenv().DiscordInvite },
            nonce = game:GetService("HttpService"):GenerateGUID(false)
        }
        
        local success, response = pcall((syn and syn.request) or http and http.request or http_request or (fluxus and fluxus.request) or request, {
            Url = 'http://127.0.0.1:6463/rpc?v=1',
            Method = 'POST',
            Headers = { ['Content-Type'] = 'application/json', ['Origin'] = 'https://discord.com' },
            Body = game:GetService("HttpService"):JSONEncode(requestData)
        })     

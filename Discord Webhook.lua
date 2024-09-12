function SendMessage(url, message)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["content"] = message
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end

function SendMessageEMBED(url, embed)
    local http = game:GetService("HttpService")
    local headers = {
        ["Content-Type"] = "application/json"
    }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = {
                    ["text"] = embed.footer.text
                }
            }
        }
    }
    local body = http:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
end


--Examples 

local url = "https://discord.com/api/webhooks/1280676568426877042/VNags7CmQg1EJZLBH4Ej_aAQR8ldCzPAVayK2B_hJEoCNZ9eqjbeNxDSEvi9NU_2Voue"

local embed = {
    ["title"] = getgenv().hooktitle,
    ["description"] = "",
    ["color"] = 0,
    ["fields"] = {
        {
            ["name"] = "Hub Version",
            ["value"] = getgenv().Version
        },
        {
            ["name"] = "Executor",
            ["value"] = getgenv().Executor
        },
        {
            ["name"] = "Game",
            ["value"] = GameName
        }
    },
    ["footer"] = {
        ["text"] = ""
    }
}
SendMessageEMBED(url, embed)

--[[
getgenv().hooktitle = "Title"

getgenv().hookcontents = {
"test 1",
"test 1",
"test 2",
"test 2",
}
]]

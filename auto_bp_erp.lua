local sampev = require 'lib.samp.events'
local inicfg = require "inicfg"


dcf = getWorkingDirectory().."\\config\\abp.ini"
mainIni = inicfg.load(nil,dcf)

local autoBP = 1

function main()
if not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end

    while true do
        wait(0)
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 20057 then
        GetAutoBP()
    end
end

function GetAutoBP()
    if mainIni then
        local gun = {}
        if mainIni.abp.deagle then table.insert( gun, 0) end
        if mainIni.abp.shot then table.insert( gun,1 ) end
        if mainIni.abp.smg then table.insert( gun,2 ) end
        if mainIni.abp.m4 then table.insert( gun,3 ) end
        if mainIni.abp.rifle then table.insert( gun,4 ) end
        if mainIni.abp.armour then table.insert( gun,5 ) end
        if mainIni.abp.spec then table.insert( gun,6 ) end
        lua_thread.create(function()
            wait(100)
            if autoBP == #gun + 1 then -- остановка авто-бп 
                autoBP = 1
                if mainIni.abp.close then
                    sampCloseCurrentDialogWithButton(0)
                end
            elseif gun[autoBP] == 5 then
                autoBP = autoBP + 1
                wait(100)
                sampSendDialogResponse(20057, 1, 5)
                wait(500)
                sampSendDialogResponse(32700, 1, 2)
                wait(100)
                sampCloseCurrentDialogWithButton(0)
                return
            else
                sampSendDialogResponse(20057, 1, gun[autoBP])
                autoBP = autoBP + 1
            end
        end)
    end
end
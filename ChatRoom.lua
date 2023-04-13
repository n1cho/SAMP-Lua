require 'luaircv2'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local connected = false
local sentText = false
users = ''
local check_online = false
local online = 0

local inicfg = require "inicfg"
local imgui = require 'imgui'

mws = imgui.ImBool(false)
sw,sh = getScreenResolution()
function imgui.OnDrawFrame()
    if not mws.v then imgui.Process = false end

    imgui_teg = imgui.ImBuffer(u8(mainIni.config.teg),64)
    code_kk=imgui.ImBuffer(u8(mainIni.config.code),10)
    text_pozivnoi = imgui.ImBuffer(u8(mainIni.config.pozivnoi),32)
    color_teg = imgui.ImBuffer(u8(mainIni.config.color_teg),7)
    color_pozivnoi = imgui.ImBuffer(u8(mainIni.config.color_pozivnoi),7)
    color_text = imgui.ImBuffer(u8(mainIni.config.color_text),7)

    if mws.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 245), imgui.Cond.FirstUseEver) -- resoluthion window
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2),sh/2),imgui.Cond.FirstUseEver,imgui.ImVec2(0.5,0.5)) -- in center monitor

        imgui.Begin(u8'Настройки',mws)

        imgui.PushItemWidth(150)
        if imgui.InputText(u8'Введите название чата (без [])',imgui_teg) then 
            mainIni.config.teg = u8:decode(imgui_teg.v) 
        end 

        if imgui.InputText(u8'Введите код чат-рума',code_kk) then 
            mainIni.config.code = u8:decode(code_kk.v) 
        end 

        imgui.SameLine()

        if imgui.Button(u8'Подключится') then
            s:disconnect()
            IRCConnect()
        end

        if imgui.InputText(u8'Введите ваш позывной',text_pozivnoi) then 
            mainIni.config.pozivnoi = u8:decode(text_pozivnoi.v) 
        end 

        imgui.Text(u8('Цвет:'))
        if imgui.InputText(u8'Тега',color_teg) then 
            mainIni.config.color_teg = u8:decode(color_teg.v) 
        end
        if imgui.InputText(u8'Позывного',color_pozivnoi) then 
            mainIni.config.color_pozivnoi = u8:decode(color_pozivnoi.v) 
        end 
        if imgui.InputText(u8'Текста',color_text) then 
            mainIni.config.color_text = u8:decode(color_text.v) 
        end
        imgui.Text(u8('/kk - отправить сообщение в чат'))
        imgui.Text(u8('/konl - посмотреть онлайн КК'))
        imgui.Text(u8('Автор скрипта - Arthur Nicho'))
        imgui.PopItemWidth()
        inicfg.save(mainIni,path)
        imgui.End()
    end
end




function main()
    if not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end

    ip, port = sampGetCurrentServerAddress()
    
    path = getWorkingDirectory()..'\\kk_setting.ini'
    mainIni = inicfg.load(nil,path)

    style()
    while not sampIsLocalPlayerSpawned() do wait(0) end
    stext('Скрипт загружен, для отправки сообщения - {DCDCDC}/kk{FFFFFF},для настроек - {DCDCDC}/kmenu{FFFFFF}.by - Arthur Nicho')
    _,MyId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    MyName = sampGetPlayerNickname(MyId)

    s = irc.new{nick = MyName}
    IRCConnect()

    sampRegisterChatCommand('kmenu',function()
        mws.v = not mws.v
        imgui.Process = mws.v
    end)
    sampRegisterChatCommand('konl',function()
        if s.__isConnected and s.__isJoined then
            check_online = true
            s:send('NAMES %s','#'..ip..mainIni.config.code)
        else
            stext('Вы ещё не подключились к серверу')
        end
    end)
    sampRegisterChatCommand('kk',onIRCSendMessage)
    while true do
        wait(500)
        if s.__isConnected and sentText then
            stext('Вы подключились к каналу')
            s:prejoin('#'..ip..mainIni.config.code)
            sentText = false
        end
        s:think()
    end
end

--------- IRC ---------------

function onIRCMessage(user,channel,message)
    if sampGetPlayerIdByNickname(user.nick) then
        id = sampGetPlayerIdByNickname(user.nick)
        scolor=string.format("%06X", ARGBtoRGB(sampGetPlayerColor(id)))
        message = u8:decode(message)
        if message:match('%{.+%}%«.+%»%{.+%} .+') then
            poziv,message = message:match('({.+}«.+»{.+}) (.+)')
        else
            poziv = ''
        end
        sampAddChatMessage(string.format('{%s}[%s] {%s}%s [%s]{FFFFFF}: %s {%s} %s',mainIni.config.color_teg,mainIni.config.teg,scolor,user.nick,id,poziv,mainIni.config.color_text,message),-1)
    else        
        sampAddChatMessage(string.format('{%s}[%s]{%s} %s: %s',mainIni.config.color_teg,mainIni.config.teg,mainIni.config.color_text,user.nick,u8:decode(message)),-1)
    end
end

function onIRCSendMessage(param)
    if s.__isConnected then
        if mainIni.config.pozivnoi and not (param == '' or param == ' ' or param == nil)then
            pred_text = string.format('{%s}«%s»{FFFFFF} ',mainIni.config.color_pozivnoi,mainIni.config.pozivnoi)
            params = pred_text..param
        end
        s:sendChat('#'..ip..mainIni.config.code,u8(tostring(params)))
        sampAddChatMessage(string.format('{%s}[%s] {%s}%s [%s]{FFFFFF}: %s{%s} %s',mainIni.config.color_teg,mainIni.config.teg,string.format("%06X", ARGBtoRGB(sampGetPlayerColor(MyId))),MyName,MyId,pred_text,mainIni.config.color_text,param),-1)
    else
        stext('Вы ещё не подключились к серверу')
    end
end

function IRCConnect()
    stext('Подключаюсь к серверу...')
    s:connect("irc.esper.net")

    s:hook("OnChat",onIRCMessage)
    s:hook("OnJoin", onIRCJoin)
    s:hook("OnPart",onIRCPart)
    s:hook("OnQuit",onIRCPart)
    s:hook("OnKick", onIRCKick)
    s:hook("OnRaw", onIRCRaw)

    connected = true
    sentText = true
end

function onIRCJoin(user, channel)
    ConnectID = sampGetPlayerIdByNickname(user.nick)
    if sampIsPlayerConnected(ConnectID) then
        stext(string.format('%s [%s] подключился к каналу',user.nick,ConnectID))
    end
end

function onIRCPart(user)
    stext(string.format('%s вышел из сервера',user.nick))
end



function onScriptTerminate(scr,quitGame)
    if scr == script.this then
        stext('Вы были кикнуты с канала, за длительное бездействие')
    end
end

function onIRCKick(channel, nick, kicker, reason)
    stext(string.format('%s кикнут из канала',user.nick))
end

function onIRCRaw(line)
    if check_online and line:find('353') then
        nicks = line:match('.+%:(.+)')
        list=GetOnlineList(nicks,users)
        sampShowDialog(8048, "Онлайн", list..'{FFFFFF} Всего: '..online, "OK", "", 0)
        users = ''
        online = 0
        check_online = false
    end
end
-------------------------------------------------

function GetOnlineList(nicks,users)
    for w in string.gmatch(nicks,"(%w+%_%w+)") do
        online = online + 1
        id = sampGetPlayerIdByNickname(w)
        if id then
            users = users..'{'..string.format("%06X", ARGBtoRGB(sampGetPlayerColor(id)))..'} '..w..'['..id..']\n'
        else
            users = users..'{'..string.format("%06X", ARGBtoRGB(sampGetPlayerColor(id)))..'} '..w..'\n'
        end
        nick=nicks:gsub(w,' ')
        nicks = nick
    end
    for w in string.gmatch(nicks,"(%w+)") do
        online = online + 1
        users = users..'{FFFFFF} '..w..'\n'
    end
    return users
end

function stext(arg)
    sampAddChatMessage('{DCDCDC}[ChatRoom]{FFFFFF} '..arg,-1)
end

function sampGetPlayerIdByNickname(nick)
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    if tostring(nick) == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1000 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then return i end end
end


function getColor(ID)
	PlayerColor = sampGetPlayerColor(id)
	a, r, g, b = explode_argb(PlayerColor)
	return r/255, g/255, b/255, 1
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function ARGBtoRGB(color)
    local a = bit.band(bit.rshift(color, 24), 0xFF)
    local r = bit.band(bit.rshift(color, 16), 0xFF)
    local g = bit.band(bit.rshift(color, 8), 0xFF)
    local b = bit.band(color, 0xFF)
    local rgb = b
    rgb = bit.bor(rgb, bit.lshift(g, 8))
    rgb = bit.bor(rgb, bit.lshift(r, 16))
    return rgb
end

function style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

    colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 0.95)
    colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
    colors[clr.ChildWindowBg] = ImVec4(0.13, 0.12, 0.12, 1.00)
    colors[clr.PopupBg] = ImVec4(0.05, 0.05, 0.05, 0.94)
    colors[clr.Border] = ImVec4(0.53, 0.53, 0.53, 0.46)
    colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg] = ImVec4(0.00, 0.00, 0.00, 0.85)
    colors[clr.FrameBgHovered] = ImVec4(0.22, 0.22, 0.22, 0.40)
    colors[clr.FrameBgActive] = ImVec4(0.16, 0.16, 0.16, 0.53)
    colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive] = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.MenuBarBg] = ImVec4(0.12, 0.12, 0.12, 1.00)
    colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive] = ImVec4(0.48, 0.48, 0.48, 1.00)
    colors[clr.ComboBg] = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark] = ImVec4(0.79, 0.79, 0.79, 1.00)
    colors[clr.SliderGrab] = ImVec4(0.48, 0.47, 0.47, 0.91)
    colors[clr.SliderGrabActive] = ImVec4(0.56, 0.55, 0.55, 0.62)
    colors[clr.Button] = ImVec4(0.50, 0.50, 0.50, 0.63)
    colors[clr.ButtonHovered] = ImVec4(0.67, 0.67, 0.68, 0.63)
    colors[clr.ButtonActive] = ImVec4(0.26, 0.26, 0.26, 0.63)
    colors[clr.Header] = ImVec4(0.54, 0.54, 0.54, 0.58)
    colors[clr.HeaderHovered] = ImVec4(0.64, 0.65, 0.65, 0.80)
    colors[clr.HeaderActive] = ImVec4(0.25, 0.25, 0.25, 0.80)
    colors[clr.Separator] = ImVec4(0.58, 0.58, 0.58, 0.50)
    colors[clr.SeparatorHovered] = ImVec4(0.81, 0.81, 0.81, 0.64)
    colors[clr.SeparatorActive] = ImVec4(0.81, 0.81, 0.81, 0.64)
    colors[clr.ResizeGrip] = ImVec4(0.87, 0.87, 0.87, 0.53)
    colors[clr.ResizeGripHovered] = ImVec4(0.87, 0.87, 0.87, 0.74)
    colors[clr.ResizeGripActive] = ImVec4(0.87, 0.87, 0.87, 0.74)
    colors[clr.CloseButton] = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered] = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive] = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines] = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.PlotLinesHovered] = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.PlotHistogram] = ImVec4(0.90, 0.77, 0.33, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(0.87, 0.55, 0.08, 1.00)
    colors[clr.TextSelectedBg] = ImVec4(0.47, 0.60, 0.76, 0.47)
    colors[clr.ModalWindowDarkening] = ImVec4(0.88, 0.88, 0.88, 0.35)

end
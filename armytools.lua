 -- Copyright (c) 2023 Tur41ks Prod.

-- ���������� � �������
script_name('�Army-Tools�') 	-- ��������� ��� �������
script_version(1.8) 			-- ��������� ������ �������
script_author('Henrich_Rogge,Arthur_Nicho') 	-- ��������� ��� ������

require('lib.moonloader')
require('lib.sampfuncs')

local sampev = require('lib.samp.events')
local vkeys = require('vkeys')
local rkeys = require('rkeys')
local imgui = require('imgui')
local imadd = require('imgui_addons')
local lfs = require('lfs')
local encoding = require('encoding')
local memory = require('memory')
local bitex = require('bitex')
local copas = require('copas')
local http = require('copas.http')
local ffi = require('ffi')
if doesFileExist(getWorkingDirectory()..'/lib/imgui_piemenu.lua') then
	lpie,pie = pcall(require,"imgui_piemenu")
	assert(lpie,'���������� "imgui_piemenu.lua" �� �������')
else
	downloadUrlToFile('https://raw.githubusercontent.com/n1cho/SAMP-Lua/main/lib/imgui_piemenu.lua',getWorkingDirectory()..'/lib/imgui_piemenu.lua')
	thisScript():reload()
end
------------------
encoding.default = 'CP1251'
u8 = encoding.UTF8
dlstatus = require('moonloader').download_status
imgui.ToggleButton = imadd.ToggleButton
imgui.HotKey = imadd.HotKey
x, y = getScreenResolution()
------------------

ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]
BuffSize = 32
KeyboardLayoutName = ffi.new('char[?]', BuffSize)
inputInfo = ffi.new('char[?]', BuffSize)

local updatesInfo = {
	version = thisScript().version,
	type = '�������� ����������', -- �������� ����������, ������������� ����������, ����������� ����������, ����
	date = '15.12.2023',
	list = {
		{ '���������� �������� � ��������;'},
		{"��������� Fast Menu, � ������������ ��� �������������;"},
		{"��������� ��������� ���� �������. �� ��������� ��������� �� ������� - �;"},
		{"��������� ������� ���:  �����, ������������ � �����-����;"},
		{'��������� ����������� �������� ����� ������� ������� ��� ����� ������� /members;'},
		{'��������� ������� ������ ����� �������, ������� ����� �� ����;'}
	}
}

local paths = {
	config = 'moonloader/Army-Tools/configVER1.4.json',
	fastmenu = 'moonloader/Army-Tools/configFastMenu.json'
}

local config = {
	options = {
		pg = false,
		tag = 'YouTag',
		tagbool = false,
		clist = 0,
		clistbool = false,
		modradiobool = false,
		giverank = false,
		membersdate = false,
		modmembers = false,
		rank = 0,
		sex = nil,
		target = true,
		hud = true,
		hudX = x / 1.5,
		hudY = y - 250,
		hudset = { false, true, true, true, true, true, true, true, false, true },
		hudopacity = 1.0,
		hudrounding = 0.0,
		autodoklad = false,
		autologin = false,
		password = '',
		inputhelper = false,
		useautobp = false,
		timer = { false, false, false},
		showquit = false
	},
	info = {
		day = os.date('%d.%m.%y'),
		dayOnline = 0,
		dayAFK = 0,
		thisWeek = 0,
		dayPM = 0,
		weekPM = 0,
		weekOnline = 0,
		weekWorkOnline = 0,
		dayWorkOnline = 0
	},
	autoBP = {
		deagle=true,
		spec=false,
		close=true,
		m4=true,
		shot=false,
		armour=true,
		rifle=true,
		smg=false
	},
	weeks = { 0, 0, 0, 0, 0, 0, 0 },
	counter = { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
	ranknames = { '�������', '��������', '��.�������', '�������', '��.�������', '��������', '���������', '��.���������', '���������', '��.���������', '�������', '�����', '������������', '���������', '�������' }
}

local configKeys = { punaccept = { v = { vkeys.VK_Y } }, menuscript = {v = {vkeys.VK_M}}, fastmenu = {v = {vkeys.VK_Z}} }
local configCommandBinder = {}
local configButtonBinder = {}
local configFastMenu = {
	{
		name = "��������",
		items={{
			pause = 1000,
			name="�������",
			text = "/showpass {targetid}"
		},
		{
			pause=1000,
			name="��������",
			text="/showlicenses {targetid}"
		}}
	},
	{	
		name="���������",
		items ={{
			pause = 1000,
			name = "���������",
			text = "������� �����, {rank} {myrpnick}. ���������� ���� ���������"
		},
		{
			pause=1000,
			name ="���������",
			text="/r {mytag} ���������� ���������. ������� - {kv}"
		},
		{
			pause=1000,
			name="����������",
			text="/r {mytag} ���������� ����������"
		}}
	},
	{
		name="��������",
		items = {{
			pause=1000,
			name="�������",
			text ="/me ������� ���� �������� ��������, ����� ������ ������� � ������ ��������\n/tie {targetid}"
		},
		{
			pause=1000,
			name="���������",
			text="/do �� ���� ����������� ������ ��� ����\n/me ������ �� ������ ���, ����� ������ ��������� �������� ������\n/untie {targetid}"
		}}
	},
	{
		name="��������",
		items = {{
			pause = 1000,
			name = "�������� ����������",
			text = "/s �������� ���������� {frac}, ��� ��� 15 ������! ����� �� ����� ��������� ������� �����"
		},
		{
			pause = 1000,
			name = "��� ���������",
			text = "/s ��� ��������� ����������� ���������� {frac} ����� ������ ����� ��� ��������������."
		},
		{
			pause = 1000,
			name = "������ �������� ���",
			text = "/s ����� ������ �������� ������� �������, ����� ������������� ��� ���������."
		}}
	}
}

local tempConfig = {
	workingDay = false,
	vehicleId = nil,
	authTime = nil,
	updateAFK = 0,
	mySkin = nil,
	myId = nil,
	myNick = '',
	fraction = '',
	rank = 0,
	health = 0,
	armour = 0,
	maska = ''
}

local timers = {
	mask = 0,
	dep = 0,
	ffix = 0
}

local dayName = { '�����������', '�������', '�����', '�������', '�������', '�������', '�����������' }
local counterNames = { '������� �������', '������� �������', '�������� �������', '��������� ������ (/lecture)', '��������� �� �����', '��������� �� ���', '��������� ����', '�������� �� LVa', '�������� �� SFa' }
local ranknames = { '�������', '��������', '��.�������', '�������', '��.�������', '��������', '���������', '��.���������', '���������', '��.���������', '�������', '�����', '������������', '���������', '�������' }
local fractions = { ['SFA'] = true, ['LVA'] = true, ['LSPD'] = false, ['SFPD'] = false, ['LVPD'] = false, ['Instructors'] = false, ['FBI'] = false, ['Medic'] = false, ['Mayor'] = false }
local reason_quit = {[0] = 'TimedOut',[1] = '�����',[2] = 'Kick/Ban'}

local tempFiles = {
	blacklist = {},
	blacklistTime = 0
}

local targetMenu = {
	playerid = nil,
	show = false,
	coordX = 135,
	time = nil,
	cursor = nil
}

local localInfo = {
	autopost = {
		title = '����-��������',
		load = {'�������� ���������', '�� ����� ���� - {id}. ���������� �� ���������. ���� ���� �� �� Army LV.', '�� ����� ���� - {id}. ����������� �� ���������. ���� ���� �� �� Army LV.'},
		unload = {'��������� ���������', '�� ����� ���� - {id}. ����������� �� �� Army LV. ��������� - {sklad}/300', '�� ����� ���� - {id}. ������������ �� �� Army LV. ��������� - {sklad}/300'},
		start = {'����� ��������', '�� ����� ���� - {id}. ����� �������� ����������� �� �� Army LV.', '�� ����� ���� - {id}. ������� �������� ����������� �� �� Army LV.'},
		ends = {'�������� ��������', '�� ����� ���� - {id}. �������� �������� �� �� Army LV.', '�� ����� ���� - {id}. ��������� �������� �� �� Army LV.'},
		startp = {'����� �������� � �����', '10-15', '10-15'},
		endp = {'�������� �������� � �����', '10-16', '10-16'},
		load_boat = {'�������� ���������, ����� � ��� (�����)', '�� ����� ���� - {id}. ���������� �� ���������. ���� ���� �� �� Army SF.', '�� ����� ���� - {id}. ����������� �� ���������. ���� ���� �� �� Army SF.'},
		load_boat_lsa = {'�������� ���������, ����� � ���� �� (�����)', '�� ����� ���� - {id}. ���������� �� ���������. ���� ���� �� �� ����� ��.', '�� ����� ���� - {id}. ����������� �� ���������. ���� ���� �� �� ����� ��.'},
		unload_boat = {'��������� ��������� � ��� (�����)', '�� ����� ���� - {id}. ����������� �� �� Army SF. ��������� - {sklad}/300', '�� ����� ���� - {id}. ������������ �� �� Army SF. ��������� - {sklad}/300'},
		start_boat = {'����� �������� � ��� (�����)', '�� ����� ���� - {id}. ����� �������� �� �� Army SF.', '�� ����� ���� - {id}. ������� �������� �� �� Army SF.'},
		start_boat_lsa = {'����� �������� � ���� (�����)', '�� ����� ���� - {id}. ����� �������� � ���� ��.', '�� ����� ���� - {id}. ������� �������� � ���� ��.'},
		unload_boat_lsa = {'��������� ��������� � ����� (�����)', '�� ����� ���� - {id}. ����������� � ����� ��. ��������� - {sklad}/200', '�� ����� ���� - {id}. ������������ � ����� ��. ��������� - {sklad}/200'},
		ends_boat = {'�������� �������� (�����)', '�� ����� ���� - {id}. �������� �������� �� �� Army SF.', '�� ����� ���� - {id}. ��������� �������� �� �� Army SF.'},
		ends_boat_lsa = {'�������� �������� (�����)', '�� ����� ���� - {id}. �������� �������� � ���� ��.', '�� ����� ���� - {id}. ��������� �������� � ���� ��.'}
	},
	lvapost = {
		title = '����-�������� LVA',
		start = {'����� ��������', '���� �������� ���������!', '����� �������� ���������!'},
		unload = {'����������� �� ������', '������������ �� ������ {frac}. ��������� - {sklad}. ������� - {gps}', '������������ �� ������ {frac}. ��������� - {sklad}. ������� - {gps}'},
		unloadgs = {'���������� �� ������', '����������� �� ������� ������!', '������������ �� ������� ������!'}
	},
	post = {
		title = '����-������',
		ends = {'������� ����', '������� ����: �{post}�.', '�������� ����: �{post}�.' },
		start = {'�������� �� ����', '�������� �� ����: �{post}�.', '��������� �� ����: �{post}�.'},
		doklad = {'������', '����: �{post}�. ���������� ������: {count}. ���������: code 1', '����: �{post}�. ���������� ������: {count}. ���������: code 1'}
	},
	punaccept = {
		title = '�������� � ��������',
		blag = {'�������� �������������', '/d {frac}, ������� ������������� {id} �� {reason}', '/d {frac}, ������� ������������� {id} �� {reason}'},
		vig = {"������ �������", "{id} �������� {type} ������� �� {reason}", "{id} �������� {type} ������� �� {reason}"},
		loc = {"��������� ��������������", '{nick}, ���� ��������������? �� ����� {sec} ������.', '{nick}, ���� ��������������? �� ����� {sec} ������.'},
		naryad = {"������ �����", '{id} �������� ����� {count} ������ �� {reason}', '{id} �������� ����� {count} ������ �� {reason}'}
	},
	rp = {
		title = '�� ���������',
		uninvite = {'��������� ����������', '/me ������ ���, ����� ���� ������� ������ ���� {nick} ��� �������', '/me ������� ���, ����� ���� �������� ������ ���� {nick} ��� �������'},
		giverank = {'��������� ���������', '/me ������ {type} {rankname}�, � ������� �� �������� ��������', '/me ������� {type} {rankname}�, � �������� �� �������� ��������'},
		uninviter = {'��������� ���������� (/r)', '���� {nick} ������ �� �����. �������: {reason}', '���� {nick} ������ �� �����. �������: {reason}'},
	},
	others = {
		title = '���������',
		viezd = {'��������� ����� �� ����������', '{frac}, �������� �����', '{frac}, �������� �����'},
		mon = {'���������� (SFA)', '��������� ������ ����� LV - {sklad} ����', '��������� ������ ����� LV - {sklad} ����'},
		monl = {'���������� (LVA)', '������: LSPD - {lspd} | SFPD - {sfpd} | LVPD - {lvpd} | SFa - {sfa} | FBI - {fbi}', '������: LSPD - {lspd} | SFPD - {sfpd} | LVPD - {lvpd} | SFa - {sfa} | FBI - {fbi}'},
		ev = {'��������� ���������', '���������� ���������! ������: {kv}, ���������� ����: {mesta}', '���������� ���������! ������: {kv}, ���������� ����: {mesta}'}
	}
}

local getPosts = {
	{ '���', -1530.65, 480.05, 7.19, 16 },
	{ '����', -1334.59, 477.46, 9.06, 11 },
	{ '������', -1367.36, 517.50, 11.20, 10 },
	{ '����� 1', -1299.44, 498.90, 11.20, 12 },
	{ '����� 2', -1410.75, 502.03, 11.20, 14 },
	{ '���� 1', -1457.57, 355.17, 7.18, 13 },
	{ '���� 2', -1457.55, 390.83, 7.18, 13 },
	{ '���� 3', -1457.19, 426.95, 7.18, 13 },
	{ '����', 135.2195, 1928.5598, 19.2065, 15 },
	{ '��', 144.2770, 1876.6501, 18.0148, 15 },
	{ '�����-1', 142.6142, 1842.5087, 17.6406, 15 },
	{ '����', 211.9541, 1810.4440, 21.8672, 20 },
	{ '����', 338.9109, 1804.5820, 18.0012, 15 },
	{ '��', 331.0642, 1937.4352, 17.6665, 20 },
	{ '�����-2', 283.3381, 1954.7589, 17.6406, 15 },
	{ '�����-3', 280.8460, 1990.0000, 17.6406, 15 },
	{ '��', 247.9268, 1968.6095, 17.6666, 15 },
	{ '����', 212.4058, 1920.2151, 17.6465, 15 },
	{ '���-2', 2720.6206, -2504.3625, 13.4869, 15 },
	{ '���-1', 2720.8896, -2405.3481, 13.4609, 15 }
}
local configPosts = {
	{ name = '���', coordX = -1530.65, coordY = 480.05, coordZ = 7.19, radius = 16 },
	{ name = '����', coordX = -1334.59, coordY = 477.46, coordZ = 9.06, radius = 11 },
	{ name = '������', coordX = -1367.36, coordY = 517.50, coordZ = 11.20, radius = 10 },
	{ name = '����� 1', coordX = -1299.44, coordY = 498.90, coordZ = 11.20, radius = 12 },
	{ name = '����� 2', coordX = -1410.75, coordY = 502.03, coordZ = 11.20, radius = 14 },
	{ name = '���� 1', coordX = -1457.57, coordY = 355.17, coordZ = 7.18, radius = 13 },
	{ name = '���� 2', coordX = -1457.55, coordY = 390.83, coordZ = 7.18, radius = 13 },
	{ name = '���� 3', coordX = -1457.19, coordY = 426.95, coordZ = 7.18, radius = 13 },
	{ name = '����', coordX = 135.2195, coordY = 1928.5598, coordZ = 19.2065, radius = 15 },
	{ name = '��', coordX = 144.2770, coordY = 1876.6501, coordZ = 18.0148, radius = 15 },
	{ name = '�����-1', coordX = 142.6142, coordY = 1842.5087, coordZ = 17.6406, radius = 15 },
	{ name = '����', coordX = 211.9541, coordY = 1810.4440, coordZ = 21.8672, radius = 20 },
	{ name = '����', coordX = 338.9109, coordY = 1804.5820, coordZ = 18.0012, radius = 15 },
	{ name = '��', coordX = 331.0642, coordY = 1937.4352, coordZ = 17.6665, radius = 20 },
	{ name = '�����-2', coordX = 283.3381, coordY = 1954.7589, coordZ = 17.6406, radius = 15 },
	{ name = '�����-3', coordX = 280.8460, coordY = 1990.0000, coordZ = 17.6406, radius = 15 },
	{ name = '��', coordX = 247.9268, coordY = 1968.6095, coordZ = 17.6666, radius = 15 },
	{ name = '����', coordX = 212.4058, coordY = 1920.2151, coordZ = 17.6465, radius = 15 },
	{ name = '���-2', coordX = 2720.6206, coordY = -2504.3625, coordZ = 13.4869, radius = 15 },
	{ name = '���-1', coordX = 2720.8896, coordY = -2405.3481, coordZ = 13.4609, radius = 15 }
}

local post = {
  interval = 180,
  lastpost = 0,
  next = 0,
  active = false,
}

local tCarsName = { 'Landstalker', 'Bravura', 'Buffalo', 'Linerunner', 'Perrenial', 'Sentinel', 'Dumper', 'Firetruck', 'Trashmaster', 'Stretch', 'Manana', 'Infernus',
'Voodoo', 'Pony', 'Mule', 'Cheetah', 'Ambulance', 'Leviathan', 'Moonbeam', 'Esperanto', 'Taxi', 'Washington', 'Bobcat', 'Whoopee', 'BFInjection', 'Hunter',
'Premier', 'Enforcer', 'Securicar', 'Banshee', 'Predator', 'Bus', 'Rhino', 'Barracks', 'Hotknife', 'Trailer', 'Previon', 'Coach', 'Cabbie', 'Stallion', 'Rumpo',
'RCBandit', 'Romero','Packer', 'Monster', 'Admiral', 'Squalo', 'Seasparrow', 'Pizzaboy', 'Tram', 'Trailer', 'Turismo', 'Speeder', 'Reefer', 'Tropic', 'Flatbed',
'Yankee', 'Caddy', 'Solair', 'Berkley\'sRCVan', 'Skimmer', 'PCJ-600', 'Faggio', 'Freeway', 'RCBaron', 'RCRaider', 'Glendale', 'Oceanic', 'Sanchez', 'Sparrow',
'Patriot', 'Quad', 'Coastguard', 'Dinghy', 'Hermes', 'Sabre', 'Rustler', 'ZR-350', 'Walton', 'Regina', 'Comet', 'BMX', 'Burrito', 'Camper', 'Marquis', 'Baggage',
'Dozer', 'Maverick', 'NewsChopper', 'Rancher', 'FBIRancher', 'Virgo', 'Greenwood', 'Jetmax', 'Hotring', 'Sandking', 'BlistaCompact', 'PoliceMaverick',
'Boxvillde', 'Benson', 'Mesa', 'RCGoblin', 'HotringRacerA', 'HotringRacerB', 'BloodringBanger', 'Rancher', 'SuperGT', 'Elegant', 'Journey', 'Bike',
'MountainBike', 'Beagle', 'Cropduster', 'Stunt', 'Tanker', 'Roadtrain', 'Nebula', 'Majestic', 'Buccaneer', 'Shamal', 'hydra', 'FCR-900', 'NRG-500', 'HPV1000',
'CementTruck', 'TowTruck', 'Fortune', 'Cadrona', 'FBITruck', 'Willard', 'Forklift', 'Tractor', 'Combine', 'Feltzer', 'Remington', 'Slamvan', 'Blade', 'Freight',
'Streak', 'Vortex', 'Vincent', 'Bullet', 'Clover', 'Sadler', 'Firetruck', 'Hustler', 'Intruder', 'Primo', 'Cargobob', 'Tampa', 'Sunrise', 'Merit', 'Utility', 'Nevada',
'Yosemite', 'Windsor', 'Monster', 'Monster', 'Uranus', 'Jester', 'Sultan', 'Stratum', 'Elegy', 'Raindance', 'RCTiger', 'Flash', 'Tahoma', 'Savanna', 'Bandito',
'FreightFlat', 'StreakCarriage', 'Kart', 'Mower', 'Dune', 'Sweeper', 'Broadway', 'Tornado', 'AT-400', 'DFT-30', 'Huntley', 'Stafford', 'BF-400', 'NewsVan',
'Tug', 'Trailer', 'Emperor', 'Wayfarer', 'Euros', 'Hotdog', 'Club', 'FreightBox', 'Trailer', 'Andromada', 'Dodo', 'RCCam', 'Launch', 'PoliceCar', 'PoliceCar',
'PoliceCar', 'PoliceRanger', 'Picador', 'S.W.A.T', 'Alpha', 'Phoenix', 'GlendaleShit', 'SadlerShit', 'Luggage A', 'Luggage B', 'Stairs', 'Boxville', 'Tiller',
'UtilityTrailer' }

local data = {
	functions = {
		checkbox = {},
		radius = imgui.ImInt(15)
	},
	imgui = {
		hudpos = false,
    	watchpos = false,
		hudpoint = { x = 0, y = 0 }
	},
	lecture = {
    	string = '',
    	list = {},
    	text = {},
		status = 0,
    	time = imgui.ImInt(5000)
	},
	combo = {
		dialog = imgui.ImInt(0),
		post = imgui.ImInt(0),
    	lecture = imgui.ImInt(0)
	},
	shpora = {
    	edit = -1,
    	loaded = 0,
    	page = 0,
    	select = {},
    	inputbuffer = imgui.ImBuffer(10000),
    	search = imgui.ImBuffer(256),
		filename = '',
   		text = ''
	},
	players = {},
	members = {},
	show = 6
}

local membersInfo = {
	online = 0,
	work = 0,
	nowork = 0,
	mode = 0,
	imgui = imgui.ImBuffer(256),
	players = {}
}

local window = {
	['main'] = { bool = imgui.ImBool(false), cursor = true },
	['shpora'] = { bool = imgui.ImBool(false), cursor = true },
	['binder'] = { bool = imgui.ImBool(false), cursor = false },
	['members'] = { bool = imgui.ImBool(false), cursor = true, draw = true },
	['target'] = { bool = imgui.ImBool(false), cursor = false, draw = true },
	['hud'] = { bool = imgui.ImBool(false), cursor = false, draw = true },
	['smslog'] = { bool = imgui.ImBool(false), cursor = true },
	['departmentlog'] = { bool = imgui.ImBool(false), cursor = true },
	['menuscript'] = { bool = imgui.ImBool(false),cursor = true},
	['fastmenu'] = { bool = imgui.ImBool(false),cursor = true},
	['fastmenuedit'] = { bool = imgui.ImBool(false),cursor = true}
}

local binders = {
	bind = {
		text = imgui.ImBuffer(20480),
		name = imgui.ImBuffer(256),
		pause = imgui.ImInt(8),
		select = nil
	},
	cmd = {
		text = imgui.ImBuffer(20480),
		buffer = imgui.ImBuffer(256),
		params = imgui.ImInt(0),
		pause = imgui.ImInt(8),
		select = nil
	},
	fast = {
		name_menu = imgui.ImBuffer(256),
		items = {},
		text = imgui.ImBuffer(20480),
		name = imgui.ImBuffer(256),
		pause = imgui.ImInt(8),
		select = nil,
		select_item = nil
	}
}

local punkeyActive = 0
local punkey = {
	{ nick = nil, time = nil, reason = nil },
	{ nick = nil, time = nil, rank = nil },
	{ text = nil, time = nil, active = false },
	{ text = nil, active = false },
	{ text = nil, time = nil }
}

local bufferKeys = {}
local searchsmslog = imgui.ImBuffer(256)
local tablesmslog = {}
local sloglist = 1
local smsButtonsVisible = true
local searchdepartmentlog = imgui.ImBuffer(256)
local tabledepartmentlog = {}
local dloglist = 1
local departmentButtonsVisible = true
local selectWarehouse = -1
local startpst = false
local kvCoord = { x = nil, y = nil, ny = '', nx = '' }
local monikQuant = {}
local monikQuantNum = {}
local targetID = -1
local autoBP = 1
local inputFont = renderCreateFont('Segoe UI', 11, 13)

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then error(script_name .. ' needs SA:MP and SAMPFUNCS!') end
    while not isSampAvailable() do wait(100) end
	----------------------------------------------------------------------
	local directoryes = { 'Army-Tools', 'Army-Tools/lectures', 'Army-Tools/shpores' }
	for key, value in pairs(directoryes) do
		if not doesDirectoryExist('moonloader/'..value) then 
			createDirectory('moonloader/'..value) 
		end
	end
	----------------------------------------------------------------------
	if doesFileExist(paths.config) then
		local file = io.open(paths.config, 'r')
		config = decodeJson(file:read('*a'))
	end
	saveData(config, paths.config)
	----------------------------------------------------------------------
	if doesFileExist('moonloader/Army-Tools/configKeys.json') then
		local file = io.open('moonloader/Army-Tools/configKeys.json', 'r')
		configKeys = decodeJson(file:read('*a'))
	end
	saveData(configKeys, 'moonloader/Army-Tools/configKeys.json')
	----------------------------------------------------------------------
	if doesFileExist('moonloader/Army-Tools/configPosts.json') then
		local file = io.open('moonloader/Army-Tools/configPosts.json', 'r')
		configPosts = decodeJson(file:read('*a'))
	end
	saveData(configPosts, 'moonloader/Army-Tools/configPosts.json')
	----------------------------------------------------------------------
	if doesFileExist('moonloader/Army-Tools/configCommandBinder.json') then
		local file = io.open('moonloader/Army-Tools/configCommandBinder.json', 'r')
		configCommandBinder = decodeJson(file:read('*a'))
	end
	saveData(configCommandBinder, 'moonloader/Army-Tools/configCommandBinder.json')
	----------------------------------------------------------------------
	if doesFileExist('moonloader/Army-Tools/configButtonBinder.json') then
		local file = io.open('moonloader/Army-Tools/configButtonBinder.json', 'r')
		configButtonBinder = decodeJson(file:read('*a'))
	end
	saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
	----------------------------------------------------------------------
	if doesFileExist(paths['fastmenu']) then
		local file = io.open(paths['fastmenu'], 'r')
		configFastMenu = decodeJson(file:read('*a'))
	end
	saveData(configFastMenu, paths['fastmenu'])
	----------------------------------------------------------------------
	punacceptbind = rkeys.registerHotKey(configKeys.punaccept.v, true, punaccept)
	menuscriptbind = rkeys.registerHotKey(configKeys.menuscript.v,true,menuscript)
	fastmenubind = rkeys.registerHotKey(configKeys.fastmenu.v,true,actfast)
	----------------------------------------------------------------------
	for k, v in pairs(configButtonBinder) do
		rkeys.registerHotKey(v.v, true, onHotKey)
		if v.time ~= nil then 
			v.time = nil 
		end
		if v.name == nil then 
			v.name = '����'..k 
		end
		v.text = v.text:gsub('%[enter%]', ''):gsub('{noenter}', '{noe}')
	end
	saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
	----------------------------------------------------------------------
	stext('������ ������� ��������! ������� ���� ������� - /arm')
	----------------------------------------------------------------------
	if sampIsChatCommandDefined('r') then sampUnregisterChatCommand('r') end
	if sampIsChatCommandDefined('f') then sampUnregisterChatCommand('f') end
	if sampIsChatCommandDefined('dlog') then sampUnregisterChatCommand('dlog') end
	sampRegisterChatCommand('shpora', function() window['shpora'].bool.v = not window['shpora'].bool.v end)
	sampRegisterChatCommand('arm', function() window['main'].bool.v = not window['main'].bool.v end)
	sampRegisterChatCommand('slog', function() window['smslog'].bool.v = not window['smslog'].bool.v end)
	sampRegisterChatCommand('dlog', function() window['departmentlog'].bool.v = not window['departmentlog'].bool.v end)
	sampRegisterChatCommand('shud', function()
      	window['hud'].bool.v = not window['hud'].bool.v
      	config.options.hud = not config.options.hud
      	atext(('��� %s'):format(config.options.hud and '�������' or '��������'))      
    end)
	sampRegisterChatCommand('starget', function()
		config.options.target = not config.options.target
		atext(('Target Bar %s'):format(config.options.target and '�������' or '��������'))
	end)
	sampRegisterChatCommand('reconnect', cmd_reconnect)
	sampRegisterChatCommand('cchat', cmd_cchat)
	sampRegisterChatCommand('contract', cmd_contract)
	sampRegisterChatCommand('armupd', cmd_armytoolsupdates)
	sampRegisterChatCommand('cn', cmd_cn)
	sampRegisterChatCommand('setkv', cmd_setkv)
    sampRegisterChatCommand('stime', cmd_stime)
    sampRegisterChatCommand('sweather', cmd_sweather)
    sampRegisterChatCommand('ev', cmd_ev)
    sampRegisterChatCommand('blag', cmd_blag)
	sampRegisterChatCommand('r', cmd_r)
	sampRegisterChatCommand('f', cmd_f)
	sampRegisterChatCommand('members', cmd_members)
	sampRegisterChatCommand('mon', cmd_mon)
	sampRegisterChatCommand('checkbl', cmd_checkbl)
	sampRegisterChatCommand('createpost', cmd_createpost)
	sampRegisterChatCommand('loc', cmd_loc)
	sampRegisterChatCommand('vig', cmd_vig)
	sampRegisterChatCommand('nar', cmd_naryad)

	----------------------------------------------------------------------
	while not sampIsLocalPlayerSpawned() do wait(0) end
	----------------------------------------------------------------------
	tempConfig.myId = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	tempConfig.myNick = sampGetPlayerNickname(tempConfig.myId)
	tempConfig.updateAFK = os.time()
	tempConfig.authTime = os.date('%d.%m.%y %H:%M:%S') 
	----------------------------------------------------------------------
	registerCommandsBinder()
	applyCustomStyle()
	secoundTimer()
	updateScript()
	cmd_stats('checkout')
	----------------------------------------------------------------------
	local day = os.date('%d.%m.%y')
    if config.info.thisWeek == 0 then config.info.thisWeek = os.date('%W') end
    if config.info.day ~= day and tonumber(os.date('%H')) > 4 and config.info.dayOnline > 0 then
		local weeknum = dateToWeekNumber(config.info.day)
		if weeknum == 0 then weeknum = 7 end
		config.weeks[weeknum] = config.info.dayOnline
		atext(string.format('������� ����� ����. ����� ����������� ��� (%s): %s', config.info.day, secToTime(config.info.dayOnline)))
		if tonumber(config.info.thisWeek) ~= tonumber(os.date('%W')) then
			atext('�������� ����� ������. ����� ���������� ������: '..secToTime(config.info.weekOnline))
			config.info.weekOnline = 0
			config.info.weekPM = 0
			config.info.weekWorkOnline = 0
			for i = 1, #config.weeks do config.weeks[i] = 0 end
			for i = 1, #config.counter do config.counter[i] = 0 end
			config.info.thisWeek = os.date('%W')
		end
		config.info.day = day
		config.info.dayPM = 0
		config.info.dayAFK = 0
		config.info.dayOnline = 0
		config.info.dayWorkOnline = 0
		saveData(config, paths.config)
    end
	----------------------------------------------------------------------
	if config.options.hud == true then window['hud'].bool.v = true end
	----------------------------------------------------------------------
	while true do wait(0)
		if sampIsChatInputActive() == true and config.options.inputhelper == true then
			local function getStrByState(keyState)
				if keyState == 0 then
					return '{ff8533}OFF{ffffff}'
				end
				return '{85cf17}ON{ffffff}'
			end  
			local function getStrByPing(ping)
				if ping < 100 then
					return string.format('{85cf17}%d{ffffff}', ping)
				elseif ping < 150 then
					return string.format('{ff8533}%d{ffffff}', ping)
				end
				return string.format('{BF0000}%d{ffffff}', ping)
			end
			local in1 = sampGetInputInfoPtr()
			in1 = getStructElement(in1, 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			local fib = in3 + 40
			local fib2 = in2 + 5
			local _, pID = sampGetPlayerIdByCharHandle(playerPed)
			local name = sampGetPlayerNickname(pID)
			local ping = sampGetPlayerPing(pID)
			local score = sampGetPlayerScore(pID)
			local color = sampGetPlayerColor(pID)
			local capsState = ffi.C.GetKeyState(20)
			local numState = ffi.C.GetKeyState(144)
			local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
			local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, inputInfo, BuffSize)
			local localName = ffi.string(inputInfo)
			local text = string.format(
			'| {bde0ff}%s {ffffff}| {%0.6x}%s[%d] {ffffff}| LvL: {ff8533}%d {ffffff}| Ping: %s | Num: %s | Caps: %s | {ffeeaa}%s{ffffff}',
			os.date('%H:%M:%S'), bit.band(color,0xffffff), tempConfig.myNick, pID, score, getStrByPing(ping), getStrByState(numState), getStrByState(capsState), localName
			)
			renderFontDrawText(inputFont, text, fib2, fib, -1)
		end
		local result, target = getCharPlayerIsTargeting(playerHandle)
		if result then result, player = sampGetPlayerIdByCharHandle(target) end
		targetID = player
		if result and isKeyJustPressed(vkeys.VK_MENU) and targetMenu.playerid ~= player then
		  	targetPlayer(player)
		end
		tempConfig.armour = getCharArmour(PLAYER_PED)
      	tempConfig.health = getCharHealth(PLAYER_PED)
		local cx, cy, cz = getCharCoordinates(PLAYER_PED)
        local zcode = getNameOfZone(cx, cy, cz)    	
      	playerZone = getZones(zcode)
		if data.imgui.hudpos then
			window['hud'].bool.v = true
			sampToggleCursor(true)
			local curX, curY = getCursorPos()
			config.options.hudX = curX
			config.options.hudY = curY
		end
		if isKeyJustPressed(vkeys.VK_LBUTTON) and data.imgui.hudpos then
			data.imgui.hudpos = false
			sampToggleCursor(false)
			window['main'].bool.v = true
			saveData(config, paths.config)
		end
		tempConfig.mySkin = getCharModel(PLAYER_PED)
		if tempConfig.mySkin == 287 or tempConfig.mySkin == 191 or tempConfig.mySkin == 179 or tempConfig.mySkin == 61 or tempConfig.mySkin == 255 or tempConfig.mySkin == 73 then
			tempConfig.workingDay = true
		else tempConfig.workingDay = false end
		local ImguiWindowSettings = { false, false }
		for k, settings in pairs(window) do
			if settings.bool.v and ImguiWindowSettings[1] == false then
				imgui.Process = true
				ImguiWindowSettings[1] = true
			end
			if settings.bool.v and settings.cursor and ImguiWindowSettings[2] == false then
				imgui.ShowCursor = true
				ImguiWindowSettings[2] = true
			end
		end
		if ImguiWindowSettings[1] == false then
			imgui.Process = false
		end
		if ImguiWindowSettings[2] == false then
			imgui.ShowCursor = false
		end
		if (window['main'].bool.v and (data.show == 4 or data.show == 5)) or window['fastmenuedit'].bool.v then
			window['binder'].bool.v = true
		else window['binder'].bool.v = false end 
    	if isKeyJustPressed(VK_T) and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then sampSetChatInputEnabled(true) end
		if isCharInAnyCar(PLAYER_PED) then tempConfig.VehicleId = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(PLAYER_PED))) end
		local valid, ped = getCharPlayerIsTargeting(playerHandle)
        if valid and doesCharExist(ped) then
            local result, id = sampGetPlayerIdByCharHandle(ped)
            targetid = id
        end
  	end
end

function imgui.OnDrawFrame()
	if imgui.BeginPopupModal(u8'�������� �����', nil, imgui.WindowFlags.AlwaysAutoResize) then
		imgui.ShowCursor = true
		imgui.Text(u8'�������� �����, ���� ������ ������ ���������:')
		imgui.Combo('##combodialog', data.combo.dialog, u8'�� �������\0����� ��\0���� ��\0\0')
		imgui.Spacing()
		if imgui.Button(u8'�������', imgui.ImVec2(120, 30)) then
			if data.combo.dialog.v > 0 then
				punkey[4].active = true
				warehouseDialog = data.combo.dialog.v
				if warehouseDialog == 1 then cmd_r(localVars('autopost', 'start_boat', { ['id'] = tempConfig.myId }))
				elseif warehouseDialog == 2 then cmd_r(localVars('autopost', 'start_boat_lsa', { ['id'] = tempConfig.myId })) end
				stext('����� ��� �������� ���������. ����� �������� ����� ������ ������ ������ � �����')
				dialogCursor = false
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8'�������', imgui.ImVec2(120, 30)) then
		  dialogCursor = false
		  imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	if openPopup ~= nil then
		dialogCursor = true
		imgui.OpenPopup(openPopup)
		openPopup = nil
	end
	if window['main'].bool.v then
		imgui.SetNextWindowSize(imgui.ImVec2(700, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8(thisScript().name..' | ������� ���� | Version: '..thisScript().version), window['main'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar + imgui.WindowFlags.NoResize)
		if imgui.BeginMenuBar() then
			if imgui.BeginMenu(u8('��������')) then
				if imgui.MenuItem(u8('������� ����')) then
					data.show = 6
				elseif imgui.MenuItem(u8('������ ��������')) then
					data.show = 8
				elseif imgui.MenuItem(u8('���������')) then
					data.show = 1
				elseif imgui.MenuItem(u8('����-��')) then
					data.show = 11
				elseif imgui.MenuItem(u8('���������� ����')) then
					data.show = 9
					clearparams()
				end
				imgui.EndMenu()
			end
			if imgui.MenuItem(u8('������')) then
				data.show = 2
			end
			if imgui.MenuItem(u8'Fast Menu') then window['fastmenuedit'].bool.v = true end
			if imgui.BeginMenu(u8('��������')) then
				if imgui.MenuItem(u8('�����')) then 
					window['shpora'].bool.v = not window['shpora'].bool.v
				elseif imgui.MenuItem(u8('������')) then
					data.show = 4
				elseif imgui.MenuItem(u8('�����������')) then
					data.show = 10
					clearparams()
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('����������')) then
				if imgui.MenuItem(u8('������')) then					
					data.show = 3
				elseif imgui.MenuItem(u8('�������')) then				
					data.show = 7
				end
				imgui.EndMenu()
			end
			if imgui.BeginMenu(u8('���������')) then
				if imgui.MenuItem(u8('������������� ������')) then
					lua_thread.create(function()
						stext('���������������...')
						window['main'].bool.v = not window['main'].bool.v
						wait(1000)
						thisScript():reload()
					end)
				end
				if imgui.MenuItem(u8('��������� ������')) then
					lua_thread.create(function()
						stext('�������� ������...')
						window['main'].bool.v = not window['main'].bool.v
						wait(1000)
						stext('������ ������� ��������!')
						thisScript():unload()
					end)
				end
				imgui.EndMenu()
			end
			imgui.EndMenuBar()
		end
		if data.show == 1 then
			local autologin = imgui.ImBool(config.options.autologin)
			local passbuffer = imgui.ImBuffer(tostring(u8:encode(config.options.password)), 256)
			local membersdate = imgui.ImBool(config.options.membersdate)
			local doklad = imgui.ImBool(config.options.autodoklad)
			local tagbool = imgui.ImBool(config.options.tagbool)
			local tagbuffer = imgui.ImBuffer(u8(config.options.tag), 256)
			local clistbool = imgui.ImBool(config.options.clistbool)
			local clistbuffer = imgui.ImInt(config.options.clist)
			local pg = imgui.ImBool(config.options.pg)
			local modradiobool = imgui.ImBool(config.options.modradiobool)
			local hud = imgui.ImBool(config.options.hud)
			local target = imgui.ImBool(config.options.target)
			local inputhelper = imgui.ImBool(config.options.inputhelper)
			local showquitplayer = imgui.ImBool(config.options.showquit)
			local modificatemembers = imgui.ImBool(config.options.modmembers)
			if imgui.BeginChild('##1', imgui.ImVec2(320, 60)) then
				if imgui.ToggleButton(u8('������������ ����-���'), tagbool) then 
					config.options.tagbool = not config.options.tagbool 
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('������������ ����-���'))
				if tagbool.v == true then
					if imgui.InputText(u8('������� ���� ���'), tagbuffer) then 
						config.options.tag = u8:decode(tagbuffer.v) 
						saveData(config, paths.config)
					end
				end
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##2', imgui.ImVec2(320, 60)) then
				if imgui.ToggleButton(u8('������������ ����-�����'), clistbool) then 
					config.options.clistbool = not config.options.clistbool
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('������������ ����-�����')); imgui.SameLine(); imgui.TextQuestion(u8('� ������� �� ���������'))
				if clistbool.v == true then
					imgui.PushItemWidth(195)
					if imgui.SliderInt(u8('�������� ��������'), clistbuffer, 0, 33) then 
						config.options.clist = clistbuffer.v
						saveData(config, paths.config)
					end
				end
				imgui.EndChild()
			end
			if imgui.BeginChild('##3', imgui.ImVec2(320, 190)) then
				if imgui.ToggleButton(u8('pg'), pg) then 
					config.options.pg = not config.options.pg
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('��������� ������ �������')); imgui.SameLine(); imgui.TextQuestion(u8('�������������� ��������� � ��� ��� ������ �������/�����, ��������� ��� ������� � ����'))
				if imgui.ToggleButton(u8('modradiobool'), modradiobool) then
					config.options.modradiobool = not config.options.modradiobool
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('���������������� �����')); imgui.SameLine(); imgui.TextQuestion(u8('������� �������� � ����� � ���� �������� ������ ������'))
				if imgui.ToggleButton(u8 'membersdate##1', membersdate) then
					config.options.membersdate = membersdate.v
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '�������� ���� �������� � /members 1'); imgui.SameLine(); imgui.TextQuestion(u8('���������� ���� �������� ���� �������� ������ �� �������'))
				if imgui.ToggleButton(u8 'modmemb##1', modificatemembers) then
					config.options.modmembers = modificatemembers.v;
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '���������������� /members'); imgui.SameLine(); imgui.TextQuestion(u8('���������� ���������������� ������� � ��� �����, ��� ������������� ����� /members 1'))
				if imgui.ToggleButton(u8 'autologin##1', autologin) then
					config.options.autologin = autologin.v;
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '��������� � ����')
				if config.options.autologin then
					imgui.Spacing()
					imgui.Text(u8'������� ������ ��� ����������')
					if imgui.InputText('##pass', passbuffer, imgui.InputTextFlags.Password) then
					  	config.options.password = u8:decode(passbuffer.v)
					end   
				end
				if imgui.HotKey('##menuscript', configKeys.menuscript, bufferKeys, 50) then
					rkeys.changeHotKey(menuscriptbind, configKeys.menuscript.v)
					stext('������� ������� ��������!')
					saveData(configKeys, 'moonloader/Army-Tools/configKeys.json')
				end; imgui.SameLine(); imgui.Text(u8('������� ��������� ����')); imgui.SameLine(); imgui.TextQuestion(u8('������������ ��� ��������� ���� ������� �� ������'))
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##4', imgui.ImVec2(320, 190)) then
				if imgui.ToggleButton(u8 'hud##1', hud) then
					config.options.hud = hud.v
					window['hud'].bool.v = hud.v
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '�������� ���'); imgui.SameLine(); imgui.TextQuestion(u8('�������� ������ ��� ������, ������� ���������� ��������� ��� ��� ���� ����������'))
				if imgui.ToggleButton(u8 'doklad##1', doklad) then
					config.options.autodoklad = doklad.v
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '�������� ����-������� � ��������'); imgui.SameLine(); imgui.TextQuestion(u8('��� ������� ������� �������������, ������������� �������� � ��� ������ � ���� ��� ����� ����� ��������'))
				if imgui.ToggleButton(u8 'target##1', target) then
					config.options.target = target.v;
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '�������� Target Bar'); imgui.SameLine(); imgui.TextQuestion(u8('�������� ������-���, ������� ���������� ���������� ��� ����, � ���� �� ��������'))
				if imgui.ToggleButton(u8 'inputhelper##1', inputhelper) then
					config.options.inputhelper = inputhelper.v;
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '���������� ���� �������� �������'); imgui.SameLine(); imgui.TextQuestion(u8('���������� ���� �������, ������� ���������� � ���� ������ � ����� �� ����'))
				if imgui.ToggleButton(u8 'quitshow##1', showquitplayer) then
					config.options.showquit = showquitplayer.v;
					saveData(config, paths.config)
				end
				imgui.SameLine(); imgui.Text(u8 '�������� InputHelper ��� ������� �����'); imgui.SameLine(); imgui.TextQuestion(u8('������: teekyuu, DarkP1xel'));
				if imgui.HotKey('##punaccept', configKeys.punaccept, bufferKeys, 50) then
					rkeys.changeHotKey(punacceptbind, configKeys.punaccept.v)
					stext('������� ������� ��������!')
					saveData(configKeys, 'moonloader/Army-Tools/configKeys.json')
				end; imgui.SameLine(); imgui.Text(u8('������� �������������')); imgui.SameLine(); imgui.TextQuestion(u8('������������ ��� ����-��������, � ��������� ��������� ��������� ������������� �� ������'))
				imgui.EndChild()
			end
		elseif data.show == 2 then
			imgui.PushItemWidth(150)
			if data.lecture.string == '' then
				data.combo.lecture.v = 0
				data.lecture.list = {}
				data.lecture.string = u8('�� �������\0')
				for file in lfs.dir(getWorkingDirectory()..'\\Army-Tools\\lectures') do
					if file ~= '.' and file ~= '..' then
						local attr = lfs.attributes(getWorkingDirectory()..'\\Army-Tools\\lectures\\'..file)
						if attr.mode == 'file' then 
							table.insert(data.lecture.list, file)
							data.lecture.string = data.lecture.string..u8:encode(file)..'\0'
						end
					end
				end
				data.lecture.string = data.lecture.string..'\0'
			end
			imgui.Columns(2, _, false)
			imgui.SetColumnWidth(-1, 200)
			imgui.Text(u8('�������� ���� ������'))
			imgui.Combo('##lec', data.combo.lecture, data.lecture.string)
			if imgui.Button(u8('��������� ������')) then
				if data.combo.lecture.v > 0 then
					local file = io.open('moonloader/Army-Tools/lectures/'..data.lecture.list[data.combo.lecture.v], 'r+')
					if file == nil then 
						atext('���� �� ������!')
					else
						data.lecture.text = {} 
						for line in io.lines('moonloader/Army-Tools/lectures/'..data.lecture.list[data.combo.lecture.v]) do
							table.insert(data.lecture.text, line)
						end
						if #data.lecture.text > 0 then
							atext('���� ������ ������� ��������!')
						else 
							atext('���� ������ ����!') 
						end
					end
					file:close()
					file = nil
				else 
					atext('�������� ���� ������!') 
				end
			end
			imgui.NextColumn()
			imgui.PushItemWidth(200)
			imgui.Text(u8('�������� �������� (� �������������)'))
			imgui.InputInt('##inputlec', data.lecture.time)
			if data.lecture.status == 0 then
				if imgui.Button(u8('��������� ������')) then
					if #data.lecture.text == 0 then 
						stext('���� ������ �� ��������!') 
						return 
					end
					if data.lecture.time.v == 0 then 
						stext('����� �� ����� ���� ����� 0!') 
						return 
					end
					if data.lecture.status ~= 0 then 
						stext('������ ��� ��������/�� �����.') 
						return 
					end
					local ltext = data.lecture.text
					local ltime = data.lecture.time.v
					atext('����� ������ �������.')
					data.lecture.status = 1
					lua_thread.create(function()
						while true do
							if data.lecture.status == 0 then 
								break 
							end
							if data.lecture.status >= 1 then
								sampSendChat(ltext[data.lecture.status])
								data.lecture.status = data.lecture.status + 1
							end
							if data.lecture.status > #ltext then
								wait(150)
								data.lecture.status = 0
								addcounter(4, 1)
								stext('����� ������ ��������.')
								break 
							end
							wait(tonumber(ltime))
						end
					end)
				end
			else
				if imgui.Button(u8:encode(string.format('%s', data.lecture.status > 0 and '�����' or '�����������'))) then
					if data.lecture.status == 0 then 
						stext('������ �� ��������.') 
						return 
					end
					data.lecture.status = data.lecture.status * -1
					if data.lecture.status > 0 then 
						stext('������ ������������.')
					else 
						stext('������ ��������������.') 
					end
				end
				imgui.SameLine()
				if imgui.Button(u8('����')) then
					if data.lecture.status == 0 then 
						stext('������ �� ��������.') 
						return 
					end
					data.lecture.status = 0
					stext('����� ������ ���������.')
				end
			end
			imgui.NextColumn()
			imgui.Columns(1)
			imgui.Separator()
			imgui.Text(u8('���������� ����� ������:'))
			imgui.Spacing()
			if #data.lecture.text == 0 then 
				imgui.Text(u8('���� �� ��������/����!')) 
			end
			for i = 1, #data.lecture.text do
				imgui.Text(u8:encode(data.lecture.text[i]))
			end
		elseif data.show == 3 then
			imgui.NewLine()
			imgui.NewLine()
			imgui.CentrText('Script Version: '..thisScript().version)
			imgui.NewLine()
			imgui.CentrText(u8('�����������: Henrich Rogge & Arthur Nicho'))
			imgui.CentrText(u8('������: Laurance Rockefeller & Erik Mann'))
			imgui.CentrText(u8('�����: Henrich Rogge & Laurance Rockefeller'))
			imgui.CentrText(u8('����: Laurance Rockefeller'))
			imgui.NewLine()
			imgui.CentrText(u8('������� ����� ������� ����� �� ������� SFA-Helper � ��������������� ��� ����������� ������'))
			imgui.CentrText(u8('����������� SFA-Helper - Edward Franklin a.k.a Illia Illiashenko'))
		elseif data.show == 4 then
			if imgui.BeginChild('##commandlist', imgui.ImVec2(170, 290)) then
				for k, v in pairs(configCommandBinder) do
					if imgui.Selectable(u8(('/%s##%s'):format(v.cmd, k)), binders.cmd.select == k) then 
						binders.cmd.select = k 
						binders.cmd.buffer.v = u8(v.cmd) 
						binders.cmd.params.v = v.params
						binders.cmd.text.v = u8(v.text)
						binders.cmd.pause.v = v.pause
					end
				end
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##configCommandBindersetting', imgui.ImVec2(500, 290)) then
				for k, v in pairs(configCommandBinder) do
					if binders.cmd.select == k then
						if imgui.BeginChild('##������', imgui.ImVec2(110, 50)) then
							imgui.PushItemWidth(105)
							imgui.Text(u8('������� �������:'))
							imgui.InputText(u8('##������� �������'), binders.cmd.buffer)
						 	imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##casd', imgui.ImVec2(170, 50)) then
							imgui.PushItemWidth(165)
							imgui.Text(u8('������� ���-�� ����������:'))
							imgui.InputInt(u8('##����� ���-�� ����������'), binders.cmd.params, 0)
							imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##��������', imgui.ImVec2(170, 50)) then
							imgui.PushItemWidth(165)
							imgui.Text(u8('�������� ����� ����� (��):'))
							imgui.InputInt(u8('�������� ����� ����� (��):'), binders.cmd.pause, 0)
							imgui.EndChild()
						end
						imgui.Text(u8('������� ����� �������:'))
						imgui.InputTextMultiline(u8('##cmdtext'), binders.cmd.text, imgui.ImVec2(470, 175))
						if imgui.Button(u8('��������� �������'), imgui.ImVec2(130, 25)) then
							sampUnregisterChatCommand(v.cmd)
							v.cmd = u8:decode(binders.cmd.buffer.v)
							v.params = binders.cmd.params.v
							v.text = u8:decode(binders.cmd.text.v)
							v.pause = binders.cmd.pause.v
							saveData(configCommandBinder, 'moonloader/Army-Tools/configCommandBinder.json')
							registerCommandsBinder()
							stext('������� ������� ���������!')
						end
						imgui.SameLine()
						if imgui.Button(u8('������� �������##')..k, imgui.ImVec2(130, 25)) then
							sampUnregisterChatCommand(v.cmd)
							binders.cmd.select = nil
							binders.cmd.buffer.v = ''
							binders.cmd.params.v = 0
							binders.cmd.text.v = ''
							table.remove(configCommandBinder, k)
							saveData(configCommandBinder, 'moonloader/Army-Tools/configCommandBinder.json')
							registerCommandsBinder()
							stext('������� ������� �������!')
						end
					end
				end
				imgui.EndChild()
			end
			if imgui.Button(u8('�������� �������'), imgui.ImVec2(170, 25)) then
				table.insert(configCommandBinder, {cmd = '', params = 0, text = '',pause=1000})
				saveData(configCommandBinder, 'moonloader/Army-Tools/configCommandBinder.json')
			end
			imgui.SameLine(564)
			if imgui.Button(u8('��������� ������')) then
				data.show = 5
			end
		elseif data.show == 5 then
			imgui.BeginChild('##bindlist', imgui.ImVec2(170, 290))
			for k, v in ipairs(configButtonBinder) do
				if imgui.Selectable(u8('')..u8:encode(v.name)) then 
					binders.bind.select = k
					binders.bind.name.v = u8(v.name) 
					binders.bind.text.v = u8(v.text)
					binders.bind.pause.v = v.pause
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			if imgui.BeginChild('##editbind', imgui.ImVec2(500, 290)) then
				for k, v in ipairs(configButtonBinder) do 
					if binders.bind.select == k then
						if imgui.BeginChild('##cmbdas', imgui.ImVec2(155, 50)) then
							imgui.PushItemWidth(150)
							imgui.Text(u8('������� �������� �����:'))
							imgui.InputText('##������� �������� �����', binders.bind.name)
							imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##3123454', imgui.ImVec2(125, 50)) then
							imgui.Text(u8('�������:'))
							if imgui.HotKey(u8('##HK').. k, v, bufferKeys, 55) then
								if not rkeys.isHotKeyDefined(v.v) then
									if rkeys.isHotKeyDefined(bufferKeys.v) then
										rkeys.unRegisterHotKey(bufferKeys.v)
									end
									rkeys.registerHotKey(v.v, true, onHotKey)
								end
								saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
							end
							imgui.EndChild()
						end
						imgui.SameLine()
						if imgui.BeginChild('##�������', imgui.ImVec2(170, 50)) then
							imgui.PushItemWidth(165)
							imgui.Text(u8('�������� ����� ����� (��):'))
							imgui.InputInt(u8('###�������� ����� �����(��):'), binders.bind.pause, 0)
							imgui.EndChild()
						end
						imgui.Text(u8('������� ����� �����:'))
						imgui.InputTextMultiline('##������� ����� �����', binders.bind.text, imgui.ImVec2(470, 175))
						if imgui.Button(u8('��������� ����##')..k, imgui.ImVec2(110, 25)) then
							stext('���� ������� ��������!')
							v.name = u8:decode(binders.bind.name.v)
							v.text = u8:decode(binders.bind.text.v)
							v.pause = binders.bind.pause.v
							saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
						end
						imgui.SameLine()
						if imgui.Button(u8('������� ����##')..k, imgui.ImVec2(100, 25)) then
							stext('���� ������� ������!')
							table.remove(configButtonBinder, k)
							saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
						end
					end
				end
				imgui.EndChild()
			end
			if imgui.Button(u8('�������� �������'), imgui.ImVec2(170, 25)) then
				configButtonBinder[#configButtonBinder + 1] = {text = '', v = {}, time = 0, name = '����'..#configButtonBinder + 1, pause = 1000}
				saveData(configButtonBinder, 'moonloader/Army-Tools/configButtonBinder.json')
			end
			imgui.SameLine(564)
			if imgui.Button(u8('��������� ������')) then
				data.show = 4
			end
		elseif data.show == 6 then
			if imgui.BeginChild('##FirstWindow', imgui.ImVec2(669.1, 322), true, imgui.WindowFlags.VerticalScrollbar) then
				imgui.CentrText(u8('����������')) 
				imgui.Separator()
				imgui.Text(u8'���:'); imgui.SameLine(175.0); imgui.Text(('%s[%d]'):format(tempConfig.myNick, tempConfig.myId))
				imgui.Text(u8'������� ����:'); imgui.SameLine(175.0); imgui.TextColoredRGB(string.format('%s', tempConfig.workingDay == true and '{00bf80}�����' or '{ec3737}�������'))
				if tempConfig.workingDay == true and config.options.rank > 0 then
				  imgui.Text(u8'������:'); imgui.SameLine(175.0); imgui.Text(('%s[%d]'):format(u8:encode(config.ranknames[config.options.rank]), config.options.rank))
				end
				imgui.Text(u8'����� �����������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(tempConfig.authTime))
				imgui.Separator()
				imgui.Text(u8'�������� �� �������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(secToTime(config.info.dayOnline)))
				imgui.Text(u8'�� ��� �� ������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(secToTime(config.info.dayWorkOnline)))
				imgui.Text(u8'AFK �� �������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(secToTime(config.info.dayAFK)))
				imgui.Separator()
				imgui.Text(u8'�������� �� ������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(secToTime(config.info.weekOnline)))
				imgui.Text(u8'�� ��� �� ������:'); imgui.SameLine(175.0); imgui.Text(('%s'):format(secToTime(config.info.weekWorkOnline)))
				imgui.EndChild()
			end
		elseif data.show == 7 then
			imgui.BulletText(u8('/arm - ������� ���� �������.'))
			imgui.BulletText(u8('/shpora - ������� ���� � �������.'))
			imgui.BulletText(u8('/cn [id] [0 - RP nick, 1 - NonRP nick] - ����������� ��� � ������ ������.'))
			imgui.BulletText(u8('/armupd - ����������� ������ ����������.'))
			imgui.BulletText(u8('/r [Text] - ���� ��� � �����.'))
			imgui.BulletText(u8('/f [Text] - ���� ��� � �����.'))
			imgui.BulletText(u8('/ev [0-1] [�����] - ��������� ���������, 0 �������� � ������� �������, 1 ������ ������� ��� �� ��������� �����.'))
			imgui.BulletText(u8('/blag [��] [�������] [���] 1 - ������ �� �������, 2 - �� ������� �� ����������, 3 - �� ���������������.'))
			imgui.BulletText(u8('/reconnect [�������] - ����������� ��� �� ������.'))
			imgui.BulletText(u8('/cchat - ��������� ������� ��� ���.'))
			imgui.BulletText(u8('/sweather [������ 0-45] - ��������� ��� ��� �������� ������ � ����.'))
			imgui.BulletText(u8('/stime [����� 0-23 | -1 ����������] - ��������� ��� ��� �������� ����� � ����.'))
			imgui.BulletText(u8('/contract [id] [rank] - ��������� ������ �� ���������, ����� �� ������� ���.'))
			imgui.BulletText(u8('/members [0-2] ���: 1 - ������ ������� /members, 2 - ��������� ����.'))
			imgui.BulletText(u8('/setkv [�������] - ������ ����� �� ��������� ���� �������.'))
			imgui.BulletText(u8('/mon [0-1] ���: 0 - ��������� ���������� ��� � ���, 1 - ���������� LVA(���� �� � ������� SFA � ��������) � �����.'))
			imgui.BulletText(u8('/checkbl [id/nick] - ��������� ������ �� ���������� � ������ ������ (�������� ��� SFA)'))
			imgui.BulletText(u8('/createpost [������] [��������] - ������� ����� ����, � �������� ������� � ����, ���������� �� ������������ �������.'))
			imgui.BulletText(u8('/shud - ��������/��������� ���.'))
			imgui.BulletText(u8('/starget - ��������/��������� ������-���.'))
			imgui.BulletText(u8('/vig [id] [��� �������� (�������/�������)] [�������] - ������ ������� �����.'))
			imgui.BulletText(u8('/nar [id] [���-�� ������] [�������] - ������ ����� �����.'))
			imgui.BulletText(u8('/loc [id] [sec] - ��������� �������������� �����.'))
			imgui.BulletText(u8('/slog - ���������� ��� ��������� SMS ���������.'))
			imgui.BulletText(u8('/dlog - ���������� ��� ��������� ��������� � ����� ������������.'))
		elseif data.show == 8 then
			if imgui.BeginChild('##TwoWindow', imgui.ImVec2(327.5, 322), true, imgui.WindowFlags.VerticalScrollbar) then
				imgui.CentrText(u8('������ �� ������')) 
				imgui.Separator()
				local daynumber = dateToWeekNumber(os.date('%d.%m.%y'))
				if daynumber == 0 then daynumber = 7 end
				local mediumtime = {}
				for key, value in ipairs(config.weeks) do
					local colour = ''
					if daynumber > 0 then
						if daynumber < key then 
							colour = 'ec3737'
							table.insert(mediumtime, value)
						elseif daynumber == key then
							colour = 'FFFFFF'
							table.insert(mediumtime, config.info.dayOnline)
						else colour = '00BF80' end
					else
						if daynumber == 0 and key == 7 then colour = 'FFFFFF'
						else colour = '00BF80' end
					end
					imgui.Text(u8:encode(dayName[key]))
					imgui.SameLine(185.0)
					imgui.TextColoredRGB(('{%s}%s'):format(colour, daynumber == key and secToTime(config.info.dayOnline) or secToTime(value)))
				end
				local counter = 0
				for i = 1, #mediumtime do
				  counter = counter + mediumtime[i]
				end
				counter = math.floor(counter / #mediumtime)
				imgui.Spacing()
				imgui.Text(u8'������� ������ � ����')
				imgui.SameLine(185.0)
				imgui.Text(secToTime(counter))
				imgui.EndChild()
			end
			imgui.SameLine()
			if imgui.BeginChild('##ThirdWindow', imgui.ImVec2(330, 322), true, imgui.WindowFlags.VerticalScrollbar) then
				imgui.CentrText(u8('���������� �� ������'))
				imgui.Separator()
				for i = 1, #config.counter do
					if counterNames[i] ~= nil then
						local count = config.counter[i]
						if i == 5 or i == 6 then count = secToTime(count) end
						imgui.Text(('%s'):format(u8:encode(counterNames[i])))
						imgui.SameLine(225.0)
						imgui.Text(('%s'):format(count))
					end
				end
				imgui.EndChild()
			end
		elseif data.show == 9 then
			local menuText = { 'FPS', '������', '����������', '�������', '�����', '�����', '����', '�������', '��������, �����, �������', '������-����' }
			local menuTime = {{'������ �����',imgui.ImBool(config.options.timer[1])},
				{"������ ������������",imgui.ImBool(config.options.timer[2])},
				{"������ FFIX'a",imgui.ImBool(config.options.timer[3])}}
			local opacity = imgui.ImFloat(config.options.hudopacity)
			local rounding = imgui.ImFloat(config.options.hudrounding)
			imgui.Text(u8'������������ ����')
			if imgui.SliderFloat('##sliderfloat', opacity, 0.0, 1.0, '%.3f', 0.5) then
				config.options.hudopacity = opacity.v
			end
			imgui.Spacing()
			imgui.Text(u8'���������� ������ ����')
			if imgui.SliderFloat('##floatrounding', rounding, 0.0, 15.0, '%.2f', 0.5) then
				config.options.hudrounding = rounding.v
			end
			for i = 1, #config.options.hudset do
				if data.functions.checkbox[i] == nil then
					data.functions.checkbox[i] = imgui.ImBool(config.options.hudset[i])
				end
				imgui.Checkbox(u8:encode(menuText[i]), data.functions.checkbox[i])
				if data.functions.checkbox[i].v ~= config.options.hudset[i] then
					config.options.hudset[i] = data.functions.checkbox[i].v
					saveData(config, paths.config)
				end
			end
			for i = 1, #menuTime do
				imgui.Checkbox(u8:encode(menuTime[i][1]),menuTime[i][2])
				if menuTime[i][2].v ~= config.options.timer[i] then
					config.options.timer[i] = menuTime[i][2].v
					saveData(config, paths.config)
				end
			end
			imgui.Spacing()
			imgui.Separator()
			if imgui.Button(u8 '�������������� ����') then data.imgui.hudpos = true; window['main'].bool.v = false end
		elseif data.show == 10 then
			imgui.PushItemWidth(150)
			local togglepost = imgui.ImBool(post.active)
			local interval = imgui.ImInt(post.interval)
			if imgui.ToggleButton(u8 'post##1', togglepost) then
			  	post.active = togglepost.v;
			end
			imgui.SameLine(); imgui.Text(u8 '�������� ����������')
			imgui.Text(u8'�������� ����� ��������� (� ��������):')
			if imgui.InputInt('##inputint', interval) then
				if interval.v < 60 then interval.v = 60 end
				if interval.v > 3600 then interval.v = 3600 end
				post.interval = interval.v
			end
			imgui.Spacing()
			imgui.Separator()
			imgui.Spacing()
			imgui.Text(u8'�������� ���� ��� ���������:')
			local pstr = ''
			for i = 1, #configPosts do
			  	pstr = pstr..configPosts[i].name..'\0'
			end
			imgui.Combo('##combo', data.combo.post, u8:encode('�� �������\0'..pstr..'\0'))
			imgui.Spacing()
			if data.combo.post.v > 0 then
				imgui.Text(u8('���������� �����: %f, %f, %f'):format(configPosts[data.combo.post.v].coordX, configPosts[data.combo.post.v].coordY, configPosts[data.combo.post.v].coordZ))
				if imgui.Button(u8 '��������##1') then
					local cx, cy, cz = getCharCoordinates(PLAYER_PED)
					local radius = configPosts[data.combo.post.v].radius
					for i = 1, #configPosts do
					local pi = configPosts[i]
					if i ~= data.combo.post.v then
						if cx >= pi.coordX - (pi.radius+radius) and cx <= pi.coordX + (pi.radius+radius) and cy >= pi.coordY - (pi.radius+radius) and cy <= pi.coordY + (pi.radius+radius) and cz >= pi.coordZ - (pi.radius+radius) and cz <= pi.coordZ + (pi.radius+radius) then
							stext(('���������� �� ����� ���� ��������, �.�. ��� �������� � ������ \'%s\''):format(pi.name))
						return
						end
					end
				end
				stext('���������� ����� ������� ��������!')
				configPosts[data.combo.post.v].coordX = cx
				configPosts[data.combo.post.v].coordY = cy
				configPosts[data.combo.post.v].coordZ = cz
				saveData(configPosts, 'moonloader/Army-Tools/configPosts.json')
			end
			imgui.SameLine(); imgui.TextDisabled(u8'(���������� ��������� �� ����� �����������)');
			imgui.Text(u8('������ �����: %f'):format(configPosts[data.combo.post.v].radius))
			imgui.InputInt('##inputint2', data.functions.radius, 0)
			imgui.SameLine()
			if imgui.Button(u8 '��������##2') then
				if data.functions.radius.v ~= tonumber(configPosts[data.combo.post.v].radius) then
						stext('������ ����� ������� �������!')
						configPosts[data.combo.post.v].radius = data.functions.radius.v
						saveData(configPosts, 'moonloader/Army-Tools/configPosts.json')
					end
				end
				imgui.NewLine()
				if imgui.Button(u8 '������� ����', imgui.ImVec2(120, 30)) then
					table.remove(configPosts, data.combo.post.v)
					data.combo.post.v = 0
					stext('���� ������� ������!')
					saveData(configPosts, 'moonloader/Army-Tools/configPosts.json') 
			  	end
			end
		elseif data.show == 11 then
			local AutoBP = imgui.ImBool(config.options.useautobp)
			local abp_deagle = imgui.ImBool(config.autoBP.deagle)
			local abp_spec = imgui.ImBool(config.autoBP.spec)
			local abp_close = imgui.ImBool(config.autoBP.close)
			local abp_m4 = imgui.ImBool(config.autoBP.m4)
			local abp_shot = imgui.ImBool(config.autoBP.shot)
			local abp_armour = imgui.ImBool(config.autoBP.armour)
			local abp_rifle = imgui.ImBool(config.autoBP.rifle)
			local abp_smg = imgui.ImBool(config.autoBP.smg)

			if imgui.ToggleButton(u8('##10'), AutoBP) then 
				config.options.useautobp = not config.options.useautobp
				saveData(config, paths.config)
			end; imgui.SameLine(); imgui.Text(u8('�������� ����-��'))

			if config.options.useautobp then
				
				imgui.Separator()

				if imgui.ToggleButton(u8('##deagle'), abp_deagle) then 
					config.autoBP.deagle = not config.autoBP.deagle
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('Deagle'))

				if imgui.ToggleButton(u8('##shot'), abp_shot) then 
					config.autoBP.shot = not config.autoBP.shot
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('Shotgun'))

				if imgui.ToggleButton(u8('##smg'), abp_smg) then 
					config.autoBP.smg = not config.autoBP.smg
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('SMG'))

				if imgui.ToggleButton(u8('##m4'), abp_m4) then 
					config.autoBP.m4 = not config.autoBP.m4
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('M4'))

				if imgui.ToggleButton(u8('##rifle'), abp_rifle) then 
					config.autoBP.rifle = not config.autoBP.rifle
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('Rifle'))

				if imgui.ToggleButton(u8('##armour'), abp_armour) then 
					config.autoBP.armour = not config.autoBP.armour
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('Armour'))

				if imgui.ToggleButton(u8('##close'), abp_close) then 
					config.autoBP.close = not config.autoBP.close
					saveData(config, paths.config)
				end; imgui.SameLine(); imgui.Text(u8('������������� ������� ������'))

			end
		end
		imgui.End()
		if window['binder'].bool.v then
			imgui.SetNextWindowSize(imgui.ImVec2(200, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(x / 2.7, y / 1.2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin('##binder', window['binder'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if data.show == 4 then imgui.Text(u8('{location} - ���� ������� �������\n{targetid} - ID ���� � ���� �� ��������\n{targetrpnick} - ������ ������� ���� � ���� �� ��������\n{naparnik} - ��� ��������(�������� ���� � ����)\n{frac} - ���� �������\n{rank} - ��� ����\n{post} - ������� ���� �� ������� �� ����������\n{noe} - �������� ��������� � ���� �����\n{f6} - ��������� ��������� ����� ���\n{param:1} � �.� - ���������\n{myid} - ��� ID\n{myrpnick} - ��� �� ���\n{kv} - ��� ������� �������\n{vehid} - ��� ID ����\n{wait:sek} - �������� ����� ��������\n{screen} - ������� �������� ������\n{mytag} - ��� ���'))
			elseif data.show == 5 or window['fastmenuedit'].bool.v then imgui.Text(u8('{location} - ���� ������� �������\n{targetid} - ID ���� � ���� �� ��������\n{targetrpnick} - ������ ������� ���� � ���� �� ��������\n{naparnik} - ��� ��������(�������� ���� � ����)\n{frac} - ���� �������\n{rank} - ��� ����\n{post} - ������� ���� �� ������� �� ����������\n{noe} - �������� ��������� � ���� �����\n{f6} - ��������� ��������� ����� ���\n{myid} - ��� ID\n{myrpnick} - ��� �� ���\n{kv} - ��� ������� �������\n{vehid} - ��� ID ����\n{wait:sek} - �������� ����� ��������\n{screen} - ������� �������� ������\n{mytag} - ��� ���')) end
			imgui.End()
		end
	end
	if window['members'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 590), imgui.Cond.FirstUseEver)
		imgui.Begin(u8('Army-Tools | Members Bar'), window['members'].bool, imgui.WindowFlags.NoCollapse)
		if membersInfo.mode == 0 and #membersInfo.players > 0 then
			imgui.Text(u8:encode(('������ �������: %d | �� ������: %d | ��������: %d'):format(membersInfo.online, membersInfo.work, membersInfo.nowork)))
			imgui.InputText(u8 '����� �� ����/ID', membersInfo.imgui)
			imgui.Columns(6)
			imgui.Separator()
			imgui.SetColumnWidth(-1, 55); imgui.Text('ID'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 175); imgui.Text('Nickname'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 125); imgui.Text('Rank'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 80); imgui.Text('Status'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 90); imgui.Text('AFK'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 65); imgui.Text('Dist'); imgui.NextColumn()
			imgui.Separator()
			for i = 1, #membersInfo.players do
			  	if membersInfo.players[i] ~= nil then
					if sampIsPlayerConnected(membersInfo.players[i].mid) or membersInfo.players[i].mid == tempConfig.myId then
				  		if string.find(string.upper(sampGetPlayerNickname(membersInfo.players[i].mid)), string.upper(u8:decode(membersInfo.imgui.v))) ~= nil or string.find(membersInfo.players[i].mid, membersInfo.imgui.v) ~= nil or u8:decode(membersInfo.imgui.v) == '' then
							drawMembersPlayer(membersInfo.players[i])
				  		end
					end
			  	end
			end
			imgui.Columns(1)
		else imgui.Text(u8 '������������ ������...') end
		imgui.End()
	end
	if window['shpora'].bool.v then
		if data.shpora.loaded == 0 then
		data.shpora.select = {}
			for file in lfs.dir(getWorkingDirectory()..'\\Army-Tools\\shpores') do
				if file ~= '.' and file ~= '..' then
					local attr = lfs.attributes(getWorkingDirectory()..'\\Army-Tools\\shpores\\'..file)
					if attr.mode == 'file' then 
						table.insert(data.shpora.select, file)
					end
				end
			end
			data.shpora.page = 1
			data.shpora.loaded = 1
		end
    	if data.shpora.loaded == 1 then
			if #data.shpora.select == 0 then
				data.shpora.text = {}
				data.shpora.edit = 0
			else
				data.shpora.filename = 'moonloader/Army-Tools/shpores/'..data.shpora.select[data.shpora.page]
				data.shpora.text = {}
				for line in io.lines(data.shpora.filename) do
					table.insert(data.shpora.text, line)
				end
			end
			data.shpora.search.v = ''
			data.shpora.loaded = 2
		end
    	imgui.SetNextWindowSize(imgui.ImVec2(x - 400, y - 250), imgui.Cond.FirstUseEver)
    	imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    	imgui.Begin(u8('Army-Tools | �����'), window['shpora'].bool, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.MenuBar + imgui.WindowFlags.HorizontalScrollbar)
		if imgui.BeginMenuBar(u8('Army-Tools')) then
			for i = 1, #data.shpora.select do
				local text = data.shpora.select[i]:gsub('.txt', '')
				if imgui.MenuItem(u8:encode(text)) then
					data.shpora.page = i
					data.shpora.loaded = 1
				end
			end
			imgui.EndMenuBar()
    	end
   	 	if data.shpora.edit < 0 and #data.shpora.select > 0 then
      		if imgui.Button(u8('����� �����'), imgui.ImVec2(120, 30)) then
				data.shpora.edit = 0
				data.shpora.search.v = ''
				data.shpora.inputbuffer.v = ''
      		end
      		imgui.SameLine()
      		if imgui.Button(u8('�������� �����'), imgui.ImVec2(120, 30)) then
				data.shpora.edit = data.shpora.page
				local text = data.shpora.select[data.shpora.page]:gsub('.txt', '')
				data.shpora.search.v = u8:encode(text)
				local ttext  = ''
				for k, v in pairs(data.shpora.text) do
					ttext = ttext .. v .. '\n'
				end
        		data.shpora.inputbuffer.v = u8:encode(ttext)
      		end
     		imgui.SameLine()
      		if imgui.Button(u8('������� �����'), imgui.ImVec2(120, 30)) then
				os.remove(data.shpora.filename)
				data.shpora.loaded = 0
				stext('����� \''..data.shpora.filename..'\' ������� �������!')
			end
      		imgui.Spacing()
			imgui.PushItemWidth(250)
			imgui.Text(u8('����� �� ������'))
			imgui.InputText('##inptext', data.shpora.search)
			imgui.PopItemWidth()
			imgui.Separator()
			imgui.Spacing()
			for k, v in pairs(data.shpora.text) do
				if u8:decode(data.shpora.search.v) == '' or string.find(rusUpper(v), rusUpper(u8:decode(data.shpora.search.v))) ~= nil then
					imgui.Text(u8(v))
				end
			end
    	else
			imgui.PushItemWidth(250)
			imgui.Text(u8('������� �������� �����'))
			imgui.InputText('##inptext', data.shpora.search)
			imgui.PopItemWidth()
			if imgui.Button(u8('���������'), imgui.ImVec2(120, 30)) then
				if #data.shpora.search.v ~= 0 and #data.shpora.inputbuffer.v ~= 0 then
					if data.shpora.edit == 0 then
						local file = io.open('moonloader\\Army-Tools\\shpores\\'..u8:decode(data.shpora.search.v)..'.txt', 'a+')
						file:write(u8:decode(data.shpora.inputbuffer.v))
						file:close()
						stext('����� ������� �������!')
					elseif data.shpora.edit > 0 then
            			local file = io.open(data.shpora.filename, 'w+')
           				file:write(u8:decode(data.shpora.inputbuffer.v))
						file:close()
						local rename = os.rename(data.shpora.filename, 'moonloader\\Army-Tools\\shpores\\'..u8:decode(data.shpora.search.v)..'.txt')
						if rename then
							stext('����� ������� ��������!')
						else
							stext('������ ��� ��������� �����')
						end
          			end
					data.shpora.search.v = ''
					data.shpora.loaded = 0
					data.shpora.edit = -1
				else 
					stext('��� ���� ������ ���� ���������!') 
				end
      		end
			imgui.SameLine()
			if imgui.Button(u8('������'), imgui.ImVec2(120, 30)) then
				if #data.shpora.select > 0 then
					data.shpora.edit = -1
					data.shpora.search.v = ''
				else 
					stext('��� ���������� ������� ���� �� ���� �����!') 
				end
			end
			imgui.Separator()
			imgui.Spacing()
			imgui.InputTextMultiline('##intextmulti', data.shpora.inputbuffer, imgui.ImVec2(-1, -1))
		end
    	imgui.End()
	end 
	if window['smslog'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(950, 610), imgui.Cond.FirstUseEver)   
		imgui.Begin(u8(thisScript().name..' | SMS-LOG | Version: '..thisScript().version), window['smslog'].bool, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.PushItemWidth(250)
		imgui.Text(u8('����� �� ������'))
		imgui.InputText('##inptext', searchsmslog)
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(u8('�������� ���')) then
			tablesmslog = {}
		end
		imgui.Separator()
		imgui.Spacing()	
		if u8:decode(searchsmslog.v) == '' then
			firstsloglist = (sloglist - 1) * 20 + 1 -- ����� ������ ������ ��� �������� �����
			lastsloglist = sloglist * 20 -- ����� ��������� ������ ��� �������� �����
			if lastsloglist > #tablesmslog then -- ���� ����� ������ ���������� ������, ��� ����� ����� � ����
				lastsloglist = #tablesmslog -- �� ����� ��������� ������ = #tablesmslog
			end
			smsButtonsVisible = true
		else 
			firstsloglist = 1 -- ����� ������ ������ ��� �������� �����
			lastsloglist = #tablesmslog -- ����� ��������� ������ ��� �������� �����
			smsButtonsVisible = false
		end
		for k = firstsloglist, lastsloglist do
			imgui.BeginChild('##listnumber'..sloglist, imgui.ImVec2(920, 455), true)
			if u8:decode(searchsmslog.v) == '' then
				imgui.TextColoredRGB(tablesmslog[k])
				if imgui.IsItemClicked() then
					local text = tablesmslog[k]:gsub('{......}', '')
					sampSetChatInputEnabled(true)
					sampSetChatInputText(text)
				end
			elseif string.find(rusUpper(tablesmslog[k]), rusUpper(u8:decode(searchsmslog.v))) ~= nil then
				imgui.TextColoredRGB(tablesmslog[k])
				if imgui.IsItemClicked() then
					local text = tablesmslog[k]:gsub('{......}', '')
					sampSetChatInputEnabled(true)
					sampSetChatInputText(text)
				end
			end
			k = k + 1
			imgui.EndChild()
		end
		if smsButtonsVisible and #tablesmslog ~= 0 then -- ��������� ������, ��� ������ �� ����� �����
			if sloglist == 1 and math.ceil(#tablesmslog / 20) > 1 then -- ���� �������� 1
				imgui.SetCursorPosX(380)
				if imgui.Button(u8 '>>', imgui.ImVec2(90, 30)) then
					sloglist = 2
				end
			elseif sloglist > 1 and sloglist < math.ceil(#tablesmslog / 20) then -- ���� �������� �� 1 � �� ���������
				imgui.SetCursorPosX(320)
				if imgui.Button(u8 '<<', imgui.ImVec2(90, 30)) then
					sloglist = sloglist - 1
				end
				imgui.SameLine()
				if imgui.Button(u8 '>>', imgui.ImVec2(90, 30)) then
					sloglist = sloglist + 1
				end
			elseif sloglist >= math.ceil(#tablesmslog / 20) and sloglist ~= 1 then -- ���� �������� ��������� 
				imgui.SetCursorPosX(380)
				if imgui.Button(u8 '<<', imgui.ImVec2(90, 30)) then
					sloglist = sloglist - 1
				end
			end
		end
		imgui.End()
  	end
	if window['departmentlog'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(950, 610), imgui.Cond.FirstUseEver)   
		imgui.Begin(u8(thisScript().name..' | Department-LOG | Version: '..thisScript().version), window['departmentlog'].bool, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.PushItemWidth(250)
		imgui.Text(u8('����� �� ������'))
		imgui.InputText('##inptext', searchdepartmentlog)
		imgui.PopItemWidth()
		imgui.SameLine()
		if imgui.Button(u8('�������� ���')) then
			tabledepartmentlog = {}
		end
		imgui.Separator()
		imgui.Spacing()	
		if u8:decode(searchdepartmentlog.v) == '' then
			firstdloglist = (dloglist - 1) * 20 + 1 -- ����� ������ ������ ��� �������� �����
			lastdloglist = dloglist * 20 -- ����� ��������� ������ ��� �������� �����
			if lastdloglist > #tabledepartmentlog then -- ���� ����� ������ ���������� ������, ��� ����� ����� � ����
				lastdloglist = #tabledepartmentlog -- �� ����� ��������� ������ = #tabledepartmentlog
			end
			departmentButtonsVisible = true
		else 
			firstdloglist = 1 -- ����� ������ ������ ��� �������� �����
			lastdloglist = #tabledepartmentlog -- ����� ��������� ������ ��� �������� �����
			departmentButtonsVisible = false
		end
		for k = firstdloglist, lastdloglist do
			imgui.BeginChild('##listnumber'..dloglist, imgui.ImVec2(920, 455), true)
			if u8:decode(searchdepartmentlog.v) == '' then
				imgui.TextColoredRGB(tabledepartmentlog[k])
				if imgui.IsItemClicked() then
					local text = tabledepartmentlog[k]:gsub('{......}', '')
					sampSetChatInputEnabled(true)
					sampSetChatInputText(text)
				end
			elseif string.find(rusUpper(tabledepartmentlog[k]), rusUpper(u8:decode(searchdepartmentlog.v))) ~= nil then
				imgui.TextColoredRGB(tabledepartmentlog[k])
				if imgui.IsItemClicked() then
					local text = tabledepartmentlog[k]:gsub('{......}', '')
					sampSetChatInputEnabled(true)
					sampSetChatInputText(text)
				end
			end
			k = k + 1
			imgui.EndChild()
		end
		if departmentButtonsVisible and #tabledepartmentlog ~= 0 then -- ��������� ������, ��� ������ �� ����� �����
			if dloglist == 1 and math.ceil(#tabledepartmentlog / 20) > 1 then -- ���� �������� 1
				imgui.SetCursorPosX(380)
				if imgui.Button(u8 '>>', imgui.ImVec2(90, 30)) then
					dloglist = 2
				end
			elseif dloglist > 1 and dloglist < math.ceil(#tabledepartmentlog / 20) then -- ���� �������� �� 1 � �� ���������
				imgui.SetCursorPosX(320)
				if imgui.Button(u8 '<<', imgui.ImVec2(90, 30)) then
					dloglist = dloglist - 1
				end
				imgui.SameLine()
				if imgui.Button(u8 '>>', imgui.ImVec2(90, 30)) then
					dloglist = dloglist + 1
				end
			elseif dloglist >= math.ceil(#tabledepartmentlog / 20) and dloglist ~= 1 then -- ���� �������� ��������� 
				imgui.SetCursorPosX(380)
				if imgui.Button(u8 '<<', imgui.ImVec2(90, 30)) then
					dloglist = dloglist - 1
				end
			end
		end
		imgui.End()
  	end
	if window['hud'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2(config.options.hudX, config.options.hudY), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(320, 190), imgui.Cond.FirstUseEver)
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.07, config.options.hudopacity))
		imgui.PushStyleVar(imgui.StyleVar.WindowRounding, config.options.hudrounding)
		imgui.Begin('notitle', window['hud'].bool, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.SetWindowSize('notitle', imgui.ImVec2(320, 0))
		if config.options.hudset[6] then
			local titlename = u8:encode('Army-Tools')
			imgui.SetCursorPosX((300 - imgui.CalcTextSize(titlename).x) / 2)
			imgui.Text(titlename)
			imgui.Separator()
		end
		local myping = sampGetPlayerPing(tempConfig.myId)
		imgui.TextColoredRGB(('���: {%s}%s [%d]{ffffff}%s%s%s'):format(('%06X'):format(bit.band(sampGetPlayerColor(sampGetPlayerIdByNickname(tempConfig.myNick)), 0xFFFFFF)), tempConfig.myNick, tempConfig.myId,
			config.options.hudset[7] and ' | ����: '..myping or '',
		  	config.options.hudset[1] and ' | FPS: '..math.floor(imgui.GetIO().Framerate) or '',
			tempConfig.maska
		))
		if config.options.hudset[9] then
			box,color,sx,sy=sampTextdrawGetBoxEnabledColorAndSize(2078)
			hungry = math.ceil(( sx - 546 ) * 1.72)
		  	imgui.Text(u8:encode('��������: '..tempConfig.health..' | �����: '..tempConfig.armour..'  | �������: '..hungry))
		end
		if config.options.hudset[2] then
			local myweapon = getCurrentCharWeapon(PLAYER_PED)
			local myweaponammo = getAmmoInCharWeapon(PLAYER_PED, myweapon)
			local myweaponname = getweaponname(myweapon)
			imgui.Text(u8:encode(('������: %s [%d]'):format(myweaponname, myweaponammo)))
		end
		if isCharInAnyCar(playerPed) and config.options.hudset[3] then
			local vHandle = storeCarCharIsInNoSave(playerPed)
			local _, vID = sampGetVehicleIdByCarHandle(vHandle)
			local vHP = getCarHealth(vHandle)
			local speed = math.floor(getCarSpeed(vHandle)) * 2
			local vehName = tCarsName[getCarModel(vHandle) - 399]
			imgui.Text(u8:encode(('����: %s[%d] | HP: %s | ��������: %s'):format(vehName, vID, vHP, speed)))
		elseif config.options.hudset[3] then
		  	imgui.Text(u8'����: ���')
		end
		if config.options.hudset[4] or config.options.hudset[8] then
			imgui.Text(u8:encode(('%s%s'):format(
				config.options.hudset[4] and '�������: '..playerZone..' | ' or '',
				config.options.hudset[8] and '�������: '..kvadrat() or ''
			)))
		end
		if config.options.hudset[5] then
		  	imgui.Text(u8'�����: '..os.date('%H:%M:%S | %d.%m.%y'))
		end
		if config.options.timer[1] or config.options.timer[2] or config.options.timer[3] then
			imgui.Separator()
			if config.options.timer[1] then
				if timers.mask > os.time() then
					imgui.Text(u8'�����: '..get_clock(timers.mask- os.time()))
				else 
					imgui.Text(u8'�����: ��������')
				end
			end
			if config.options.timer[2] then
				if timers.dep > os.time() then
					imgui.Text(u8'�����������: '..get_clock(timers.dep - os.time()))
				else
					imgui.Text(u8'����������: ��������')
				end
			end
			if config.options.timer[3] then
				if timers.ffix > os.time() then
					imgui.Text(u8'FFIX: '..get_clock(timers.ffix - os.time()))
				else
					imgui.Text(u8'FFIX: ��������')
				end
			end
		end
		data.imgui.hudpoint = { x = imgui.GetWindowSize().x, y = imgui.GetWindowSize().y }
		imgui.End()
	    imgui.PopStyleVar()
    	imgui.PopStyleColor()
		if imgui.IsMouseClicked(0) and data.imgui.hudpos then
			data.imgui.hudpos = false
			sampToggleCursor(false)
			window['main'].bool.v = true
			if not config.options.hud then window['hud'].bool.v = false end
			saveData(config, paths.config)
		end
	end
	if window['target'].bool.v and config.options.hud then
		-- �������� �������� �������
		if targetMenu.show == true then
			if targetMenu.slide == 'top' then
				targetMenu.coordY = targetMenu.coordY - 25
				if targetMenu.coordY < config.options.hudY-10-57.5 then targetMenu.coordY = config.options.hudY-10-57.5 end
			elseif targetMenu.slide == 'bottom' then
				targetMenu.coordY = targetMenu.coordY + 25
				if targetMenu.coordY > config.options.hudY+10+57.5+data.imgui.hudpoint.y then targetMenu.coordY = config.options.hudY+10+57.5+data.imgui.hudpoint.y end
			end
		else
			if targetMenu.slide == 'top' then
				targetMenu.coordY = targetMenu.coordY + 25
				if targetMenu.coordY > (data.imgui.hudpoint.y / 2) + config.options.hudY then targetMenu.coordY = (data.imgui.hudpoint.y / 2) + config.options.hudY end
			elseif targetMenu.slide == 'bottom' then
				targetMenu.coordY = targetMenu.coordY - 25
				if targetMenu.coordY < config.options.hudY + (data.imgui.hudpoint.y / 2) then targetMenu.coordY = config.options.hudY + (data.imgui.hudpoint.y / 2) end
			end
		end
		imgui.SetNextWindowSize(imgui.ImVec2(320, 115), imgui.Cond.Always)
		imgui.SetNextWindowPos(imgui.ImVec2(300, 300), imgui.Cond.Always, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.07, config.options.hudopacity))
		imgui.PushStyleVar(imgui.StyleVar.WindowRounding, config.options.hudrounding)
		imgui.Begin(u8'Army-Tools | ������ ���', _, imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize)
		imgui.Text(u8:encode(('���: %s[%d]'):format(sampGetPlayerNickname(targetMenu.playerid), targetMenu.playerid)))
		local com = false
		for i = 1, #data.members do
			if data.members[i].pid == targetMenu.playerid then
				imgui.Text(u8:encode(('�������: %s | ������: %s[%d]'):format(tempConfig.fraction, config.ranknames[data.members[i].prank], data.members[i].prank)))
				com = true
				break
			end
		end
		if com == false then
			for i = 1, #data.players do
				if data.players[i].nick == sampGetPlayerNickname(targetMenu.playerid) then
					imgui.Text(u8:encode(('�������: %s | ������: %s'):format(data.players[i].fraction, data.players[i].rank)))
					com = true
					break
				end
			end
			if com == false then
				imgui.Text(u8:encode(('�������: %s'):format(sampGetFraktionBySkin(targetMenu.playerid))))
			end
		end
		local arm = tostring(sampGetPlayerArmor(targetMenu.playerid))
		local health = tostring(sampGetPlayerHealth(targetMenu.playerid))
		local ping = tostring(sampGetPlayerPing(targetMenu.playerid))
		imgui.Text(u8:encode(('��������: %s | �����: %s | ����: %s'):format(health, arm, ping)))
		imgui.TextColoredRGB(('���� ����: %s'):format(getcolorname(string.format('%06X', ARGBtoRGB(sampGetPlayerColor(player))))))
		imgui.End()
		imgui.PopStyleVar()
		imgui.PopStyleColor()
	end
	if window['menuscript'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2( x / 2, y / 2))
        imgui.SetNextWindowSize(imgui.ImVec2(-1,-1))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.07, 0.5)) 
		imgui.Begin('dsa',_,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		
		if not imgui.IsWindowHovered() and window['menuscript'].bool.v then
			imgui.OpenPopup('MainMenu')
		end
		if pie.BeginPiePopup('MainMenu') then
			if pie.PieMenuItem(u8'����') then menuscript(); window['main'].bool.v = true; data.show = 6 end
			if pie.PieMenuItem(u8'���������') then menuscript(); window['main'].bool.v = true;data.show = 1 end
			if pie.PieMenuItem(u8'���') then menuscript(); window['main'].bool.v = true;data.show = 9 end
			if pie.PieMenuItem(u8'Fast Menu') then menuscript(); window['fastmenuedit'].bool.v = true; end
			if pie.PieMenuItem(u8'������') then menuscript(); window['main'].bool.v = true;data.show = 4 end
			if pie.PieMenuItem(u8'������') then menuscript(); window['main'].bool.v = true;data.show = 2 end
			if pie.PieMenuItem(u8'�����') then menuscript(); window['shpora'].bool.v = true end
			if pie.PieMenuItem(u8'������') then menuscript() end 
			pie.EndPiePopup()
		end
		imgui.End()
		imgui.PopStyleColor()
	end
	if window['fastmenuedit'].bool.v then
		imgui.SetNextWindowSize(imgui.ImVec2(700, 420), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(x / 2, y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('Fast Menu',window['fastmenuedit'].bool,imgui.WindowFlags.NoResize)
		imgui.Text(u8'��������� Fast-Menu: ������ ������ ���� + ')
		imgui.SameLine()
		if imgui.HotKey(u8('##startfastmmenu'),configKeys.fastmenu, bufferKeys, 55) then
			rkeys.changeHotKey(fastmenubind, configKeys.fastmenu.v)
			stext('������� ������� ��������!')
			saveData(configKeys, 'moonloader/Army-Tools/configKeys.json')
		end
		imgui.Separator()

		imgui.BeginChild('##fastlist',imgui.ImVec2(150,295))
			for k,v in ipairs(configFastMenu) do
				if imgui.Selectable(u8:encode(v.name)) then
					binders.fast.name_menu.v = u8(v.name)
					binders.fast.items = v.items
					binders.fast.select = k
					binders.fast.select_item = nil
				end
			end
		imgui.EndChild()

		imgui.SameLine()

		imgui.BeginChild('##fastedit',imgui.ImVec2(510,295))
			imgui.BeginChild('##fastitemlist',imgui.ImVec2(480,50))
				for k,v in ipairs(configFastMenu) do
					if binders.fast.select == k then
						imgui.BeginChild('##fastmenuname',imgui.ImVec2(100,50))
							imgui.Text(u8('�������� ����:'))
							imgui.PushItemWidth(100)
							imgui.InputText('##�������� ����',binders.fast.name_menu)
							imgui.PopItemWidth()
						imgui.EndChild()
						imgui.SameLine()
						imgui.BeginChild('##fastitemslist',imgui.ImVec2(365,50))
							imgui.CentrText(u8'��������:')
							for key,value in ipairs(v.items) do
								if imgui.Button(u8(value.name)) then
									binders.fast.select_item = key
									binders.fast.text.v = u8(value.text)
									binders.fast.name.v = u8(value.name)
									binders.fast.pause.v = value.pause
								end
								imgui.SameLine()
							end
							if imgui.Button('+') then
								table.insert(configFastMenu[binders.fast.select].items,{text = '', name = '������� �'..#binders.fast.items+1,pause = 1000})
								saveData(configFastMenu,paths['fastmenu'])
							end
						imgui.EndChild()
					end
				end
			imgui.EndChild()
			imgui.BeginChild('##fastbindedit',imgui.ImVec2(500,230))
				if binders.fast.select and binders.fast.select_item then
					imgui.Separator()
					imgui.BeginChild('##fastitemname',imgui.ImVec2(150,50))
					imgui.Text(u8('�������� ��������:'))
					imgui.PushItemWidth(120)
					imgui.InputText('##�������� ����',binders.fast.name)
					imgui.PopItemWidth()
					imgui.EndChild()

					imgui.SameLine()
					
					imgui.BeginChild('##fast��������',imgui.ImVec2(165,50))
					imgui.Text(u8('�������� ����� ����� (��):'))
					imgui.PushItemWidth(165)
					imgui.InputInt('##������������������',binders.fast.pause)
					imgui.PopItemWidth()
					imgui.EndChild()

					imgui.Text(u8'������� ����� �����:')
					imgui.InputTextMultiline('##inputtextfast',binders.fast.text,imgui.ImVec2(500,100))
					
					if imgui.Button(u8'��������� ����',imgui.ImVec2(110,25)) then
						binders.fast.items = {text=u8:decode(binders.fast.text.v),pause = binders.fast.pause.v, name = u8:decode(binders.fast.name.v)}
						configFastMenu[binders.fast.select].name = u8:decode(binders.fast.name_menu.v)
						configFastMenu[binders.fast.select].items[binders.fast.select_item] = binders.fast.items						
						saveData(configFastMenu,paths['fastmenu'])
					end
					imgui.SameLine()
					if imgui.Button(u8'������� ����',imgui.ImVec2(110,25)) then
						table.remove(configFastMenu[binders.fast.select].items,binders.fast.select_item)
						binders.fast.select_item = nil
						saveData(configFastMenu,paths['fastmenu'])
					end
				end
			imgui.EndChild()
		imgui.EndChild()
		if imgui.Button(u8'�������� ����', imgui.ImVec2(150,25)) then
			configFastMenu[#configFastMenu + 1] = {name = "���� �"..#configFastMenu+1,items = {}}
			saveData(configFastMenu,paths['fastmenu'])
		end
		imgui.SameLine(535)
		if binders.fast.select then
			if imgui.Button(u8'������� ����',imgui.ImVec2(150,25)) then
				table.remove(configFastMenu,binders.fast.select)
				binders.fast.select = nil
				saveData(configFastMenu,paths['fastmenu'])
			end
		end
		imgui.End()
	end
	if window['fastmenu'].bool.v then
		imgui.SetNextWindowPos(imgui.ImVec2( x / 2, y / 2))
        imgui.SetNextWindowSize(imgui.ImVec2(-1,-1))
		imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0.06, 0.05, 0.07, 0)) 
		imgui.Begin('dsadsadasda',_,imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		
		if not imgui.IsWindowHovered() and window['fastmenu'].bool.v then
			imgui.OpenPopup('FastMenu')
		end

		if pie.BeginPiePopup('FastMenu') then
			for k,v in ipairs(configFastMenu) do
					if pie.BeginPieMenu(u8(v.name)) then
						for key,value in pairs(v.items) do
							if pie.PieMenuItem(u8(value.name)) then
								actfast()
								thread = lua_thread.create(function()
									local pause = value.pause
									local first_line = 0
									local text = value.text
									for line in text:gmatch('[^\r\n]+') do
										if first_line == 0 then 
											first_line = 1
										else
											wait(pause)
										end
										if line:match('^{wait%:%d+}$') then
											wait(math.abs(line:match('^%{wait%:(%d+)}$')-2*pause))
										elseif line:match('^{screen}$') then
											screen()
										else
											local bIsEnter = string.match(line, '^{noe}(.+)') ~= nil
											local bIsF6 = string.match(line, '^{f6}(.+)') ~= nil
											local keys = {
												['{location}'] = playerZone,
												['{targetrpnick}'] = sampGetPlayerNicknameForBinder(targetID):gsub('_', ' '),
												['{targetid}'] = targetID,
												['{naparnik}'] = naparnik(),
												['{rank}'] = ranknames[tempConfig.rank],
												['{frac}'] = tempConfig.fraction,
												['{post}'] = getPost(),
												['{screen}'] = '',
												['{f6}'] = '',
												['{noe}'] = '',
												['{myid}'] = tempConfig.myId,
												['{kv}'] = kvadrat(),
												['{myrpnick}'] = tempConfig.myNick:gsub('_', ' '),
												['{vehid}'] = tempConfig.VehicleId,
												['{mytag}'] = tag()
											}
											for k1, v1 in pairs(keys) do
												line = line:gsub(k1, v1)
											end
											if not bIsEnter then
												if bIsF6 then
													sampProcessChatInput(line)
												else
													sampSendChat(line)
												end
											else
												sampSetChatInputText(line)
												sampSetChatInputEnabled(true)
											end
										end
									end
								end)
							end
						end
						pie.EndPieMenu()
					end
			end
			if pie.PieMenuItem(u8'������') then actfast() end
			pie.EndPiePopup()
		end

		imgui.End()
		imgui.PopStyleColor()
	end
end

function targetPlayer(id)
	if config.options.target ~= true then return end
	id = tonumber(id)
	if id == nil or not sampIsPlayerConnected(id) then stext('Target Error: ����� �� ������!') return end 
	window['target'].bool.v = true
	targetMenu = {
		playerid = id,
		time = os.time(),
		show = true,
		cursor = false,
		coordX = config.options.hudX + 160,
		coordY = config.options.hudY + (data.imgui.hudpoint.y / 2)
	}
	targetMenu.slide = 'bottom'
	if y < config.options.hudY + data.imgui.hudpoint.y + 10 + 115 then targetMenu.slide = 'top' end
	lua_thread.create(function()
	  	while true do
			wait(150)
			if targetMenu.playerid ~= id then return end 
			if targetMenu.time < os.time() - 5 then 
				targetMenu.show = false
				wait(500)
				window['target'].bool.v = false
				targetMenu.playerid = nil
				targetMenu.time = nil
				return
			end
		end
		return
	end)
end

function addcounter(id, count)
	id = tonumber(id)
	count = tonumber(count)
	if id == nil or count == nil then return end
	if config.counter[id] == nil then
	  	config.counter[id] = count
	else
	  	config.counter[id] = config.counter[id] + count
	end
end

function cmd_checkbl(arg)
	if tempConfig.fraction ~= 'SFA' then stext('������� �������� ������ ������� �� SFA') return end
	if tempConfig.workingDay == false then stext('���������� ������ ������� ����!') return end
	if #arg == 0 then
	  	stext('�������: /checkbl [id / nick]')
	  	return
	end
	local id = tonumber(arg)
	if id ~= nil then
	  	if sampIsPlayerConnected(id) then arg = sampGetPlayerNickname(id)
	  	else stext('����� �������!') return end
	end
	if tempFiles.blacklistTime >= os.time() - 180 then
	  	for i = #tempFiles.blacklist, 1, -1 do
			local line = tempFiles.blacklist[i]
			if line.nick == arg or line.nick == string.gsub(arg, '_', ' ') then
		  		local blacklistStepen = { '1 �������', '2 �������', '3 �������', '4 �������', '�� ������', '�������' }
		  		stext('����� '..line.nick..' ������ � ������ ������!')
		  		if line.executor ~= nil and line.date ~= nil then 
					stext(('���: %s | ����: %s'):format(line.executor, line.date))
		  		end
		  		if line.reason ~= nil and line.stepen ~= nil then
					stext(('�������: %s | �������: %s'):format(blacklistStepen[line.stepen], u8:decode(line.reason)))
				end
				addcounter(7, 1)
				return
			end  
		end
		stext('����� �� ������ � ������ ������!')
		return
	end
	local updatelink = 'https://docs.google.com/spreadsheets/d/1yBkOkDHGgaYqZDW9hY-qG5C5Zr8S3VmEEoFFByazGZ0/export?format=tsv&id=1yBkOkDHGgaYqZDW9hY-qG5C5Zr8S3VmEEoFFByazGZ0&gid=0'
	local downloadpath = getWorkingDirectory() .. '\\SFAHelper\\blacklist.tsv'
	sampAddChatMessage('�������� ������...', 0xFFFF00)
	httpRequest(updatelink, nil, function(response, code, headers, status)
		if response then
			for line in response:gmatch('[^\r\n]+') do
		  		local arr = string.split(line, '\t')
		 		local step = arr[5]
		  		if arr[5] ~= nil then step = arr[5] end
		  		tempFiles.blacklist[#tempFiles.blacklist + 1] = { nick = arr[2], stepen = tonumber(step), date = arr[4], executor = arr[1], reason = arr[3] }
			end
			tempFiles.blacklistTime = os.time()
			cmd_checkbl(arg)
	  	end
	end)
end

function cmd_mon(arg)
	if arg == '1' and tempConfig.fraction ~= 'SFA' and tempConfig.fraction ~= 'LVA' then stext('������ � ����� �������� ������ SFA/LVA! ����� ������� ������ � ��������� ��� ������� /mon ��� ����������') return end
	if isCharInArea3d(PLAYER_PED, -1325-5, 492-5, 28-3, -1325+5, 492+5, 28+3, false) and tempConfig.fraction == 'SFA' then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local result, text = Search3Dtext(x, y, z, 1000, 'LV')
		number1, number2, mon = string.match(text, '(%d+)[^%d]+(%d+)[^%d]+(%d+)')
	  	if arg == '1' then
			cmd_r(localVars('others', 'mon', { ['sklad'] = math.floor(mon / 1000) }))
	  	else
			atext('����������: LVA - '..math.floor(mon / 1000))
	  	end
	elseif isCharInArea3d(PLAYER_PED, 219-200, 1822-200, 7-30, 219+200, 1822+200, 7+30, false) and tempConfig.fraction == 'LVA' then
		local x,y,z = getCharCoordinates(PLAYER_PED)
		local result, text = Search3Dtext(x, y, z, 500, 'FBI')
		local temp = split(text, '\n')
		for k, val in pairs(temp) do monikQuant[k] = val end
		if monikQuant[6] ~= nil then
			for i = 1, table.getn(monikQuant) do
				number1, number2, monikQuantNum[i] = string.match(monikQuant[i], '(%d+)[^%d]+(%d+)[^%d]+(%d+)')
				monikQuantNum[i] = monikQuantNum[i] / 1000
			end
		end
	  	if arg == '1' then
			cmd_r(localVars('others', 'monl', {
				['lspd'] = monikQuantNum[1],
				['sfpd'] = monikQuantNum[2],
				['lvpd'] = monikQuantNum[3],
				['sfa'] = monikQuantNum[4],
				['fbi'] = monikQuantNum[6],
			}))
		else
			atext(('����������: LSPD - %d | SFPD - %d | LVPD - %d | SFA - %d | FBI - %d'):format(monikQuantNum[1], monikQuantNum[2], monikQuantNum[3], monikQuantNum[4], monikQuantNum[6]))
	  	end
	else
	  	stext('�� ������ ���������� � �����/�� ���������� LVA!')
	  	return
	end
end

function drawMembersPlayer(table)
	local nickname = sampGetPlayerNickname(table.mid)
	local color = sampGetPlayerColor(table.mid)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
	local _, ped = sampGetCharHandleBySampPlayerId(table.mid)
	local distance = '���'
	if doesCharExist(ped) then
	  	local mx, my, mz = getCharCoordinates(PLAYER_PED)
	  	local cx, cy, xz = getCharCoordinates(ped)
	  	distance = ('%0.2f'):format(getDistanceBetweenCoords3d(mx, my, mz,cx, cy, xz))
	end
	imgui.Text(tostring(table.mid)); imgui.NextColumn()
  	imgui.TextColored(imgui_RGBA, nickname)
  	if imgui.IsItemClicked(1) then
    	selectedContext = table.mid
    	imgui.OpenPopup('ContextMenu')
  	end
  	imgui.NextColumn()
	imgui.Text(u8:encode(('%s[%d]'):format(config.ranknames[table.mrank], table.mrank))); imgui.NextColumn()
	imgui.TextColoredRGB((table.mstatus and '{008000}�� ������' or '{B22222}��������')); imgui.NextColumn()
	imgui.Text(u8:encode(table.mafk ~= nil and table.mafk..' ������' or '')); imgui.NextColumn()
	imgui.Text(u8:encode(distance)); imgui.NextColumn()
end

function cmd_members(args)
	membersInfo.players = {}
	if args == '1' and isGosFraction(tempConfig.fraction) then
	  	membersInfo.mode = 1
	elseif args == '2' and isGosFraction(tempConfig.fraction) then
		membersInfo.work = 0
		membersInfo.imgui = imgui.ImBuffer(256)
		membersInfo.nowork = 0
		membersInfo.mode = 2
		window['members'].bool.v = true
	else
		if config.options.modmembers then
	  		membersInfo.mode = -1
		else
			membersInfo.mode = 0
		end
	end
	sampSendChat('/members')
end

function cmd_stats(args)
	lua_thread.create(function()
		sampSendChat('/stats')
		while not sampIsDialogActive() or sampGetCurrentDialogId() ~= 9901 do wait(0) end
		local fraction = cleartrash(sampGetDialogText():match('�����������%s+(.-)\n'))
		local rank = cleartrash(sampGetDialogText():match('���������%s+(%d+) .-\n'))
		local sex = cleartrash(sampGetDialogText():match('���%s+(.-)\n'))
		if config.options.sex == nil then
		  	if sex == '�������' then config.options.sex = 1
		  	elseif sex == '�������' then config.options.sex = 0
		  	else config.options.sex = 1 end
		end
		tempConfig.fraction = tostring(fraction)
		if tempConfig.fraction == 'nil' then tempConfig.fraction = 'no' end
		if fractions[tempConfig.fraction] ~= nil then
			rank = tonumber(rank)
			if rank == nil or rank == 0 then
				print('����� ��� � ����������!')
			elseif rank > #ranknames then
				print('���� �� ���������')
			else
				tempConfig.rank = rank
				print(('���� ���������: %s[%d]'):format(ranknames[rank], rank))
			end
		else
			print('������ ������� �� �������������� ��������. ���������� �� ��������')
			tempConfig.fraction = 'Unsupported fraction'
			tempConfig.rank = 0
		end
		if args == 'checkout' then sampCloseCurrentDialogWithButton(1) end
		return
	end)
end
  
function cleartrash(string)
	string = tostring(string)
	return (string:gsub('^%s*(.-)%s*$', '%1'))
end

function isGosFraction(fracname)
	local fracs = {'SFA', 'LVA', 'LSPD', 'SFPD', 'LVPD', 'Instructors', 'FBI', 'Medic', 'Mayor'}
	for i = 1, #fracs do
		if fracname == fracs[i] then
			return true
		end
	end
	return false
end

function Search3Dtext(x, y, z, radius, patern)
    local text = ''
    local color = 0
    local posX = 0.0
    local posY = 0.0
    local posZ = 0.0
    local distance = 0.0
    local ignoreWalls = false
    local player = -1
    local vehicle = -1
    local result = false
    for id = 0, 2048 do
        if sampIs3dTextDefined(id) then
            local text2, color2, posX2, posY2, posZ2, distance2, ignoreWalls2, player2, vehicle2 = sampGet3dTextInfoById(id)
            if getDistanceBetweenCoords3d(x, y, z, posX2, posY2, posZ2) < radius then
                if string.len(patern) ~= 0 then
                    if string.match(text2, patern, 0) ~= nil then result = true end
                else
                    result = true
                end
                if result then
                    text = text2
                    color = color2
                    posX = posX2
                    posY = posY2
                    posZ = posZ2
                    distance = distance2
                    ignoreWalls = ignoreWalls2
                    player = player2
                    vehicle = vehicle2
                    radius = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
                end
            end
        end
    end
	return result, text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle
end

function sampev.onServerMessage(color, text)
	if color == -8224086 then
		local colors = ('{%06X}'):format(bit.rshift(color, 8))
		timers.dep = os.time() + 10
		table.insert(tabledepartmentlog, os.date(colors..'[%d/%m/%Y - %X] ') .. text)
	end
	if color == -65366 and (text:match('SMS%: .+. �����������%: .+') or text:match('SMS%: .+. ����������%: .+') or text:match('SMS%: .+ �����������%: .+') or text:match('SMS%: .+ ����������%: .+')) then
		if text:match('SMS%: .+. �����������%: .+%[%d+%]') then 
			ONEsmsid = text:match('SMS%: .+. �����������%: .+%[(%d+)%]') 
		elseif text:match('SMS%: .+. ����������%: .+%[%d+%]') then 
			ONEsmstoid = text:match('SMS%: .+. ����������%: .+%[(%d+)%]') 
		elseif text:match('SMS%: .+ �����������%: .+%[%d+%]') then 
			TWOsmsid = text:match('SMS%: .+ �����������%: .+%[(%d+)%]') 
		elseif text:match('SMS%: .+ ����������%: .+%[%d+%]') then 
			TWOsmstoid = text:match('SMS%: .+ ����������%: .+%[(%d+)%]') 
		end
		local colors = ('{%06X}'):format(bit.rshift(color, 8))
		table.insert(tablesmslog, os.date(colors..'[%d/%m/%Y - %X] ') .. text)
		table.sort(tablesmslog, function(a, b) return a > b end)
	end
	if isGosFraction(tempConfig.fraction) then
		if text:match('^ ����� ����������� ��%-����:$') then
			data.members = {}
			membersInfo.work = 0
			membersInfo.nowork = 0
			if membersInfo.mode >= 2 then return false end
		end
		if text:match('^ �����: %d+ �������$') then
			membersInfo.online = tonumber(text:match('^ �����: (%d+) �������$'))
			if membersInfo.mode >= 2 then membersInfo.mode = 0 return false end
			membersInfo.mode = 0
		end
		if text:match('') and color == -1 and membersInfo.mode >= 2 then return false end
		if text:match('^ ID: %d+ | .- | .-%: .-%[%d+%] %- {.+}.+{FFFFFF} | {FFFFFF}%[AFK%]%: .+ ������$') then
			local id, date, nick, rankname, rank, status, afk = text:match('^ ID: (%d+) | (.-) | (.-)%: (.-)%[(%d+)%] %- (.+){FFFFFF} | {FFFFFF}%[AFK%]%: (.+) ������$')
			id = tonumber(id)
			rank = tonumber(rank)
			if config.ranknames[rank] ~= rankname then
				config.ranknames[rank] = rankname
			end
			if status == '{008000}�� ������' then 
				status = true
				membersInfo.work = membersInfo.work + 1
			else 
				status = false
				membersInfo.nowork = membersInfo.nowork + 1
			end
			data.members[#data.members + 1] = { pid = id, prank = rank }
			if id == tempConfig.myId then
				config.options.rank = rank
				tempConfig.workingDay = status
			end
			membersInfo.players[#membersInfo.players + 1] = { mid = id, mrank = rank, mstatus = status, mafk = afk }
			if membersInfo.mode == 1 then
				streamed, _ = sampGetCharHandleBySampPlayerId(id)
				if config.options.membersdate == true then
					text = ('ID: %d | %s: %s[%d] - %s{FFFFFF} | [AFK]: %s ������'):format(id, sampGetPlayerNickname(id), config.ranknames[rank], rank, status and '{008000}�� ������' or '{ae433d}��������', afk)
				end
				if id ~= tempConfig.myId then
					text = string.format('%s - %s', text, streamed and '{00BF80}in stream' or '{ec3737}not in stream')
				end
				color = argb_to_rgba(sampGetPlayerColor(id))
			elseif membersInfo.mode == -1 then
				color = bit.lshift(sampGetPlayerColor(id), 8)
				return {color,text}
			elseif membersInfo.mode == 2 then
				return false
			end
		elseif text:match('^ ID: %d+ | .+%[%d+%] %- {.+}.+{FFFFFF}$') then
			local id, date, nick, rankname, rank, status = text:match('^ ID: (%d+) | (.-) | (.-)%: (.-)%[(%d+)%] %- (.+){FFFFFF}$')
			id = tonumber(id)
			rank = tonumber(rank)
			if config.ranknames[rank] ~= rankname then
				config.ranknames[rank] = rankname
			end
			if status == '{008000}�� ������' then 
				status = true
				membersInfo.work = membersInfo.work + 1
			else 
				status = false
				membersInfo.nowork = membersInfo.nowork + 1
			end
			data.members[#data.members + 1] = { pid = id, prank = rank }
			if id == tempConfig.myId then
				config.options.rank = rank
				tempConfig.workingDay = status
			end
			membersInfo.players[#membersInfo.players + 1] = { mid = id, mrank = rank, mstatus = status }
			if membersInfo.mode == 1 then
				streamed, _ = sampGetCharHandleBySampPlayerId(id)
				if config.options.membersdate == true then
			  		text = ('ID: %d | %s: %s[%d] - %s{FFFFFF}'):format(id, sampGetPlayerNickname(id), config.ranknames[rank], rank, status and '{008000}�� ������' or '{ae433d}��������')
				end
				if id ~= tempConfig.myId then
			  		text = string.format('%s - %s', text, streamed and '{00BF80}in stream' or '{ec3737}not in stream')
				end
				color = argb_to_rgba(sampGetPlayerColor(id))
			elseif membersInfo.mode == -1 then
				color = argb_to_rgba(sampGetPlayerColor(id))
				return {color,text}
			elseif membersInfo.mode == 2 then
				return false
			end
		end
	end
	if text:find('%S+%: .+') and config.options.modradiobool == true and (color == 33357768 or color == -1920073984) then
		local matchNick = text:match('(%S+)%: .+'):gsub('%[%d+%]', '')
		local getIdByMatchNick = sampGetPlayerIdByNickname(matchNick)
		if matchNick ~= '�������' then
			text = text:gsub('%[%d+%]', ''):gsub(matchNick, ('{%s}%s [%s]{%s}'):format(('%06X'):format(bit.band(sampGetPlayerColor(getIdByMatchNick), 0xFFFFFF)), matchNick, getIdByMatchNick, ('%06X'):format(bit.rshift(color, 8))))
		end
	end	
	if color == 1687547391 then
		if config.options.clistbool == true and text:find('������� ���� �����') then
			lua_thread.create(function()
				wait(1)
				sampSendChat(string.format('/clist %s', config.options.clist))
			end)
		end
	end
	if text:match('�� ������ .-%: %d+/200000') and color == -65366 and config.options.autodoklad == true and tempConfig.fraction == 'LVA' then
		local frac, sklad = text:match('�� ������ (.-)%: (%d+)/200000')
		punkeyActive = 3
		punkey[3].text = localVars('lvapost', 'unload', { 
			['id'] = tempConfig.myId, 
			['sklad'] = math.floor((tonumber(sklad) / 1000) + 0.5), 
			['frac'] = frac, 
			['gps'] = frac == 'LSPD' and '600-1' or frac == 'SFPD' and '600-2' or frac == 'LVPD' and '600-3' or frac == '���' and '600-4'
		})
		punkey[3].time = os.time()
		stext(('������� {139904}%s{FFFFFF} ��� ���������� � ���������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('�� ������ ����� ��%: %d+/300000') and color == -65366 and config.options.autodoklad == true and tempConfig.fraction == 'LVA' then
	    punkeyActive = 3
	    punkey[3].text = localVars('lvapost', 'unloadgs', { ['id'] = tempConfig.myId })
	    punkey[3].time = os.time()
	    stext(('������� {139904}%s{FFFFFF} ��� ���������� � ���������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('�����������%: /conveyingarms %-%> /carm') and color == 14221512 and config.options.autodoklad == true then
		punkeyActive = 3
		punkey[3].text = localVars('lvapost', 'start', { ['id'] = tempConfig.myId })
		punkey[3].time = os.time()
		stext(('������� {139904}%s{FFFFFF} ��� ���������� � ������ ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('��������� ��������� �� ���� 51') and color == -86 then
		punkeyActive = 3
		punkey[3].text = localVars('autopost', 'load', { ['id'] = tempConfig.myId })
		punkey[3].time = os.time()
		stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('�� ������ ���� 51 %d+%/300000 ����������') and color == -65366 then
		addcounter(8, 1)
		local materials = tonumber(text:match('�� ������ ���� 51 (%d+)/300000 ����������'))
		punkeyActive = 3
		punkey[3].text = localVars('autopost', 'unload', { ['id'] = tempConfig.myId, ['sklad'] = math.floor((materials / 1000) + 0.5) })
		punkey[3].time = os.time()
		stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('������������� �� ������� ��� �������� ����������') and color == -1697828182 then
		if color == -1697828182 then -- ��� � �������� �� ���
			punkeyActive = 3
			punkey[3].text = localVars('autopost', 'start', { ['id'] = tempConfig.myId })
			punkey[3].time = os.time()
			punkey[3].active = true
			stext(('������� {139904}%s{FFFFFF} ��� ���������� �� ������ ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
		  elseif color == -86 then -- ��� � �������� �� ���
			if isCharInArea2d(PLAYER_PED, 2720.00 + 150, -2448.29 + 150, 2720.00 - 150, -2448.29 - 150, false) then
			  punkeyActive = 3
			  punkey[3].text = localVars('autopost', 'startp', {})
			  punkey[3].time = os.time()
			  stext(('������� {139904}%s{FFFFFF} ��� ���������� �� ������ ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))         
			end
		end
	end
	if text:match('�� ������ ����� LS%: %d+%/200000') and color == -65366 then
		local sklad = text:match('�� ������ ����� LS%: (%d+)/200000')
		if tonumber(sklad) ~= nil then
			lua_thread.create(function()
				wait(5)
				selectWarehouse = 0
				sampSendChat('/carm')
				punkeyActive = 3
				punkey[3].text = localVars('autopost', 'unload_boat_lsa', { ['id'] = tempConfig.myId, ['sklad'] = math.floor((tonumber(sklad) / 1000) + 0.5) })
				punkey[3].time = os.time()
				stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end)
		end
	end 
	if text:match('�� ������ ����� ��%: %d+%/300000') and color == -65366 then
		addcounter(9, 1)
		local sklad = text:match('�� ������ ����� ��%: (%d+)%/300000')
		if tonumber(sklad) ~= nil and tempConfig.fraction == 'SFA' then
			lua_thread.create(function()
				wait(5)
				selectWarehouse = 0
				sampSendChat('/carm')
				punkeyActive = 3
				punkey[3].text = localVars('autopost', 'unload_boat', { ['id'] = tempConfig.myId, ['sklad'] = math.floor((tonumber(sklad) / 1000) + 0.5) })
				punkey[3].time = os.time()
				stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end)
		end
	end
	if text:match('����������%: 30000%/30000') and color == 14221512 then
		if warehouseDialog == 1 then
			lua_thread.create(function()
				wait(5)
				selectWarehouse = 3
				sampSendChat('/carm')
				punkeyActive = 3
				punkey[3].text = localVars('autopost', 'load_boat', { ['id'] = tempConfig.myId })
				punkey[3].time = os.time()
				stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end)
		elseif warehouseDialog == 2 then
			lua_thread.create(function()
				wait(5)
				selectWarehouse = 4
				sampSendChat('/carm')
				punkeyActive = 3
				punkey[3].text = localVars('autopost', 'load_boat_lsa', { ['id'] = tempConfig.myId })
				punkey[3].time = os.time()
				stext(('������� {139904}%s{FFFFFF} ��� ���������� � �����'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end)
		end
	end
	if text:match('����� ��������� �� %d+ �� %d+ ����������%.') and color == 866792447 then
		punkeyActive = 4
		punkey[4].text = localVars('autopost', 'start_boat', { ['id'] = tempConfig.myId })
		stext(('������� {139904}%s{FFFFFF} ��� ������ ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
	end
	if text:match('�� ��������� .+ .+%[%d+%]') and color == -1697828097 then
		local pNick, _, pRank = text:match('�� ��������� (.+) (.+)%[(%d+)%]')
		addcounter(3, 1)
		lua_thread.create(function()
			wait(100)
			if tempConfig.workingDay and tonumber(pRank) > 1 then
				punkeyActive = 2
				punkey[2].nick = pNick
				punkey[2].time = os.time()
				punkey[2].rank = tonumber(pRank)
				stext(('������� {139904}%s{FFFFFF} ��� �� ��������� ���������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end
		end)
	end
	if text:match('.+ �������%(%- �%) .- .+') and color == -1029514582 then
		local kto, _, kogo = text:match('(.+) �������%(%- �%) (.-) (.+)')
		if kto == tempConfig.nick then
			if sampGetPlayerNickname(contractId) == kogo then
				lua_thread.create(function()
					wait(250)
					sampSendChat(('/giverank %s %s'):format(contractId, contractRank))
					contractId = nil
					contractRank = nil
				end)
			end
			addcounter(1, 1)
		elseif kogo == tempConfig.nick then
			tempConfig.workingDay = true
			cmd_stats('checkout')
		end  
	end
	if text:match('�� ������� .+ �� �����������. �������: .+') and color == 1806958506 then
		local pNick, pReason = text:match('�� ������� (.+) �� �����������. �������: (.+)')
		if tempConfig.workingDay then
			addcounter(2, 1)
			lua_thread.create(function()
				wait(1250)
				sampSendChat(localVars('rp', 'uninvite', { ['nick'] = string.gsub(pNick, '_', ' ') }))
				wait(100)
				punkeyActive = 1
				punkey[1].nick = pNick
				punkey[1].time = os.time()
				punkey[1].reason = pReason
				stext(('������� {139904}%s{FFFFFF} ���������� � ����� �� ����������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
			end)
		end
	end
	if text:find('�� ������ �����') then tempConfig.maska = " \n�� ������ � �����" end
	if text:find('�� ����� � ���� �����') then
		timers.mask = os.time() + 900
		tempConfig.maska = ""
		if config.options.clistbool == true and tempConfig.workingDay == true then
			lua_thread.create(function()
				wait(1400)
				sampSendChat(string.format('/clist %s', config.options.clist))
			end)
		end
	end
	if text:find('��������� ��������� ������������ �������� �����������') and color == 866792447 then timers.ffix = os.time() + 600 end
 	return {color, text}
end

function sampev.onSendCommand(command)
	local str = replaceIds(command)
	if str ~= command then
	  	return { str }
	end
end
  
function sampev.onSendChat(message)
	local str = replaceIds(message)
	if str ~= message then
	  	return { str }
	end
end

function replaceIds(string)
	while true do
	  if string:find('@%d+') then
			local id = string:match('@(%d+)')
			if id ~= nil and sampIsPlayerConnected(id) then
				string = string:gsub('@'..id, sampGetPlayerNickname(id))
			else
				string = string:gsub('@'..id, id)
			end
		else break end
	end
	-------------
	while true do
		if string:find('#%d+') then
			local id = string:match('#(%d+)')
			if id ~= nil and sampIsPlayerConnected(id) then
				string = string:gsub('#'..id, sampGetPlayerNickname(id):gsub('_', ' '))
			else
				string = string:gsub('#'..id, id)
			end
		else break end
	end
	return string
end

function punaccept()
	if tempConfig.workingDay == false then return end
	if punkeyActive == 0 then 
		return
	elseif punkeyActive == 1 then
		if punkey[1].nick then
			if punkey[1].time > os.time() - 1 then stext('�� �����!') return end
			if punkey[1].time > os.time() - 15 then
			cmd_r(localVars('rp', 'uninviter', {
				['nick'] = string.gsub(punkey[1].nick, '_', ' '),
				['reason'] = punkey[1].reason
			}))
			end
			punkey[1].nick, punkey[1].reason, punkey[1].time = nil, nil, nil
		end
	elseif punkeyActive == 2 then
		if punkey[2].nick then
			if punkey[2].time > os.time() - 1 then stext('�� �����!') return end
			if punkey[2].time > os.time() - 15 then
			sampSendChat(localVars('rp', 'giverank', {
				['type'] = punkey[2].rank > 6 and '������' or '�����',
				['rankname'] = config.ranknames[punkey[2].rank]
			}))
			end
			punkey[2].nick, punkey[2].rank, punkey[2].time = nil, nil, nil
		end
	elseif punkeyActive == 3 then
		if punkey[3].text ~= nil then
			if punkey[3].time > os.time() - 1 then stext('�� �����!') return end
				if punkey[3].time > os.time() - 15 then
				cmd_r(punkey[3].text)
				if punkey[3].text:match('Army LV. ��������� %- 300%/300') then
					punkeyActive = 3
					punkey[3].text = localVars('autopost', 'ends', { ['id'] = tempConfig.myId })
					punkey[3].time = os.time()
					stext(('������� {139904}%s{FFFFFF} ��� ���������� � ����� �� ��������� ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
					return
				elseif punkey[3].text:match('Army SF. ��������� %- 300%/300') then
					punkeyActive = 3
					punkey[3].text = localVars('autopost', 'ends_boat', { ['id'] = tempConfig.myId })
					punkey[3].time = os.time()
					stext(('������� {139904}%s{FFFFFF} ��� ���������� � ����� �� ��������� ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
					return          
				end
			end
			punkey[3].text, punkey[3].time = nil, nil
		end
	elseif punkeyActive == 4 then
		warehouseDialog = 0
		openPopup = u8'�������� �����'
		selectWarehouse = 0
		sampSendChat('/carm')
	elseif punkeyActive == 5 then
		if punkey[5].time > os.time() - 1 then stext('�� �����!') return end
		if punkey[5].time > os.time() - 20 then
			sampSendChat('/d '..punkey[5].text)
		end
	elseif punkeyActive == 6 then cmd_r(punkey[4].text)
	elseif punkeyActive == 7 then cmd_r(punkey[3].text)
	end
	punkeyActive = 0
end

function actfast()
	if not window['main'].bool.v then
		window['fastmenu'].bool.v = not window['fastmenu'].bool.v
	end
end

function menuscript()
	if not window['main'].bool.v then
		window['menuscript'].bool.v = not window['menuscript'].bool.v
	end
end

function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
	if dialogid == 9653 and selectWarehouse >= 0 then
		lua_thread.create(function()
			wait(1)
			sampSendDialogResponse(9653, 1, selectWarehouse, '')
			selectWarehouse = -1
			sampCloseCurrentDialogWithButton(0)
			return
		end)
	end
	if dialogid == 1111 and #tostring(config.options.password) >= 6 and config.options.autologin then
		sampSendDialogResponse(dialogid, 1, _, tostring(config.options.password))
		return false
	end
	if dialogid == 20057 then
        GetAutoBP()
    end
end

function sampev.onPlayerQuit(playerid, reason)
	if playerid == targetID then
	  	targetID = nil
	end
	if config.options.showquit then
		for i = 0, sampGetMaxPlayerId(true) do
			if playerid == i then
				result,handle = sampGetCharHandleBySampPlayerId(playerid)
				if doesCharExist(handle) and result then
					nick = sampGetPlayerNickname(playerid)
					stext(nick..' ����� �� �������. �������: {B40404}'..reason_quit[reason])
				end
			end
		end
	end
end

function sampev.onSendSpawn()
	if config.options.clistbool == true and tempConfig.workingDay == true then
		lua_thread.create(function()
			wait(1400)
			sampSendChat(string.format('/clist %s', config.options.clist))
		end)
	end
end

function sampev.onSendExitVehicle(vehid)
	result,veh_hanlde = sampGetCarHandleBySampVehicleId(vehid)
	carid = getCarModel(veh_hanlde)
	if punkey[4].active and carid == 595 then
		if warehouseDialog == 1 then punkey[4].text = localVars('autopost', 'ends_boat', { ['id'] = tempConfig.myId })
		elseif warehouseDialog == 2 then punkey[4].text = localVars('autopost', 'ends_boat_lsa', { ['id'] = tempConfig.myId }) end
 		punkeyActive = 6
		stext(('������� {139904}%s{FFFFFF} ��� ������� � ���������� ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
		punkey[4].active = false
	elseif punkey[3].active and carid == 548 then
		punkeyActive = 7 
		punkey[3].text = localVars('autopost', 'ends', { ['id'] = tempConfig.myId })
		stext(('������� {139904}%s{FFFFFF} ��� ������� � ���������� ��������'):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + ')))
		punkey[3].active = false
	end
end

function sampGetPlayerIdByNickname(nick)
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	if tostring(nick) == sampGetPlayerNickname(myid) then 
		return myid 
	end
	for i = 0, 1000 do 
		if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == tostring(nick) then 
			return i 
		end 
	end
end

function localVars(category, subcategory, args)
	local cat = localInfo[category]
	if cat ~= nil then
	  	cat = cat[subcategory]
	  	if cat ~= nil then
			local pos = config.options.sex == 1 and 2 or 3
			local text = cat[pos]
			if text ~= nil then
		  		if args ~= nil then
					for k, v in pairs(args) do
			  			text = text:gsub('{'..k..'}', v)
					end
		  		end
		  		return text
			end
	  	end
	end
	return false
end

function updateScript()
	local filepath = os.getenv('TEMP') .. '\\armytoolsupd.json'
	downloadUrlToFile('https://raw.githubusercontent.com/n1cho/SAMP-Lua/main/armytoolsupd.json', filepath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local file = io.open(filepath, 'r')
			if file then
				local info = decodeJson(file:read('*a'))
				updatelink = info.updateurl
				if info and info.latest then
					if tonumber(thisScript().version) < tonumber(info.latest) then
						lua_thread.create(function()
							stext('�������� ���������� ����������. ������ �������������� ����� ���� ������.')
							wait(300)
							downloadUrlToFile(updatelink, thisScript().path, function(id3, status1, p13, p23)
								if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
									print('���������� ������� ������� � �����������.')
								elseif status1 == 64 then
									stext('���������� ������� ������� � �����������. ����������� ������ ��������� - /swupd')
								end
							end)
						end)
					else
						print('���������� ������� �� ����������.')
						update = false
					end
				end
			else
				print('�������� ���������� ������ ���������. �������� ������ ������.')
			end
		elseif status == 64 then
			print('�������� ���������� ������ ���������. �������� ������ ������.')
			update = false
		end
	end)
end

function cmd_r(args)
	if #args == 0 then
		atext('�������: /r [text]')
		return
	end
	if config.options.tagbool == true then
		sampSendChat(string.format('/r %s %s', config.options.tag, args))
	else
		sampSendChat(string.format('/r %s', args))
	end
end

function cmd_f(args)
	if #args == 0 then
		atext('�������: /f [text]')
		return
	end
	if config.options.tagbool == true then
		sampSendChat(string.format('/r %s %s', config.options.tag, args))
	else
		sampSendChat(string.format('/r %s', args))
	end
end

function GetAutoBP()
    if config.options.useautobp then
        local gun = {}
        if config.autoBP.deagle then table.insert( gun, 0) end
        if config.autoBP.shot then table.insert( gun,1 ) end
        if config.autoBP.smg then table.insert( gun,2 ) end
        if config.autoBP.m4 then table.insert( gun,3 ) end
        if config.autoBP.rifle then table.insert( gun,4 ) end
        if config.autoBP.armour then table.insert( gun,5 ) end
        if config.autoBP.spec then table.insert( gun,6 ) end
        lua_thread.create(function()
            wait(100)
            if autoBP == #gun + 1 then -- ��������� ����-�� 
                autoBP = 1
                if config.autoBP.close then
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

function cmd_setkv(arg)
	if #arg > 0 then
		local ky, kx = arg:match('(%A)-(%d+)')
		if ky ~= nil and getKVNumber(ky) ~= nil and kx ~= nil and tonumber(kx) < 25 and tonumber(kx) > 0 then
			kvCoord.ny = ky
			kvCoord.nx = kx
			kvCoord.x = kx * 250 - 3125
			kvCoord.y = (getKVNumber(ky) * 250 - 3125) * - 1
		else
			stext('�������� �������� ��������! ������: �-11 (�� �������)')
			return
		end
	end
	if kvCoord.x == nil or kvCoord.y == nil then stext('�� ������� ����� ���������� � �������� � ����') return end
	local cX, cY, cZ = getCharCoordinates(playerPed)
	cX = math.ceil(cX)
	cY = math.ceil(cY)
	atext('����� ����������� �� ������� '..kvCoord.ny..'-'..kvCoord.nx.. '. ���������: '..math.ceil(getDistanceBetweenCoords2d(kvCoord.x, kvCoord.y, cX, cY))..' �.')
	placeWaypoint(kvCoord.x, kvCoord.y, 0)
end

function cmd_sweather(arg)
	if #arg == 0 then
		stext('�������: /sweather [������ 0-45]')
		return
	end    
	local weather = tonumber(arg)
	if weather ~= nil and weather >= 0 and weather <= 45 then
		forceWeatherNow(weather)
		atext('������ �������� ��: '..weather)
	else
		stext('�������� ������ ������ ���� � ��������� �� 0 �� 45.')
	end
end

function cmd_stime(arg)
	if #arg == 0 then
		stext('�������: /stime [����� 0-23 | -1 �����������]')
		return
	end
	local hour = tonumber(arg)
	if hour ~= nil and hour >= 0 and hour <= 23 then
		time = hour
		patch_samp_time_set(true)
		if time then
			setTimeOfDay(time, 0)
			atext('����� �������� ��: '..time)
		end
	else
		stext('�������� ������� ������ ���� � ��������� �� 0 �� 23.')
		patch_samp_time_set(false)
		time = nil
	end
end

function cmd_blag(arg)
	if #arg == 0 then
		stext('�������: /blag [��] [�������] [���]')
		stext('���: 1 - ������ �� �������, 2 - �� ������� �� ����������, 3 - �� ���������������')
		return
	end
	local args = string.split(arg, ' ', 3)
	args[3] = tonumber(args[3])
	if args[1] == nil or args[2] == nil or args[3] == nil then
		stext('�������: /blag [��] [�������] [���]')
		stext('���: 1 - ������ �� �������, 2 - �� ������� �� ����������, 3 - �� ���������������')
		return   
	end
	local pid = tonumber(args[1])
	if pid == nil then stext('����� �� ������!') return end
	if not sampIsPlayerConnected(pid) then stext('����� �������!') return end
	local blags = { '������ �� �������', '������� � ����������', '���������������' }
	if args[3] < 1 or args[3] > #blags then stext('�������� ���!') return end
	sampSendChat(localVars('punaccept', 'blag', {
		['frac'] = args[2],
		['id'] = string.gsub(sampGetPlayerNickname(pid), '_', ' '),
		['reason'] = blags[args[3]]
	}))
end

function cmd_contract(arg)
	if config.options.rank < 12 then stext('������ ������� �������� ������ � ����') return end
	if #arg == 0 then
		stext('�������: /contract [playerid] [����]')
		return
	end
	local args = string.split(arg, ' ')
	local pid = tonumber(args[1])
	local rank = tonumber(args[2])
	if pid == nil then stext('�������� ID ������!') return end
	if rank == nil then stext('�������� ���������!') return end
	if tempConfig.myId == pid then stext('�� �� ������ ������� ������ ����!') return end
	if not sampIsPlayerConnected(pid) then stext('����� �������!') return end
	sampSendChat('/invite '..pid)
	contractId = pid
	contractRank = rank
end

function cmd_reconnect(args)
	if #args == 0 then
		stext('�������: /reconnect [�������]')
		return
	end
	args = tonumber(args)
	if args == nil or args < 1 then
	    stext('�������� ��������!')
		return
	end
	lua_thread.create(function()
		sampDisconnectWithReason(quit)
		wait(args * 1000) 
		sampSetGamestate(1)
		return
	end)
end

function cmd_cchat()
	memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
	memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
	memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

function cmd_loc(args)
	args = string.split(args, ' ')
	if #args ~= 2 then
		stext('�������: /loc [id/nick] [�������]')
		return
	end
	local name = args[1]
	local rnick = tonumber(name)
	if rnick ~= nil then
		if rnick == tempConfig.myId or name == tempConfig.myNick then stext('������ ����������� � ������ ����.') return end
		if sampIsPlayerConnected(rnick) then name = sampGetPlayerNickname(rnick)
		else stext('����� �������') return end
	end
	cmd_r(localVars('punaccept', 'loc', {
		['nick'] = string.gsub(name, '_', ' '),
		['sec'] = args[2]
	}))
end

function cmd_vig(arg)
	if #arg == 0 then
		stext('�������: /vig [id] [��� �������� (�������/�������)] [�������]')
		return
	end
	local args = string.split(arg, ' ', 3)
	if args[2] == nil or args[3] == nil then
		stext('�������: /vig [id] [��� �������� (�������/�������)] [�������]')
		return
	end
	local pid = tonumber(args[1])
	if pid == nil then stext('�������� ID ������!') return end
	if tempConfig.myId == pid then stext('�� �� ������ ������ ������� ������ ����!') return end
	if not sampIsPlayerConnected(pid) then stext('����� �������!') return end
	cmd_r(localVars('punaccept', 'vig', {
		['id'] = sampGetPlayerNickname(pid):gsub('_', ' '),
		['type'] = args[2],
		['reason'] = args[3]
	}))
end

function cmd_naryad(arg)
	if #arg == 0 then
		stext('�������: /vig [id] [���-�� ������] [�������]')
		return
	end
	local args = string.split(arg, ' ', 3)
	if args[2] == nil or args[3] == nil then
		stext('�������: /vig [id] [���-�� ������] [�������]')
		return
	end
	local pid = tonumber(args[1])
	if pid == nil then stext('�������� ID ������!') return end
	if tempConfig.myId == pid then stext('�� �� ������ ������ ����� ������ ����!') return end
	if not sampIsPlayerConnected(pid) then stext('����� �������!') return end
	cmd_r(localVars("punaccept", "naryad", {
		['id'] = sampGetPlayerNickname(pid):gsub('_', ' '),
		['count'] = args[2],
		['reason'] = args[3]
	}))
end

function cmd_ev(arg)
	if #arg == 0 then
		stext('�������: /ev [0-1] [���-�� ����]')
		return
	end
	local args = string.split(arg, ' ', 2)
	args[1] = tonumber(args[1])
	args[2] = tonumber(args[2])
	if args[2] == nil or args[2] < 1 then
		stext('�������� ���������� ����!')
		return
	end
	local selectPos = 0
	local kvx = ''
	local X, Y
	local KV = {'�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�'}
	if args[1] == 0 then
		X, Y, _ = getCharCoordinates(playerPed)
	elseif args[1] == 1 then
		result, X, Y, _ = getTargetBlipCoordinatesFixed()
		if not result then stext('���������� ����� �� �����') return end
	else
		stext('��������� ��������: 0 - ������� ��������������, 1 - �� �����.')
		return
	end
	X = math.ceil((X + 3000) / 250)
	Y = math.ceil((Y * - 1 + 3000) / 250)
	Y = KV[Y]
	kvx = (Y..'-'..X)
	cmd_r(localVars('others', 'ev', {
		['kv'] = kvx,
		['mesta'] = args[2]
	}))
end

function getTargetBlipCoordinatesFixed()
	local bool, x, y, z = getTargetBlipCoordinates(); if not bool then return false end
	requestCollision(x, y); loadScene(x, y, z)
	local bool, x, y, z = getTargetBlipCoordinates()
	return bool, x, y, z
end

function cmd_createpost(args)
	if #args == 0 then
		stext('�������: /createpost [������] [�������� �����]')
		return
	end
	local split = string.split(args, ' ', 2)
	local radius = split[1]
	args = split[2]
	if tonumber(radius) == nil then stext('�������� �������� �����!') return end
	local cx, cy, cz = getCharCoordinates(PLAYER_PED)
	for i = 1, #configPosts do
		local pi = configPosts[i]
		if args == pi.name then
			stext('������ ��� ����� ��� ������!')
			return
		end
		if cx >= pi.coordX - (pi.radius+radius) and cx <= pi.coordX + (pi.radius+radius) and cy >= pi.coordY - (pi.radius+radius) and cy <= pi.coordY + (pi.radius+radius) and cz >= pi.coordZ - (pi.radius+radius) and cz <= pi.coordZ + (pi.radius+radius) then
			stext(('���� �� ����� ���� ������, �.�. �� �������� � ������ \'%s\''):format(pi.name))
			return
		end
	end
	configPosts[#configPosts+1] = { name = args, coordX = cx, coordY = cy, coordZ = cz, radius = radius }
	saveData(config, paths.config)
	atext(('���� \'%s\' ������� ������. ��� ��������� ��������� � ���� (/arm - ������� - ���������� � ������)'):format(args))
end

function cmd_cn(args)
	if #args == 0 then 
		atext('�������: /cn [id] [0 - RP nick, 1 - NonRP nick]') 
		return 
	end
	args = string.split(args, ' ')
	if #args == 1 then
		cmd_cn(('%s 0'):format(args[1]))
	elseif #args == 2 then
		local getID = tonumber(args[1])
		if getID == nil then 
			stext('�������� ID ������!') 
			return 
		end
		if not sampIsPlayerConnected(getID) then 
			stext('����� �������!') 
			return 
		end 
		getID = sampGetPlayerNickname(getID)
		if tonumber(args[2]) == 1 then
			stext(('����� ��� {B40404}%s {FFFFFF}���������� � ����� ������.'):format(getID))
		else
			getID = string.gsub(getID, '_', ' ')
			stext(('�� ��� {B40404}%s {FFFFFF}���������� � ����� ������.'):format(getID))
		end
		setClipboardText(getID)
	else
		atext('�������: /cn [id] [0 - RP nick, 1 - NonRP nick]')
		return
	end 
end

function cmd_armytoolsupdates()
	local str = '{FFFFFF}���: {B40404}'..updatesInfo.type..'\n{FFFFFF}������ �������: {B40404}'..updatesInfo.version..'\n{FFFFFF}���� ������: {B40404}'..updatesInfo.date..'{FFFFFF}\n\n'
	for i = 1, #updatesInfo.list do
		str = str..'{B40404}-{FFFFFF}'
		for j = 1, #updatesInfo.list[i] do
			str = string.format('%s %s%s\n', str, j > 1 and ' ' or '', updatesInfo.list[i][j]:gsub('``(.-)``', '{B40404}%1{FFFFFF}'))
		end
	end
	sampShowDialog(61315125, '{B40404}Army-Tools | {FFFFFF}������ ����������', str, '�������', '', DIALOG_STYLE_MSGBOX)
end

function getKVNumber(param)
	local KV = {'�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�','�'}
	return table.getIndexOf(KV, rusUpper(param))
end

function table.getIndexOf(object, value)
	for k, v in pairs(object) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.removeByValue(object, value)
	local getIndexOf = table.getIndexOf(object, value)
	if getIndexOf then
		object[getIndexOf] = nil
	end
	return getIndexOf
end

function secoundTimer()
	lua_thread.create(function()
		updatecount = 0 
		while true do
			if tempConfig.workingDay == true then
				config.info.weekWorkOnline = config.info.weekWorkOnline + 1
				config.info.dayWorkOnline = config.info.dayWorkOnline + 1
			end
			config.info.dayOnline = config.info.dayOnline + 1
			config.info.weekOnline = config.info.weekOnline + 1
			config.info.dayAFK = config.info.dayAFK + (os.time() - tempConfig.updateAFK - 1)
			if updatecount >= 10 then 
				saveData(config, paths.config)
				updatecount = 0 
			end
			updatecount = updatecount + 1
			tempConfig.updateAFK = os.time()
			-- autodoklad
			if post.active == true and tempConfig.workingDay == true then
				local cx, cy, cz = getCharCoordinates(PLAYER_PED)
				for i = 1, #configPosts do
				  	local pi = configPosts[i]
				  	if cx >= pi.coordX - pi.radius and cx <= pi.coordX + pi.radius and cy >= pi.coordY - pi.radius and cy <= pi.coordY + pi.radius and cz >= pi.coordZ - pi.radius and cz <= pi.coordZ + pi.radius then
						if pi.name == '���' then addcounter(6, 1)
						else addcounter(5, 1) end
						if post.lastpost ~= i then
							punkeyActive = 3
							punkey[3].text = localVars('post', 'start', { ['post'] = pi.name })
							punkey[3].time = os.time()
							stext(('������� {139904}%s{FFFFFF} ��� ���������� �� ����������� �� ���� \'%s\''):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + '), pi.name))
							post.lastpost = i
						end
						if post.next >= post.interval then
					  		local count = 1
					  		for i = 0, 1001 do
								if sampIsPlayerConnected(i) then
						  			if sampGetFraktionBySkin(i) == 'Army' then
										local result, ped = sampGetCharHandleBySampPlayerId(i)
										if result then
							  				local px, py, pz = getCharCoordinates(ped)
							  				if px >= pi.coordX - pi.radius and px <= pi.coordX + pi.radius and py >= pi.coordY - pi.radius and py <= pi.coordY + pi.radius and pz >= pi.coordZ - pi.radius and pz <= pi.coordZ + pi.radius then
												count = count + 1
							  				end
										end
						  			end
								end
					  		end
							cmd_r(localVars('post', 'doklad', {
								['post'] = pi.name,
								['count'] = count
							}))
							post.next = 0
						end
						post.next = post.next + 1
						break
				  	elseif post.lastpost == i then
						punkeyActive = 3
						punkey[3].text = localVars('post', 'ends', { ['post'] = pi.name })
						punkey[3].time = os.time()
						stext(('������� {139904}%s{FFFFFF} ��� ���������� �� ����� � ����� \'%s\''):format(table.concat(rkeys.getKeysName(configKeys.punaccept.v), ' + '), pi.name))
						post.lastpost = 0
				  	end
				end      
			end
			wait(1000)
		end
	end)
end

function secToTime(sec)
  	local hour, minute, second = sec / 3600, math.floor(sec / 60), sec % 60
  	return string.format('%02d:%02d:%02d', math.floor(hour) ,  minute - (math.floor(hour) * 60), second)
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'� ' or '')..'%H:%M:%S', time + timezone_offset)
end

function dateToWeekNumber(date)
	local wsplit = string.split(date, '.')
	local day = tonumber(wsplit[1])
	local month = tonumber(wsplit[2])
	local year = tonumber(wsplit[3])
	local a = math.floor((14 - month) / 12)
	local y = year - a
	local m = month + 12 * a - 2
	return math.floor((day + y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + (31 * m) / 12) % 7)
end

function clearparams()
	data.functions.checkbox = {}
	data.functions.radius.v = 15
end

function onWindowMessage(msg, wparam, lparam)
	if imgui.Process then
		if msg == 0x100 or msg == 0x101 then
			if (wparam == vkeys.VK_ESCAPE and (window['shpora'].bool.v or window['binder'].bool.v or window['members'].bool.v or window['smslog'].bool.v or window['departmentlog'].bool.v or window['main'].bool.v or window['fastmenu'].bool.v or window['menuscript'].bool.v or window['fastmenuedit'].bool.v)) and not isPauseMenuActive()  then
				consumeWindowMessage(true, false)
				if msg == 0x101 then
					if window['shpora'].bool.v then 
						window['shpora'].bool.v = false
					elseif window['binder'].bool.v then 
						window['binder'].bool.v = false
						data.show = 6
					elseif window['members'].bool.v then window['members'].bool.v = false
					elseif window['smslog'].bool.v then window['smslog'].bool.v = false
					elseif window['departmentlog'].bool.v then window['departmentlog'].bool.v = false
					elseif window['menuscript'].bool.v then window['menuscript'].bool.v = false
					elseif window['fastmenu'].bool.v then window['fastmenu'].bool.v = false
					elseif window['fastmenuedit'].bool.v then 
						if binders.fast.select_item then binders.fast.select_item = nil
						elseif binders.fast.select then binders.fast.select = nil
						else window['fastmenuedit'].bool.v = false end
					elseif window['main'].bool.v then
						if data.show ~= 6 then
							data.show = 6
						else
							window['main'].bool.v = false
						end
					end
				end
			end
		end
	end
end

function rusUpper(string)
	local russian_characters = { [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�', }
	local strlen = string:len()
	if strlen == 0 then return string end
	string = string:upper()
	local output = ''
	for i = 1, strlen do
		local ch = string:byte(i)
		if ch >= 224 and ch <= 255 then
			output = output .. russian_characters[ch-32]
		elseif ch == 184 then
			output = output .. russian_characters[168]
		else
			output = output .. string.char(ch)
		end
	end
	return output
end

function screen()
	memory.setuint8(sampGetBase() + 0x119CBC, 1) 
end

function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() then 
		return false 
	end
end

function registerCommandsBinder()
	for k, v in pairs(configCommandBinder) do
		if sampIsChatCommandDefined(v.cmd) then 
			sampUnregisterChatCommand(v.cmd) 
		end
		sampRegisterChatCommand(v.cmd, function(args)
			thread = lua_thread.create(function()
				local params = string.split(args, ' ', v.params)
				local cmdtext = v.text
				local pause = v.pause
				local first_line = 0
				if #params < v.params then
					local paramtext = ''
					for i = 1, v.params do
						paramtext = paramtext .. '[��������'..i..'] '
					end
					atext(('�������: /%s %s'):format(v.cmd, paramtext))
					return
				else
					for line in cmdtext:gmatch('[^\r\n]+') do
						if first_line == 0 then 
							first_line = 1
						else
							wait(pause)
						end
						if line:match('^{wait%:%d+}$') then
							wait(math.abs(line:match('^%{wait%:(%d+)}$')-2*pause))
						elseif line:match('^{screen}$') then
							screen()
						else
							local bIsEnter = string.match(line, '^{noe}(.+)') ~= nil
							local bIsF6 = string.match(line, '^{f6}(.+)') ~= nil
							local keys = {
								['{location}'] = playerZone,
								['{targetrpnick}'] = sampGetPlayerNicknameForBinder(targetID):gsub('_', ' '),
								['{targetid}'] = targetID,
								['{naparnik}'] = naparnik(),
								['{rank}'] = ranknames[tempConfig.rank],
								['{frac}'] = tempConfig.fraction,
								['{post}'] = getPost(),
								['{screen}'] = '',
								['{f6}'] = '',
								['{noe}'] = '',
								['{myid}'] = tempConfig.myId,
								['{kv}'] = kvadrat(),
								['{myrpnick}'] = tempConfig.myNick:gsub('_', ' '),
								['{vehid}'] = tempConfig.VehicleId,
								['{mytag}'] = tag()
							}
							for i = 1, v.params do
								keys['{param:'..i..'}'] = params[i]
							end
							for k1, v1 in pairs(keys) do
								line = line:gsub(k1, v1)
							end
							if not bIsEnter then
								if bIsF6 then
									sampProcessChatInput(line)
								else
									sampSendChat(line)
								end
							else
								sampSetChatInputText(line)
								sampSetChatInputEnabled(true)
							end
						end
					end
				end
			end)
		end)
	end
end

function onHotKey(id, keys)
	lua_thread.create(function()
		local sKeys = tostring(table.concat(keys, ' '))
		for k, v in pairs(configButtonBinder) do
			if sKeys == tostring(table.concat(v.v, ' ')) then
				local tostr = tostring(v.text)
				local pause = v.pause
				local first_line = 0
				if tostr:len() > 0 then
					for line in tostr:gmatch('[^\r\n]+') do
						if first_line == 0 then 
							first_line = 1
						else
							wait(pause)
						end
						if line:match('^{wait%:%d+}$') then
							wait(math.abs(line:match('^%{wait%:(%d+)}$')-2*pause))
						elseif line:match('^{screen}$') then
							screen()
						else
							local bIsEnter = string.match(line, '^{noe}(.+)') ~= nil
							local bIsF6 = string.match(line, '^{f6}(.+)') ~= nil
							local keys = {
								['{location}'] = playerZone,
								['{targetrpnick}'] = sampGetPlayerNicknameForBinder(targetID):gsub('_', ' '),
								['{targetid}'] = targetID,
								['{naparnik}'] = naparnik(),
								['{rank}'] = ranknames[tempConfig.rank],
								['{frac}'] = tempConfig.fraction,
								['{post}'] = getPost(),
								['{screen}'] = '',
								['{f6}'] = '',
								['{noe}'] = '',
								['{myid}'] = tempConfig.myId,
								['{kv}'] = kvadrat(),
								['{myrpnick}'] = tempConfig.myNick:gsub('_', ' '),
								['{vehid}'] = tempConfig.VehicleId,
								['{mytag}'] = tag()
							}
							for k1, v1 in pairs(keys) do
								line = line:gsub(k1, v1)
							end
							if not bIsEnter then
								if bIsF6 then
									sampProcessChatInput(line)
								else
									sampSendChat(line)
								end
							else
								sampSetChatInputText(line)
								sampSetChatInputEnabled(true)
							end
						end
					end
				end
			end
		end
	end)
end

function sampGetFraktionBySkin(id)
	local t = '�����������'
	id = tonumber(id)
	if id ~= nil and sampIsPlayerConnected(id) then
		local result, ped = sampGetCharHandleBySampPlayerId(id)
		if result then
			local skin = getCharModel(ped)
			if skin == 102 or skin == 103 or skin == 104 or skin == 195 or skin == 21 then t = 'Ballas Gang' end
			if skin == 105 or skin == 106 or skin == 107 or skin == 269 or skin == 270 or skin == 271 or skin == 86 or skin == 149 or skin == 297 then t = 'Grove Gang' end
			if skin == 108 or skin == 109 or skin == 110 or skin == 190 or skin == 47 then t = 'Vagos Gang' end
			if skin == 114 or skin == 115 or skin == 116 or skin == 48 or skin == 44 or skin == 41 or skin == 292 then t = 'Aztec Gang' end
			if skin == 173 or skin == 174 or skin == 175 or skin == 193 or skin == 226 or skin == 30 or skin == 119 then t = 'Rifa Gang' end
			if skin == 73 or skin == 191 or skin == 252 or skin == 287 or skin == 61 or skin == 179 or skin == 255 then t = 'Army' end
			if skin == 57 or skin == 98 or skin == 147 or skin == 150 or skin == 187 or skin == 216 then t = 'Mayor' end
			if skin == 59 or skin == 172 or skin == 189 or skin == 240 then t = 'Instructors' end
			if skin == 201 or skin == 247 or skin == 248 or skin == 254 or skin == 248 or skin == 298 then t = 'Bikers' end
			if skin == 272 or skin == 112 or skin == 125 or skin == 214 or skin == 111  or skin == 126 then t = 'Russian Mafia' end
			if skin == 113 or skin == 124 or skin == 214 or skin == 223 then t = 'La Cosa Nostra' end
			if skin == 120 or skin == 123 or skin == 169 or skin == 186 then t = 'Yakuza' end
			if skin == 211 or skin == 217 or skin == 250 or skin == 261 then t = 'News' end
			if skin == 70 or skin == 219 or skin == 274 or skin == 275 or skin == 276 or skin == 70 then t = 'Medic' end
			if skin == 286 or skin == 141 or skin == 163 or skin == 164 or skin == 165 or skin == 166 then t = 'FBI' end
			if skin == 280 or skin == 265 or skin == 266 or skin == 267 or skin == 281 or skin == 282 or skin == 288 or skin == 284 or skin == 285 or skin == 304 or skin == 305 or skin == 306 or skin == 307 or skin == 309 or skin == 283 or skin == 303 then t = 'Police' end
		end
	end
	return t
 end

function naparnik()
    local v = {}
    for i = 0, sampGetMaxPlayerId(true) do
        if sampIsPlayerConnected(i) then
            local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
            if doesCharExist(ichar) then
                if isCharInAnyCar(PLAYER_PED) then
                    if isCharInAnyCar(ichar) then
                        local veh  = storeCarCharIsInNoSave(PLAYER_PED)
                        local iveh = storeCarCharIsInNoSave(ichar)
                        if veh == iveh then
                            if isInSuit(i) then
                                local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                                if inick and ifam then
                                    table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                                end
                            end
                        end
                    end
                else
                    local myposx, myposy, myposz = getCharCoordinates(PLAYER_PED)
                    local ix, iy, iz = getCharCoordinates(ichar)
                    if getDistanceBetweenCoords3d(myposx, myposy, myposz, ix, iy, iz) <= 100 then
                        if isInSuit(i) then
                            local inick, ifam = sampGetPlayerNickname(i):match('(.+)_(.+)')
                            if inick and ifam then
                                table.insert(v, string.format('%s.%s', inick:sub(1,1), ifam))
                            end
                        end
                    end
                end

            end
        end
    end
    if #v == 0 then
        return 'No unit.'
    elseif #v == 1 then
        return 'Unit: '..table.concat(v, ', ').. '.'
    elseif #v >=2 then
        return 'Unit\'s: '..table.concat(v, ', ').. '.'
    end
end

function isInSuit(i)
    if (sampGetFraktionBySkin(i) == '�������' or sampGetFraktionBySkin(i) == 'FBI') then return true end
    if sampGetFraktionBySkin(i) == '���������' then return true end
    if sampGetFraktionBySkin(i) == '������' then return true end
    if sampGetFraktionBySkin(i) == '�����' then return true end
    if sampGetFraktionBySkin(i) == 'Army' then return true end
    return false
end

function getZones(zone)
	local names = {
		['SUNMA'] = 'Bayside Marina',
		['SUNNN'] = 'Bayside',
		['BATTP'] = 'Battery Point',
		['PARA'] = 'Paradiso',
		['CIVI'] = 'Santa Flora',
		['BAYV'] = 'Palisades',
		['CITYS'] = 'City Hall',
		['OCEAF'] = 'Ocean Flats',
		['HASH'] = 'Hashbury',
		['JUNIHO'] = 'Juniper Hollow',
		['ESPN'] = 'Esplanade North',
		['FINA'] = 'Financial',
		['CALT'] = 'Calton Heights',
		['SFDWT'] = 'Downtown',
		['JUNIHI'] = 'Juniper Hill',
		['CHINA'] = 'Chinatown',
		['THEA'] = 'King\'s',
		['GARC'] = 'Garcia',
		['DOH'] = 'Doherty',
		['SFAIR'] = 'Easter Bay Airport',
		['EASB'] = 'Easter Basin',
		['ESPE'] = 'Esplanade East',
		['ANGPI'] = 'Angel Pine',
		['SHACA'] = 'Shady Cabin',
		['BACKO'] = 'Back o Beyond',
		['LEAFY'] = 'Leafy Hollow',
		['FLINTR'] = 'Flint Range',
		['HAUL'] = 'Fallen Tree',
		['FARM'] = 'The Farm',
		['ELQUE'] = 'El Quebrados',
		['ALDEA'] = 'Aldea Malvada',
		['DAM'] = 'The Sherman Dam',
		['BARRA'] = 'Las Barrancas',
		['CARSO'] = 'Fort Carson',
		['QUARY'] = 'Hunter Quarry',
		['OCTAN'] = 'Octane Springs',
		['PALMS'] = 'Green Palms',
		['TOM'] = 'Regular Tom',
		['BRUJA'] = 'Las Brujas',
		['MEAD'] = 'Verdant Meadows',
		['PAYAS'] = 'Las Payasadas',
		['ARCO'] = 'Arco del Oeste',
		['HANKY'] = 'Hankypanky Point',
		['PALO'] = 'Palomino Creek',
		['NROCK'] = 'North Rock',
		['MONT'] = 'Montgomery',
		['HBARNS'] = 'Hampton Barns',
		['FERN'] = 'Fern Ridge',
		['DILLI'] = 'Dillimore',
		['TOPFA'] = 'Hilltop Farm',
		['BLUEB'] = 'Blueberry',
		['PANOP'] = 'The Panopticon',
		['FRED'] = 'Frederick Bridge',
		['MAKO'] = 'The Mako Span',
		['BLUAC'] = 'Blueberry Acres',
		['MART'] = 'Martin Bridge',
		['FALLO'] = 'Fallow Bridge',
		['CREEK'] = 'Shady Creeks',
		['WESTP'] = 'Queens',
		['LA'] = 'Los Santos',
		['VE'] = 'Las Venturas',
		['BONE'] = 'Bone County',
		['ROBAD'] = 'Tierra Robada',
		['GANTB'] = 'Gant Bridge',
		['SF'] = 'San Fierro',
		['RED'] = 'Red County',
		['FLINTC'] = 'Flint County',
		['EBAY'] = 'Easter Bay Chemicals',
		['SILLY'] = 'Foster Valley',
		['WHET'] = 'Whetstone',
		['LAIR'] = 'Los Santos International',
		['BLUF'] = 'Verdant Bluffs',
		['ELCO'] = 'El Corona',
		['LIND'] = 'Willowfield',
		['MAR'] = 'Marina',
		['VERO'] = 'Verona Beach',
		['CONF'] = 'Conference Center',
		['COM'] = 'Commerce',
		['PER1'] = 'Pershing Square',
		['LMEX'] = 'Little Mexico',
		['IWD'] = 'Idlewood',
		['GLN'] = 'Glen Park',
		['JEF'] = 'Jefferson',
		['CHC'] = 'Las Colinas',
		['GAN'] = 'Ganton',
		['EBE'] = 'East Beach',
		['ELS'] = 'East Los Santos',
		['JEF'] = 'Jefferson',
		['LFL'] = 'Los Flores',
		['LDT'] = 'Downtown Los Santos',
		['MULINT'] = 'Mulholland Intersection',
		['MUL'] = 'Mulholland',
		['MKT'] = 'Market',
		['VIN'] = 'Vinewood',
		['SUN'] = 'Temple',
		['SMB'] = 'Santa Maria Beach',
		['ROD'] = 'Rodeo',
		['RIH'] = 'Richman',
		['STRIP'] = 'The Strip',
		['DRAG'] = 'The Four Dragons Casino',
		['PINK'] = 'The Pink Swan',
		['HIGH'] = 'The High Roller',
		['PIRA'] = 'Pirates in Men\'s Pants',
		['VISA'] = 'The Visage',
		['JTS'] = 'Julius Thruway South',
		['JTW'] = 'Julius Thruway West',
		['RSE'] = 'Rockshore East',
		['LOT'] = 'Come-A-Lot',
		['CAM'] = 'The Camel\'s Toe',
		['ROY'] = 'Royal Casino',
		['CALI'] = 'Caligula\'s Palace',
		['PILL'] = 'Pilgrim',
		['STAR'] = 'Starfish Casino',
		['ISLE'] = 'The Emerald Isle',
		['OVS'] = 'Old Venturas Strip',
		['KACC'] = 'K.A.C.C. Military Fuels',
		['CREE'] = 'Creek',
		['SRY'] = 'Sobell Rail Yards',
		['LST'] = 'Linden Station',
		['JTE'] = 'Julius Thruway East',
		['LDS'] = 'Linden Side',
		['JTN'] = 'Julius Thruway North',
		['HGP'] = 'Harry Gold Parkway',
		['REDE'] = 'Redsands East',
		['VAIR'] = 'Las Venturas Airport',
		['LVA'] = 'LVA Freight Depot',
		['BINT'] = 'Blackfield Intersection',
		['GGC'] = 'Greenglass College',
		['BFLD'] = 'Blackfield',
		['ROCE'] = 'Roca Escalante',
		['LDM'] = 'Last Dime Motel',
		['RSW'] = 'Rockshore West',
		['RIE'] = 'Randolph Industrial Estate',
		['BFC'] = 'Blackfield Chapel',
		['PINT'] = 'Pilson Intersection',
		['WWE'] = 'Whitewood Estates',
		['PRP'] = 'Prickle Pine',
		['SPIN'] = 'Spinybed',
		['SASO'] = 'San Andreas Sound',
		['FISH'] = 'Fisher\'s Lagoon',
		['GARV'] = 'Garver Bridge',
		['KINC'] = 'Kincaid Bridge',
		['LSINL'] = 'Los Santos Inlet',
		['SHERR'] = 'Sherman Reservoir',
		['FLINW'] = 'Flint Water',
		['ETUNN'] = 'Easter Tunnel',
		['BYTUN'] = 'Bayside Tunnel',
		['BIGE'] = 'The Big Ear',
		['PROBE'] = 'Lil\' Probe Inn',
		['VALLE'] = 'Valle Ocultado',
		['LINDEN'] = 'Linden Station',
		['UNITY'] = 'Unity Station',
		['MARKST'] = 'Market Station',
		['CRANB'] = 'Cranberry Station',
		['YELLOW'] = 'Yellow Bell Station',
		['SANB'] = 'San Fierro Bay',
		['ELCA'] = 'El Castillo del Diablo',
		['REST'] = 'Restricted Area',
		['MONINT'] = 'Montgomery Intersection',
		['ROBINT'] = 'Robada Intersection',
		['FLINTI'] = 'Flint Intersection',
		['SFAIR'] = 'Easter Bay Airport',
		['MKT'] = 'Market',
		['CUNTC'] = 'Avispa Country Club',
		['HILLP'] = 'Missionary Hill',
		['MTCHI'] = 'Mount Chiliad',
		['YBELL'] = 'Yellow Bell Golf Course',
		['VAIR'] = 'Las Venturas Airport',
		['LDOC'] = 'Ocean Docks',
		['STAR'] = 'Starfish Casino',
		['BEACO'] = 'Beacon Hill',
		['GARC'] = 'Garcia',
		['PLS'] = 'Playa del Seville',
		['STAR'] = 'Starfish Casino',
		['RING'] = 'The Clown\'s Pocket',
		['LIND'] = 'Willowfield',
		['WWE'] = 'Whitewood Estates',
		['LDT'] = 'Downtown Los Santos'
	}
	if names[zone] == nil then return '�� ����������' end
	return names[zone]
end

function getweaponname(weapon)
	local names = {
	[0] = 'Fist',
	[1] = 'Brass Knuckles',
	[2] = 'Golf Club',
	[3] = 'Nightstick',
	[4] = 'Knife',
	[5] = 'Baseball Bat',
	[6] = 'Shovel',
	[7] = 'Pool Cue',
	[8] = 'Katana',
	[9] = 'Chainsaw',
	[10] = 'Purple Dildo',
	[11] = 'Dildo',
	[12] = 'Vibrator',
	[13] = 'Silver Vibrator',
	[14] = 'Flowers',
	[15] = 'Cane',
	[16] = 'Grenade',
	[17] = 'Tear Gas',
	[18] = 'Molotov Cocktail',
	[22] = '9mm',
	[23] = 'Silenced 9mm',
	[24] = 'Desert Eagle',
	[25] = 'Shotgun',
	[26] = 'Sawnoff Shotgun',
	[27] = 'Combat Shotgun',
	[28] = 'Micro SMG/Uzi',
	[29] = 'MP5',
	[30] = 'AK-47',
	[31] = 'M4',
	[32] = 'Tec-9',
	[33] = 'Country Rifle',
	[34] = 'Sniper Rifle',
	[35] = 'RPG',
	[36] = 'HS Rocket',
	[37] = 'Flamethrower',
	[38] = 'Minigun',
	[39] = 'Satchel Charge',
	[40] = 'Detonator',
	[41] = 'Spraycan',
	[42] = 'Fire Extinguisher',
	[43] = 'Camera',
	[44] = 'Night Vis Goggles',
	[45] = 'Thermal Goggles',
	[46] = 'Parachute' }
	return names[weapon]
end

function kvadrat()
	local KV = {
		[1] = '�',
		[2] = '�',
		[3] = '�',
		[4] = '�',
		[5] = '�',
		[6] = '�',
		[7] = '�',
		[8] = '�',
		[9] = '�',
		[10] = '�',
		[11] = '�',
		[12] = '�',
		[13] = '�',
		[14] = '�',
		[15] = '�',
		[16] = '�',
		[17] = '�',
		[18] = '�',
		[19] = '�',
		[20] = '�',
		[21] = '�',
		[22] = '�',
		[23] = '�',
		[24] = '�',
	}
	local X, Y, Z = getCharCoordinates(playerPed)
	X = math.ceil((X + 3000) / 250)
	Y = math.ceil((Y * - 1 + 3000) / 250)
	Y = KV[Y]
	local KVX = (Y..'-'..X)
	return KVX
end

function saveData(table, path)
	if doesFileExist(path) then 
		os.remove(path) 
	end
    local file = io.open(path, 'w')
    if file then
		file:write(encodeJson(table))
		file:close()
  	end
end

function tag()
	local tag = {}
	if config.options.tagbool == true then
		table.insert(tag, string.format('%s:', config.options.tag))
	else
		table.insert(tag, string.format(''))
	end
	return table.concat(tag)
end

function httpRequest(request, body, handler)
	if not copas.running then
	  	copas.running = true
	  	lua_thread.create(function()
			wait(0)
			while not copas.finished() do
		  		local ok, err = copas.step(0)
		  		if ok == nil then error(err) end
		  		wait(0)
			end
			copas.running = false
	  	end)
	end
	if handler then
	  	return copas.addthread(function(r, b, h)
			copas.setErrorHandler(function(err) h(nil, err) end)
			h(http.request(r, b))
	  	end, request, body, handler)
	else
	  	local results
	  	local thread = copas.addthread(function(r, b)
			copas.setErrorHandler(function(err) results = {nil, err} end)
			results = table.pack(http.request(r, b))
	  	end, request, body)
	  	while coroutine.status(thread) ~= 'dead' do wait(0) end
	  	return table.unpack(results)
	end
end

function imgui.CentrText(text)
	local width = imgui.GetWindowWidth()
	local calc = imgui.CalcTextSize(text)
	imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	imgui.Text(text)
end

function imgui.TextQuestion(text)
	imgui.TextDisabled('(?)')
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos(450)
		imgui.TextUnformatted(text)
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end

function imgui.TextColoredRGB(text)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4
	local explode_argb = function(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end
	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end
	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else 
				imgui.Text(u8(w)) 
			end
		end
	end
	render_text(text)
end

function sampGetPlayerNicknameForBinder(nikkid)
    local nick = '-1'
    local nickid = tonumber(nikkid)
    if nickid ~= nil then
        if sampIsPlayerConnected(nickid) then
            nick = sampGetPlayerNickname(nickid)
        end
    end
    return nick
end

function applyCustomStyle()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
	
	style.ChildWindowRounding = 8.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 10.0
	style.FramePadding = ImVec2(5, 5)
	style.FrameRounding = 6.0
	style.ItemSpacing = ImVec2(12, 8)
	style.ItemInnerSpacing = ImVec2(8, 5)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 15.0
	style.GrabRounding = 7.0
	
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 0.43);
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 0.94);
    colors[clr.Border]                 = ImVec4(1.00, 1.00, 1.00, 0.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 0.00, 0.00, 0.32);
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.09);
    colors[clr.FrameBgHovered]         = ImVec4(1.00, 1.00, 1.00, 0.17);
    colors[clr.FrameBgActive]          = ImVec4(1.00, 1.00, 1.00, 0.26);
    colors[clr.TitleBg]                = ImVec4(0.19, 0.00, 0.00, 1.00);
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.00, 0.00, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.20, 0.00, 0.00, 1.00);
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.03, 0.03, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.19, 0.00, 0.00, 0.53);
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.11);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.24);
    colors[clr.ScrollbarGrabActive]    = ImVec4(1.00, 1.00, 1.00, 0.35);
	colors[clr.CloseButton]            = ImVec4(0.30, 0.00, 0.00, 0.50);
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00);
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.00, 0.00, 0.34);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.00, 0.00, 0.51);
    colors[clr.Button]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.00, 0.00, 0.31);
    colors[clr.ButtonActive]           = ImVec4(0.46, 0.00, 0.00, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.00, 0.00, 0.19);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.00, 0.00, 0.30);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.00, 0.00, 0.50);
    colors[clr.Separator]              = ImVec4(1.00, 0.00, 0.00, 0.41);
    colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.78);
    colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(0.19, 0.00, 0.00, 0.53);
    colors[clr.ResizeGripHovered]      = ImVec4(0.43, 0.00, 0.00, 0.75);
    colors[clr.ResizeGripActive]       = ImVec4(0.53, 0.00, 0.00, 0.95);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35);
end

function getPost()
    local posX, posY, posZ = getCharCoordinates(PLAYER_PED)
    if isCharInAnyCar(PLAYER_PED) then
        if getCarSpeed(storeCarCharIsInNoSave(PLAYER_PED)) < 1 then
            for k, v in pairs(getPosts) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[2], v[3], v[4])
                if dist <= 30 then
                    return v[1]
                end
            end
        else
            for k, v in pairs(getPosts) do
                local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[2], v[3], v[4])
                if dist <= 15 then
                    return v[1]
                end
            end
        end
    else
        for k, v in pairs(getPosts) do
            local dist = getDistanceBetweenCoords3d(posX, posY, posZ, v[2], v[3], v[4])
            if dist <= 30 then
                return v[1]
            end
        end
    end
    return '�� ����������'
end

function getcolorname(color)
	local colorlist = {
	  { name = '��������', color = 'FFFFFE'}, -- 0
	  { name = '������', color = '089401'}, -- 1
	  { name = '������ ������', color = '56FB4E'}, -- 2
	  { name = '���� ������', color = '49E789'}, -- 3
	  { name = '���������', color = '2A9170'}, -- 4
	  { name = 'Ƹ���-�������', color = '9ED201'}, -- 5
	  { name = 'Ҹ���-�������', color = '279B1E'}, -- 6
	  { name = '����-������', color = '51964D'}, -- 7
	  { name = '�������', color = 'FF0606'}, -- 8
	  { name = '����-�������', color = 'FF6600'}, -- 9
	  { name = '���������', color = 'F45000'}, -- 10
	  { name = '����������', color = 'BE8A01'}, -- 11
	  { name = 'Ҹ���-�������', color = 'B30000'}, -- 12
	  { name = '����-�������', color = '954F4F'}, -- 13
	  { name = 'Ƹ���-���������', color = 'E7961D'}, -- 14
	  { name = '���������', color = 'E6284E'}, -- 15
	  { name = '�������', color = 'FF9DB6'}, -- 16
	  { name = '�����', color = '110CE7'}, -- 17
	  { name = '�������', color = '0CD7E7'}, -- 18
	  { name = '����� �����', color = '139BEC'}, -- 19
	  { name = '����-������', color = '2C9197'}, -- 20
	  { name = 'Ҹ���-�����', color = '114D71'}, -- 21
	  { name = '����������', color = '8813E7'}, -- 22
	  { name = '������', color = 'B313E7'}, -- 23
	  { name = '����-�����', color = '758C9D'}, -- 24
	  { name = 'Ƹ����', color = 'FFDE24'}, -- 25
	  { name = '����������', color = 'FFEE8A'}, -- 26
	  { name = '�������', color = 'DDB201'}, -- 27
	  { name = '������ ������', color = 'DDA701'}, -- 28
	  { name = '���������', color = 'B0B000'}, -- 29
	  { name = '�����', color = '868484'}, -- 30
	  { name = '�������', color = 'B8B6B6'}, -- 31
	  { name = '׸����', color = '333333'}, -- 32
	  { name = '�����', color = 'FAFAFA'}, -- 33
	}
	for i = 1, #colorlist do
		if color == colorlist[i].color then
			local cid = i - 1 -- ����� ���������� � 0, � ������ � 1
			return string.format('{'..color..'}'..colorlist[i].name..'['..cid..']{FFFFFF}')
		end
	end
	return string.format('{%s}[|||]{FFFFFF}', color)
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

function argb_to_rgba(argb)
	local a, r, g, b = explode_argb(argb)
	return join_argb(r, g, b, a)
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8))
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function patch_samp_time_set(enable)
	if enable and default == nil then
		default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
		writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
	elseif enable == false and default ~= nil then
		writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
		default = nil
	end
end

function string.split(str, delim, plain)
	local tokens, pos, plain = {}, 1, not (plain == false)
	repeat
		local npos, epos = string.find(str, delim, pos, plain)
		table.insert(tokens, string.sub(str, pos, npos and npos - 1))
		pos = epos and epos + 1
	until not pos
	return tokens
end

function split(inputstr, sep)
	if sep == nil then
		sep = '%s'
	end
	local t = {}; i = 1
	for str in string.gmatch(inputstr, '([^'..sep..']+)') do
		t[i] = str
		i = i + 1
	end
	return t
end

function onScriptTerminate(LuaScript, quitGame)
	if LuaScript == thisScript() then
		showCursor(false)
		lua_thread.create(function()
			print('������ ����������. ��������� ���������.')
			if config.info.dayOnline then
				config.info.dayOnline = config.info.dayOnline
				saveData(config, paths.config)
			end
		end)
 	end
end

function onQuitGame()
	saveData(config, paths.config)
	thisScript():unload()
end

function stext(text)
    sampAddChatMessage((' %s {FFFFFF}%s'):format(script.this.name, text), 0xB40404)
end

function atext(text)
	sampAddChatMessage((' � {FFFFFF}%s'):format(text), 0xB40404)
end
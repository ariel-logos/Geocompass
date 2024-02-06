addon.name      = 'GeoCompass';
addon.author    = 'Arielfy';
addon.version   = '0.2';
addon.desc      = 'GEO compass for CatsEye Cardinal Chant';
addon.link      = '';


require('common');
local imgui = require('imgui');
local settings = require('settings');
local ffi = require('ffi');
local d3d       = require('d3d8');
local C         = ffi.C;
local d3d8dev   = d3d.get_device();

local signatureCompass;
local signatureOffset = 0x0;

local lookR = 100;
local lookA = 0;

local nextAngle = math.pi*1/8;
local prevAngle = -math.pi*1/8;

local compassOff;
local compassDark;
local compassLight;
local compassIce;
local compassWind;
local compassEarth;
local compassLightning;
local compassWater;
local compassFire;

local markerTexture;
local tokenTexture;

local currentCfg;

local cfg = T{

	isSettingsOn = T{false},
	showLocked = T{true},
	showGEO = T{true},
	disableBell = T{false},
	disableNeedle = T{false},
	disableToken = T{false},
	onlyLockMobs = T{true},
	scale = 1
}

local function save_settings()
    settings.save('cfg');
end

ashita.events.register('d3d_present', 'present_cb', function()

	local playerTarget = AshitaCore:GetMemoryManager():GetTarget();
	local targetIndex;
	local targetEntity;
	local targetIsMob = false;
	if (playerTarget ~= nil) then
		local targetIndex = playerTarget:GetTargetIndex(0);
		targetEntity = GetEntity(targetIndex);
	end

	if (targetEntity ~= nil) then
		if (bit.band(targetEntity.SpawnFlags, 0x10) ~= 0) then
			targetIsMob = true;
		end
	end
	
	local playerEntity = GetPlayerEntity();
	
	local playerDir = 0;
	if (playerEntity ~= nil) then
		playerDir = playerEntity.Heading;
		lookA = playerDir+math.pi/2;
	end
	
	local textureAngle = playerDir+math.pi+math.pi*1/3-1;
	
	local player = AshitaCore:GetMemoryManager():GetPlayer();
	local playerJob = player:GetMainJob();
	--imgui.Text(tostring(playerJob));
	
	--imgui.Text(tostring(bit.tohex(signatureOffset)));
	
	local compassTestPointer = ashita.memory.read_uint32(signatureCompass-0x04);
	--imgui.Text('compassTestPointer:'..tostring(bit.tohex(compassTestPointer))); 
	
	--compassPointer = compassPointer + 0x5C;

	local compassPointer = ashita.memory.read_uint32(compassTestPointer);
	--imgui.Text('compassPointer:'..tostring(bit.tohex(compassPointer)));--20bc3e60
	
	local compassPointerAdjusted = ashita.memory.read_uint8(compassPointer+0x5C);
	
	local compassLastBit = bit.band(compassPointerAdjusted, 0x00000001);
	--imgui.Text('compassPointer:'..tostring(tostring(bit.tohex(compassLastBit))));
	
	local isLockedOn = false;
	if (compassLastBit == 0x00000001) then isLockedOn = true; end
	

	local windowW = 500*currentCfg.scale;
	local windowH = 500*currentCfg.scale;
	
	local geoCheck = not currentCfg.showGEO[1] or playerJob == 21;
	local lockedCheck = not currentCfg.showLocked[1] or isLockedOn;
	local mobCheck = lockedCheck and (not currentCfg.onlyLockMobs[1] or targetIsMob);
	local isVisible = lockedCheck and geoCheck and mobCheck;
	
	
	if(isVisible) then
		imgui.SetNextWindowSize({ windowW, windowH, });
		imgui.SetNextWindowSizeConstraints({  windowW, windowH, }, { FLT_MAX, FLT_MAX, });
		local windowFlags = bit.bor(ImGuiWindowFlags_NoDecoration, ImGuiWindowFlags_NoResize ,ImGuiWindowFlags_NoBackground, ImGuiWindowFlags_NoBringToFrontOnFocus, ImGuiWindowFlags_NoFocusOnAppearing);
		imgui.Begin('GeoCompass', isVisible, windowFlags);
	
	
		local positionStartX, positionStartY = imgui.GetCursorScreenPos();
		local centerPosX = windowW/2 + positionStartX;
		local centerPosY = windowH/2 + positionStartY;
	
		local imageSize = windowH*2/5;
	
		lookR = imageSize*9/10; 
	
		local targetX = LA2XY(lookR, lookA)[1];
		local targetY = LA2XY(lookR, lookA)[2];
	
		lookR = imageSize*6/10; 
	
		local targetX1 = LA2XY(lookR, lookA)[1];
		local targetY1 = LA2XY(lookR, lookA)[2];
	
		lookR = imageSize*7/10;
		local targetX3 = LA2XY(lookR, lookA+nextAngle)[1];
		local targetY3 = LA2XY(lookR, lookA+nextAngle)[2];
	
		local targetX2 = LA2XY(lookR, lookA+prevAngle)[1];
		local targetY2 = LA2XY(lookR, lookA+prevAngle)[2];
	
		lookR = imageSize*4.7/10; 
	
		local targetX4 = LA2XY(lookR, lookA)[1];
		local targetY4 = LA2XY(lookR, lookA)[2];
	
		lookR = imageSize*5.7/10;
		local targetX6 = LA2XY(lookR, lookA+nextAngle)[1];
		local targetY6 = LA2XY(lookR, lookA+nextAngle)[2];
	
		local targetX5 = LA2XY(lookR, lookA+prevAngle)[1];
		local targetY5 = LA2XY(lookR, lookA+prevAngle)[2];
	

	--Needle
		if (not currentCfg.disableNeedle[1]) then
			imgui.GetWindowDrawList():AddTriangleFilled({centerPosX+targetX1,centerPosY+targetY1},{centerPosX-targetX2,centerPosY-targetY2},{centerPosX-targetX3,centerPosY-targetY3}, imgui.GetColorU32({ 0.0, 0.0, 0.0, 1.0 }));
	
			imgui.GetWindowDrawList():AddTriangleFilled({centerPosX+targetX4,centerPosY+targetY4},{centerPosX-targetX5,centerPosY-targetY5},{centerPosX-targetX6,centerPosY-targetY6}, imgui.GetColorU32({ 0.8, 0.8, 0.8, 1.0 }));
		end
	
	
		local textureID = tonumber(ffi.cast("uint32_t", compassOff));
	
	--Water
		if(textureAngle >= math.pi*2*15/16 or textureAngle < math.pi*2*1/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassWater));
		end
	--Fire
		if(textureAngle >= math.pi*2*1/16 and textureAngle < math.pi*2*3/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassFire));
		end
	--Dark
		if(textureAngle >= math.pi*2*3/16 and textureAngle < math.pi*2*5/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassDark));
		end
	--Light
		if(textureAngle >= math.pi*2*5/16 and textureAngle < math.pi*2*7/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassLight));
		end
	--Ice
		if(textureAngle >= math.pi*2*7/16 and textureAngle < math.pi*2*9/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassIce));
		end
	--Wind
		if(textureAngle >= math.pi*2*9/16 and textureAngle < math.pi*2*11/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassWind));
		end
	--Earth
		if(textureAngle >= math.pi*2*11/16 and textureAngle < math.pi*2*13/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassEarth));
		end
	--Lightning
		if(textureAngle >= math.pi*2*13/16 and textureAngle < math.pi*2*15/16) then
			textureID = tonumber(ffi.cast("uint32_t", compassLightning));
		end
	
	
		if (textureID ~= nil) then
			imgui.GetWindowDrawList():AddImage(textureID, {centerPosX-imageSize, centerPosY-imageSize}, {centerPosX+imageSize, centerPosY+imageSize}, {0,0}, {1,1}, imgui.GetColorU32({ 1.0, 1.0, 1.0, 1.0 }));
		end
	--Bell
		if(not currentCfg.disableBell[1]) then
			local markerSize = 25*currentCfg.scale;
			if (markerTexture ~= nil) then
				imgui.GetWindowDrawList():AddImage(tonumber(ffi.cast("uint32_t", markerTexture)), {centerPosX+targetX-markerSize, centerPosY+targetY-markerSize}, {centerPosX+targetX+markerSize, centerPosY+targetY+markerSize}, {0,0}, {1,1}, imgui.GetColorU32({ 1.0, 1.0, 1.0, 1.0 }));
			end
		end
	--Token
		if(not currentCfg.disableToken[1]) then
			local tokenSize = 70*currentCfg.scale;
			if (markerTexture ~= nil) then
				imgui.GetWindowDrawList():AddImage(tonumber(ffi.cast("uint32_t", tokenTexture)), {centerPosX-targetX1/4.5-tokenSize, centerPosY-targetY1/4.5-tokenSize}, {centerPosX-targetX1/4.5+tokenSize, centerPosY-targetY1/4.5+tokenSize}, {0,0}, {1,1}, imgui.GetColorU32({ 1.0, 1.0, 1.0, 1.0 }));
			end
		end
	
	--imgui.GetWindowDrawList():AddRectFilled({targetX-, targetY-markerSize}, {targetX+markerSize, targetY+markerSize},imgui.GetColorU32({ 1.0, 1.0, 1.0, 1.0 }),0,ImDrawCornerFlags_All);
		imgui.End();
	end
	if (currentCfg.isSettingsOn[1]) then
		imgui.SetNextWindowSize({ 380, 260, });
		imgui.SetNextWindowSizeConstraints({ 380, 260, }, { FLT_MAX, FLT_MAX, });
		imgui.Begin('Geocompass Settings', currentCfg.isSettingsOn, ImGuiWindowFlags_NoResize);
		
		local S = T{currentCfg.scale};
		imgui.Text('Compass scale');
		if (imgui.SliderFloat(' ', S, 0.5, 2, '%0.1f')) then
			currentCfg.scale = S[1];
			save_settings();
		end
		if (imgui.Checkbox('Disable bell icon',{currentCfg.disableBell[1]})) then 
			currentCfg.disableBell[1] = not currentCfg.disableBell[1];
			save_settings();
		end
		if (imgui.Checkbox('Disable compass needle',{currentCfg.disableNeedle[1]})) then 
			currentCfg.disableNeedle[1] = not currentCfg.disableNeedle[1];
			save_settings();
		end
		if (imgui.Checkbox('Disable central token',{currentCfg.disableToken[1]})) then 
			currentCfg.disableToken[1] = not currentCfg.disableToken[1];
			save_settings();
		end
		if (imgui.Checkbox('Enable only on GEO job',{currentCfg.showGEO[1]})) then 
			currentCfg.showGEO[1] = not currentCfg.showGEO[1];
			save_settings();
		end
		if (imgui.Checkbox('Show only when target is locked on',{currentCfg.showLocked[1]})) then 
			currentCfg.showLocked[1] = not currentCfg.showLocked[1];
			save_settings();
		end
		if (currentCfg.showLocked[1]) then
			imgui.Text(' L');
			imgui.SameLine();
			if (imgui.Checkbox('Only apply on mobs',{currentCfg.onlyLockMobs[1]})) then 
				currentCfg.onlyLockMobs[1] = not currentCfg.onlyLockMobs[1];
				save_settings();
			end
		end
		
			--imgui.SameLine();
			
	end
	imgui.End();
end);

function LA2XY(r, a)

	local x;
	local y;
	
	x = r * math.cos(a-math.pi/2);
	y = r * math.sin(a-math.pi/2);
	
	return {x,y};

end


ffi.cdef[[
    // Exported from Addons.dll
    HRESULT __stdcall D3DXCreateTextureFromFileA(IDirect3DDevice8* pDevice, const char* pSrcFile, IDirect3DTexture8** ppTexture);
]];

local function loadTexture(name)
	local textureID;
    local texture_ptr = ffi.new('IDirect3DTexture8*[1]');
    local res = C.D3DXCreateTextureFromFileA(d3d8dev, string.format('%s/images/%s.png', addon.path, name), texture_ptr);
    if (res ~= C.S_OK) then
        error(('Failed to load image texture: %08X (%s)'):fmt(res, d3d.get_error(res)));
    end;
    textureID = ffi.new('IDirect3DTexture8*', texture_ptr[0]);
    d3d.gc_safe_release(textureID);
	return textureID;
end

ashita.events.register('load', 'load_cb', function ()

	currentCfg = settings.load(cfg, 'cfg');
	--ui.customFont = imgui.AddFontFromFileTTF(addon.path..'/fonts/CarroisGothicSC-Regular.ttf',30);
	--ui.customFont2 = imgui.AddFontFromFileTTF(addon.path..'/fonts/calibri.ttf',30);
	
	compassOff = loadTexture('compassOff');
	compassDark = loadTexture('compassDark');
	compassLight = loadTexture('compassLight');
	compassIce = loadTexture('compassIce');
	compassWind = loadTexture('compassWind');
	compassEarth = loadTexture('compassEarth');
	compassLightning = loadTexture('compassLightning');
	compassWater = loadTexture('compassWater');
	compassFire = loadTexture('compassFire');
	markerTexture = loadTexture('marker');
	tokenTexture = loadTexture('token');
	--E8????????83C4??8B15????????F642
	--F642????74??0FBF46ffximain.dll+14E150 - F6 42 5C 03           - test byte ptr [edx+5C],03

	signatureCompass = ashita.memory.find('FFXiMain.dll', 0, 'F6425C03??????', 0 , 0);
end);

settings.register('cfg', 'cfg_update', function(s)
    if s ~= nil then currentCfg = s end
    settings.save('cfg');
end)

ashita.events.register('unload', 'unload_cb', function ()
    save_settings();
end);

ashita.events.register('command', 'command_cb', function (e)

    local args = e.command:args();
    if (#args == 0 or not args[1]:any('/geocompass')) then
        return;
    end

    e.blocked = true;

	if (#args == 2 and args[2]:any('settings') )then
		currentCfg.isSettingsOn[1] = not currentCfg.isSettingsOn[1];
	end
   
	return;
end);
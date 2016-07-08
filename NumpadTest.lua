--=======================================================

-- Must run this before drawing
function startDraw()
	Screen.waitVblankStart()
	Screen.refresh()
end

-- Must run after drawing
function endDraw()
	Screen.flip()
end

-- Clears top and bottom screens.
function clearScreens()
	Screen.clear(TOP_SCREEN);
	Screen.clear(BOTTOM_SCREEN);
end

-- Sets pad to the current controls. Sets oldPad to old pad.
function getControls()
	oldPad=pad;
	pad = Controls.read();
	circlePadX, circlePadY = Controls.readCirclePad();
end

-- Returns true if a button was just pressed according to pad and oldPad. _toCheck is the button to check. Returns false otherwise.
function isJustPressed(_toCheck)
	if (Controls.check(oldPad,_toCheck)==false) then
		if (Controls.check(pad,_toCheck)) then
			return true;
		end
	end
	return false;
end

-- ===============================================================

local tchX=0;
local tchY=0;
-- What you inputed with the numpad. Needs to be converted to number.
local numpadInput="";
local numpadMessage="Please enter the speed you want.";
local numpadActive=true;

function getTouch()
	tchX,tchY = Controls.readTouch()
end

function checkNumpadTouch()
	if (tchY<=60) then
		if (tchX<=106) then
			numpadInput = (numpadInput .. "7");
		elseif (tchX<=212) then
			numpadInput = (numpadInput .. "8");
		else
			numpadInput = (numpadInput .. "9");
		end
	elseif (tchY<=120) then
		if (tchX<=106) then
			numpadInput = (numpadInput .. "4");
		elseif (tchX<=212) then
			numpadInput = (numpadInput .. "5");
		else
			numpadInput = (numpadInput .. "6");
		end
	elseif (tchY<=180) then
		if (tchX<=106) then
			numpadInput = (numpadInput .. "1");
		elseif (tchX<=212) then
			numpadInput = (numpadInput .. "2");
		else
			numpadInput = (numpadInput .. "3");
		end
	elseif (tchY<=240) then
		if (tchX<=106) then
			numpadActive=false;
		elseif (tchX<=212) then
			numpadInput = (numpadInput .. "0");
		else
			numpadInput = string.sub(numpadInput,1,#numpadInput-1)
		end
	end

end

function drawNumpad()
	-- Each segment is 106 x 60
	Screen.debugPrint(45, 25, "7", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(151, 25, "8", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(257, 25, "9", Color.new(255,255,255), BOTTOM_SCREEN)
	--===
	Screen.debugPrint(45, 85, "4", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(151, 85, "5", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(257, 85, "6", Color.new(255,255,255), BOTTOM_SCREEN)
	--===
	Screen.debugPrint(45, 145, "1", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(151, 145, "2", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(257, 145, "3", Color.new(255,255,255), BOTTOM_SCREEN)
	--====
	Screen.debugPrint(45, 205, "DONE", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(151, 205, "0", Color.new(255,255,255), BOTTOM_SCREEN)
	Screen.debugPrint(257, 205, "<-", Color.new(255,255,255), BOTTOM_SCREEN)
end

getControls();
getControls();

while (numpadActive) do
startDraw();
clearScreens();
Screen.debugPrint(0, 0, numpadMessage, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32, numpadInput, Color.new(255,255,255), TOP_SCREEN)

drawNumpad()
getControls();
getTouch();

if (isJustPressed(KEY_TOUCH)) then
	checkNumpadTouch();
end

endDraw();
end
-- Support for PS Vita


KEY_A = SCE_CTRL_CROSS;
KEY_B = SCE_CTRL_CIRCLE;
KEY_X = SCE_CTRL_TRIANGLE
KEY_Y = SCE_CTRL_SQUARE
KEY_ZL = SCE_CTRL_VOLUP
KEY_ZR = SCE_CTRL_VOLUP
KEY_R = SCE_CTRL_RTRIGGER
KEY_L = SCE_CTRL_LTRIGGER
KEY_DDOWN = SCE_CTRL_DOWN
KEY_DUP = SCE_CTRL_UP
KEY_DLEFT = SCE_CTRL_LEFT
KEY_DRIGHT = SCE_CTRL_RIGHT
KEY_TOUCH = SCE_CTRL_VOLUP
KEY_START = SCE_CTRL_START
KEY_POWER = SCE_CTRL_SELECT

function myEmptyFunction()
end

function System.setCpuSpeed()
end

oldClearScreens = Screen.clear;
function GoodClearScreens()
	oldClearScreens();
end

oldScreenFlip = Screen.flip;
function GoodFlipScreens()
	Graphics.termBlend()
	oldScreenFlip();
end

function Controls.readCirclePad()
	return 0,0
end

oldDebugPrint = Graphics.debugPrint;
function GoodDebugPrintA(x,y,text,color,scale)
	if (scale == TOP_SCREEN) then
		oldDebugPrint(x,y,text,color,1);
	end
end
function GoodDebugPrintB(x,y,text,color,scale)
	if (scale == BOTTOM_SCREEN) then
		oldDebugPrint(x,y,text,color,1);
	end
end

function GoodWriteFile(handle, position, text, len)
	System.seekFile(handle, position, SET)
	System.writeFile(handle, text, len)
end

function GoodReadFile(handle, position, len)
	System.seekFile(handle, position, SET)
	return System.readFile(handle, len)
end

oldDrawPartialImage = Graphics.drawPartialImage;
--Screen.drawPartialImage(0,0,currentX,currentY,400,240,currentPageImage,TOP_SCREEN)
--Graphics.drawPartialImage (number x, number y, int img, int x_start, int y_start, number width, number height, int color)
function Graphics.drawPartialImage( x, y, image_x, image_y, width, height, image, screen_id, eye)
	oldDrawPartialImage(x,y,image,image_x,image_y,width,height)
end

io.open = System.openFile;
io.write = GoodWriteFile;
io.close = System.closeFile;
io.read = GoodReadFile;

Graphics.debugPrint = GoodDebugPrintA;

System.getModel = function() return 2 end


System.startKeyboard = myEmptyFunction;

Graphics.refresh = Graphics.initBlend;

TOP_SCREEN = 1;
BOTTOM_SCREEN = 2;

Graphics.clear = GoodClearScreens; -- 3ds version includes an argument. We don't want this.
Graphics.flip = GoodFlipScreens;
Graphics.waitVblankStart = Screen.waitVblankStart;
Screen = Graphics;
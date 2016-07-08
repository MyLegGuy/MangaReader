-- Good line.
System.setCpuSpeed(NEW_3DS_CLOCK)
-- =======================
-- READING VARS
-- =======================
-- Your current menu/place
--	0 = mainRead
--	1 = titleScreen
--	2 = fileSelector
--	3 = download
--	4 = options
local currentPlace=1;
-- Current page to be displaying
local currentPageImage;
-- Current path pages are in
local currentPath = "/NewReader/";
-- Current page being displayed;
local currentPage=1;
-- X position in imaage we're at.
local currentX=0;
-- Y position in image we're at.
local currentY=0;

--    ======================
--    PAGE SPECIFIC SETTINGS
--    (These are changed every time a page is loaded)
--    ======================
-- A variable to tell how the page is drawn.
--	0 = Normal
--  1 = Just drawn at the top left. No vertical scroll. No horizontal scroll.
--  2 = No vetical scrolling, only horizontal.
--  3 = No horiontal scrolling. Vertical only.
local currentDrawPageMode=0;
-- The current page's width
local currentPageWidth;
-- The current page's height
local currentPageHeight;

--      =======================
--      READING OPTION VARS
--      =======================
-- How many pixels the page moves per second
local moveSpeed=10;
-- Where you start on the next page.
	-- True is for the top right, false is for the top left.
local returnPlace=true;
-- The current image format for the current manga
local currentImageFormat="happu!";
-- Current image name prefix.
local currentPrefix="angry!";
-- True if the bottom part of the page should be drawn.
local drawBottom=true;
-- Number of pixels the image moves per frame.
local moveSpeed=15;
-- Bottom bar is on?
local bottomBarEnabled=false;
-- ======================
-- GENERIC VARS
-- ======================
-- White
local colorWhite = Color.new(255,255,255);
-- Green
local colorGreen = Color.new(0,255,255);
-- Commonly reused variable for the current buttons pressed.
local pad;
-- Commonly reused variable for the buttons pressed the last frame
local oldPad;
-- Circle pad y
local circlePadY;
-- Circle pad x
local circlePadX;
-- Touch x
local tchX=0;
-- Touch y
local tchY=0;
-- is new 3ds?
local isNew3ds;
-- ======================
-- Options
--	Things the user can change in the options.
-- ======================

-- =======================
-- DEBUG
-- =======================
debugMode=false;
if (debugMode) then
	fpsTimer = Timer.new();
	frames=0;
	lastFps=0;
end


-- /////////////////////////////////////////////////////////////////////////////////////
-- Real stuff incoming...
-- /////////////////////////////////////////////////////////////////////////////////////

-- Saves the options file with the globla options variables
function saveOptions()
	local _fileStream;
	local _optionsToWrite;

	_optionsToWrite = (moveSpeed .. "," .. tostring(returnPlace))

	_fileStream = io.open("/MangaReader-cfg",FCREATE);
	io.write(_fileStream,0,forceTripleDigitNumber(#_optionsToWrite), 3);
	io.write(_fileStream,3,_optionsToWrite,#_optionsToWrite);
	io.close(_fileStream);

	_fileStream=nil;
	_optionFileLength=nil;
end

-- Loads the options files and sets the vaules
function loadOptions()
	if (System.doesFileExist("/MangaReader-cfg")==false) then
		return;
	end
	
	local fileStream;
	local _optionFileLength;
	local _loadedString;
	fileStream = io.open("/MangaReader-cfg",FREAD);
	_optionFileLength = tonumber(io.read(fileStream,0,3));
	_loadedString = io.read(fileStream,3,_optionFileLength);
	io.close(fileStream);
	fileStream=nil;
	_optionFileLength=nil;

	local _loadedValues = {};

	--string = "cat,dog"
	_loadedValues[1], _loadedValues[2] = _loadedString:match("([^,]+),([^,]+)")

	if (_loadedValues[1]==nil) then
		System.deleteFile("/MangaReader-cfg");
	end

	moveSpeed=tonumber(_loadedValues[1]);
	if (_loadedValues[2]=="true") then
		returnPlace=true;
	else
		returnPlace=false;
	end

	_loadedValues=nil;
	_loadedString=nil;
end

-- Sets touch position variables.
function getTouch()
	tchX,tchY = Controls.readTouch()
end

-- Waits a number of miliseconds
function wait(amount)
	_tempTimer = Timer.new();
	while (Timer.getTime(_tempTimer)<=amount) do
	end
	Timer.destroy(_tempTimer);
end

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

-- Returns true if a button is pressed according to pad variable. _toCheck is button to check. Returns false otherwise.
function isPressed(_toCheck)
	if (Controls.check(pad,_toCheck)) then
		return true;
	end
	return false;
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

-- Takes the input number and returns it as a double number string
function forceDoubleDigitNumber(_num)
	if (_num<10) then
		return ("0".. _num);
	end
	return tostring(_num);
end

-- Takes the input number and returns it as a triple number string
function forceTripleDigitNumber(_num)
	if (_num<10) then
		return ("00" .. _num);
	elseif (_num<100) then
		return ("0" .. _num)
	end
	return _num;
end

-- ============================================
-- MAIN READ
-- =============================================

-- Main reading section
function mainRead()
	getControls();
	startDraw();
	clearScreens();
	getMoveInputs();
	drawPage();
	if (debugMode) then
		Screen.debugPrint(0, 0, tostring(lastFps), colorWhite, BOTTOM_SCREEN)
		Screen.debugPrint(0, 16, tostring(currentDrawPageMode), colorWhite, BOTTOM_SCREEN)
	end
	if (bottomBarEnabled) then
		drawBottomBar();
	end
	endDraw();
	getPageChangeInputs();
	if (debugMode) then
		frames=frames+1;
		if (Timer.getTime(fpsTimer)>=1000) then
			Timer.reset(fpsTimer);
			lastFps=frames;
			frames=0;
		end
	end
end

-- Handles the controls for mainRead.
function getMoveInputs()
	if (currentDrawPageMode==0 or currentDrawPageMode==2) then
		if (isPressed(KEY_DRIGHT) or circlePadX>20) then
			if (currentX+moveSpeed+400>currentPageWidth) then
				currentX=currentPageWidth-400;
			else
				currentX=currentX+moveSpeed;
			end
		elseif (isPressed(KEY_DLEFT) or circlePadX<-20) then
			if (currentX-moveSpeed<0) then
				currentX=0;
			else
				currentX=currentX-moveSpeed;
			end
		end
	end

	if (currentDrawPageMode==0 or currentDrawPageMode==3) then
		if (isPressed(KEY_DDOWN) or circlePadY<-20) then
			if (currentY+moveSpeed+240>currentPageHeight) then
				currentY=currentPageHeight-240;
			else
				currentY=currentY+moveSpeed;
			end
		elseif (isPressed(KEY_DUP) or circlePadY>20) then
			if (currentY-moveSpeed<0) then
				currentY=0;
			else
				currentY=currentY-moveSpeed;
			end
		end
	end

	if (isJustPressed(KEY_X)) then
		if (bottomBarEnabled==false) then
			bottomBarEnabled=true;
		else
			bottomBarEnabled=false;
		end
	end

end

function drawBottomBar()

	h,m,s = System.getTime()
	Screen.fillRect(0, 320, 214, 239, Color.new(0,155,50), BOTTOM_SCREEN)
	Screen.debugPrint(16, 224, (tostring(h) .. ":" .. tostring(m) .. ":" .. tostring(s)), colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(222, 224, ("Page: " .. tostring(currentPage)), colorWhite, BOTTOM_SCREEN)

end

-- Gets the inputs for L and R and startDraw
function getPageChangeInputs()
	if (isJustPressed(KEY_R)) then
		currentPage=currentPage+1;
		if (loadNextPage()==false) then
			initializeTitleScreen();
			currentPlace=1;
		end
	elseif (isJustPressed(KEY_L)) then
		currentPage=currentPage-1;
		if (loadNextPage()==false) then
			initializeTitleScreen();
			currentPlace=1;
		end
	end
	if (isJustPressed(KEY_START)) then
		destroyMainRead();
		initializeTitleScreen();
		currentPlace=1;
	end
end


function destroyMainRead()

	if (currentPageImage~=nil) then
	Screen.freeImage(currentPageImage)
	currentPageImage=nil;
	end

	fileStream = io.open(currentPath .. "_lastPage",FCREATE);
	io.write(fileStream,0,tostring(forceTripleDigitNumber(currentPage)), 3)
	io.close(fileStream);
	fileStream=nil;
end

-- Draws the currently loaded page
function drawPage()

	if (currentDrawPageMode==0) then
		Screen.drawPartialImage(0,0,currentX,currentY,400,240,currentPageImage,TOP_SCREEN)
	elseif (currentDrawPageMode==1) then
		Screen.drawImage(0,0,currentPageImage,TOP_SCREEN)
	elseif (currentDrawPageMode==2) then
		Screen.drawPartialImage(0,0,currentX,0,400,currentPageHeight,currentPageImage,TOP_SCREEN)
	else
		Screen.drawPartialImage(0,0,0,currentY,currentPageWidth,240,currentPageImage,TOP_SCREEN)
	end
	
	if (drawBottom) then
		-- 38 is bottom screen offset. Hence x+38.
		if (currentDrawPageMode==0 or currentPageMode==3) then
			if (currentPageHeight-(currentY+240))<240 then
				Screen.drawPartialImage(0,0,currentX+38,currentY+240,320,(currentPageHeight-(currentY+240)),currentPageImage,BOTTOM_SCREEN)
			else
				Screen.drawPartialImage(0,0,currentX+38,currentY+240,320,240,currentPageImage,BOTTOM_SCREEN)
			end
		end
	end

end

-- Sets the page specific settigs such as draw mode.
function getCurrentPageSpecificSettings()
	currentPageWidth = Screen.getImageWidth(currentPageImage);
	currentPageHeight = Screen.getImageHeight(currentPageImage);


	if currentPageWidth>399 then
		currentDrawPageMode=2;
	elseif currentPageHeight>239 then
		currentDrawPageMode=3;
	else
		currentDrawPageMode=1;
	end

	if (currentPageHeight>239 and currentPageWidth>399) then
		currentDrawPageMode=0;
	end

	-- Return to top.
	if (returnPlace==false) then
		currentX=0;
	else
		if (currentDrawPageMode==0 or currentDrawPageMode==2) then
			currentX=currentPageWidth-400;
		end
	end
	currentY=0;
end

-- loads the next page with the current settings
--	Returns false if it failed. Returns nil otherwise.
function loadNextPage()
	-- Frees the last image if it needs to so memory can be freed.
	if (currentPageImage~=nil) then
		Screen.freeImage(currentPageImage)
		currentPageImage=nil;
	end
	-- Checks if the next page exists.
	if ((System.doesFileExist(currentPath .. currentPrefix .. currentPage .. currentImageFormat)==false)) then
		System.deleteFile(currentPath .. "_lastPage");
		return false;
	end

	-- Finally, loads the next page
	currentPageImage = Screen.loadImage(currentPath .. currentPrefix .. currentPage .. currentImageFormat);

	getCurrentPageSpecificSettings();
end

-- Finds out number of zeros and format
-- Sets currentPrefix and imageformat to what it finds.
-- Returns false if it failed.
function detectMangaSettings()
	local _result;
	_result = detectZeros(currentPath,".jpg");
	if (_result~=false) then
		currentPrefix=_result;
		currentImageFormat=".jpg";
		return;
	end
	_result = detectZeros(currentPath,".png");
	if (_result~=false) then
		currentPrefix=_result;
		currentImageFormat=".png";
		return;
	end
	_result = detectZeros(currentPath,".bmp");
	if (_result~=false) then
		currentPrefix=_result;
		currentImageFormat=".bmp";
		return;
	end
	-- Nothing found, return false.
	return false;
end

-- Detects number of zeros using specified file format and path.
-- Returns the prefix, or false if it couldn't find the stuff.
function detectZeros(_path, _format)
	local _workPrefix="";
	for i=1,8 do
		if (System.doesFileExist(_path .. _workPrefix .. "1" .. _format)) then
			return _workPrefix;
		end
		_workPrefix = ("0" .. _workPrefix);
	end
	return false;
end

function gotoRead()
	if System.doesFileExist(currentPath .. "_lastPage") then
		fileStream = io.open(currentPath .. "_lastPage",FREAD);
		currentPage = tonumber(io.read(fileStream,0,3));
		io.close(fileStream);
		fileStream=nil;
	else
		currentPage=1;
	end
	currentPlace=0;
	loadNextPage();
end

-- =============================================
-- FILE SELECTOR
-- =============================================
local currentDirectory="/Manga/";
local currentFileList;
local currentFileSelectorSelected;
local currentFileSelectorOffset;

local sort_func = function( a,b ) return a.name < b.name end

-- Sorts currentFileList in alphabetical order
function sortCurrentFileList()
	table.sort( currentFileList, sort_func )
end

function initializeFileSelector()
	currentFileSelectorSelected=1;
	currentFileSelectorOffset=0;
	refreshDirectory();
end

-- In goes selection, returns offset. It took me about an hour to figure this out. :(
function getOffsetForSelection(_currentSelection)
	if (_currentSelection<=14) then
		return 0;
	end
	return (_currentSelection-14);
end

-- Removes a thingie from a file list
-- _toRemove is thingie to remove
-- _list is da list
function removeFromFileList(_toRemove,_list)
	for i=1,#_list do
		if (_list[i].name==_toRemove) then
			table.remove(_list,i);
			break;
		end
	end
end

-- Sets currentFileList to the list in currentDirectiry
function refreshDirectory()
	currentFileList=System.listDirectory(currentDirectory);
	sortCurrentFileList();

	if (System.doesFileExist(currentDirectory .. "_lastChapter")==true) then
		-- Remove _lastChapter from list
		removeFromFileList("_lastChapter",currentFileList)

		local _chapterStringLength;
		local _lastChapterString;
		fileStream = io.open(currentDirectory .. "_lastChapter",FCREATE);
		_chapterStringLength = tonumber(io.read(fileStream,0,2));
		_lastChapterString = io.read(fileStream,2,_chapterStringLength);
		io.close(fileStream);
		fileStream=nil;
		for i=1,#currentFileList do
			if (currentFileList[i].name==_lastChapterString) then
				currentFileSelectorSelected=i;
				currentFileSelectorOffset=getOffsetForSelection(currentFileSelectorSelected);
				break;
			end
		end
	end

end

-- For the file selector, draws the list of files in currentFileList vairable.
function drawList()
	if (#currentFileList==0) then
		Screen.debugPrint(0, 16, "Empty directory", colorWhite, TOP_SCREEN)
		return;
	end
	for i=1,14 do
		Screen.debugPrint(0, i*16, currentFileList[i+currentFileSelectorOffset].name, colorWhite, TOP_SCREEN)
		if (#currentFileList==i) then
			break;
		end
	end
	Screen.debugPrint(0, (currentFileSelectorSelected-currentFileSelectorOffset)*16, currentFileList[currentFileSelectorSelected].name, Color.new(0,255,111), TOP_SCREEN)
end

-- Controls for the file selector
function fileSelectorControls()

	local pushedDown;
	local pushedUp;
	if (isPressed(KEY_L)) then
		if (isPressed(KEY_DDOWN)) then
			pushedDown=true;
		elseif (isPressed(KEY_DUP)) then
			pushedUp=true;
		end
	else
		if (isJustPressed(KEY_DDOWN)) then
			pushedDown=true;
		elseif (isJustPressed(KEY_DUP)) then
			pushedUp=true;
		end
	end


	if (pushedDown) then
		if (currentFileSelectorSelected==#currentFileList) then
			currentFileSelectorSelected=1;
			currentFileSelectorOffset=0;
		else
			if (currentFileSelectorSelected-currentFileSelectorOffset==14) then
				currentFileSelectorOffset=currentFileSelectorOffset+1;
			end
			currentFileSelectorSelected=currentFileSelectorSelected+1;
		end
	elseif (pushedUp) then
		if (currentFileSelectorSelected==1) then
			currentFileSelectorSelected=#currentFileList;
			if (#currentFileList>14) then
			currentFileSelectorOffset = #currentFileList-14;
			end
		else
			if (currentFileSelectorSelected-currentFileSelectorOffset==1) then
				currentFileSelectorOffset=currentFileSelectorOffset-1;
			end
			currentFileSelectorSelected=currentFileSelectorSelected-1;
		end
	end

	if (isJustPressed(KEY_A)) then
		currentPath=(currentDirectory .. currentFileList[currentFileSelectorSelected].name .. "/");
		if (detectMangaSettings()~=false) then
			createLastChapterFile(currentDirectory,currentFileList[currentFileSelectorSelected].name);
			destroyFileSelector();
			gotoRead();
		else
			currentDirectory=(currentDirectory .. currentFileList[currentFileSelectorSelected].name .. "/");
			currentFileSelectorSelected=1;
			currentFileSelectorOffset=0;
			refreshDirectory();
			
		end
	elseif (isJustPressed(KEY_B)) then
		for i=2, string.len(currentDirectory) do
			if string.sub(currentDirectory,i*-1,i*-1)=="/" then
				currentDirectory = string.sub(currentDirectory, 0, (i*-1))
				break
			end
		end
		currentFileSelectorSelected=1;
		currentFileSelectorOffset=0;
		refreshDirectory();
	end

	if (isJustPressed(KEY_START)) then
		destroyFileSelector();
		initializeTitleScreen();
		currentPlace=1;
	end

end

-- The file selector's main lop.
function fileSelector()
startDraw();
clearScreens();
drawList();
Screen.debugPrint(0, 0, currentDirectory, colorWhite, BOTTOM_SCREEN)
Screen.debugPrint(0, 32, "Press A to open selected directory", colorWhite, BOTTOM_SCREEN)
Screen.debugPrint(0, 48, "Press B to go back a directory", colorWhite, BOTTOM_SCREEN)
Screen.debugPrint(0, 64, "Press START to exit to title", colorWhite, BOTTOM_SCREEN)
Screen.debugPrint(0, 80, "Hold L for really fast movement", colorWhite, BOTTOM_SCREEN)
endDraw();
getControls();
fileSelectorControls();
end

function destroyFileSelector()
	currentFileSelectorSelected=nil;
	currentFileSelectorOffset=nil;
	currentFileList=nil;
end

-- Creates the last chapter file.
-- _createLocation is usually currentDirectory and _folderName is the name of the folder that the lastchapter file will contain.
function createLastChapterFile(_createLocation, _folderName)
	fileStream = io.open(_createLocation .. "_lastChapter",FCREATE);
	io.write(fileStream,0,forceDoubleDigitNumber(#_folderName), 2);
	io.write(fileStream,2,_folderName, #_folderName);
	io.close(fileStream);
	fileStream=nil;
end

-- =============================================
-- TITLE SCREEN
-- =============================================
local titleScreenSelected;

function initializeTitleScreen()
	titleScreenSelected=0;
end

function titleScreenControls()
	if (isJustPressed(KEY_DDOWN)) then
		if (titleScreenSelected~=3) then
			titleScreenSelected=titleScreenSelected+1;
		else
			titleScreenSelected=0;
		end
	elseif (isJustPressed(KEY_DUP)) then
		if (titleScreenSelected~=0) then
			titleScreenSelected=titleScreenSelected-1;
		else
			titleScreenSelected=3;
		end
	elseif (isJustPressed(KEY_A)) then
		if (titleScreenSelected==0) then
			destroyTitleScreen();
			initializeFileSelector();
			currentPlace=2;
		elseif (titleScreenSelected==1) then
			destroyTitleScreen();
			initializeDownloadMenu();
			currentPlace=3;
		elseif (titleScreenSelected==2) then
			destroyTitleScreen();
			initializeOptionsMenu();
			currentPlace=4;
		elseif (titleScreenSelected==3) then
			System.exit();
		end
	end
end

function titleScreen()
	getControls();
	startDraw();
	clearScreens();
	titleScreenDraw();
	endDraw();
	titleScreenControls();
end

-- Draws the title screen stuff
function titleScreenDraw()
	Screen.debugPrint(134, 136, "Manga Reader", colorWhite, TOP_SCREEN)
	Screen.debugPrint(0, 0, "v2.0", colorWhite, TOP_SCREEN)
	Screen.debugPrint(150, 120, "Read", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(150, 136, "Download", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(150, 152, "Options", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(150, 168, "Exit", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(134, titleScreenSelected*16+120, ">", colorGreen, BOTTOM_SCREEN)
end

function destroyTitleScreen()
	titleScreenSelected=nil;
end

-- ==========================================================================
-- NUMPAD
-- ==========================================================================

-- What you inputed with the numpad. Needs to be converted to number.
local numpadInput;
local numpadMessage;
local numpadActive;

function openNumpad(_message,_default)
numpadMessage=_message;
numpadActive=true;
numpadInput=tostring(_default);
numpadMainLoop();
numpadMessage=nil;
numpadActive=nil;
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
	Screen.debugPrint(45, 25, "7", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(151, 25, "8", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(257, 25, "9", colorWhite, BOTTOM_SCREEN)
	--===
	Screen.debugPrint(45, 85, "4", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(151, 85, "5", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(257, 85, "6", colorWhite, BOTTOM_SCREEN)
	--===
	Screen.debugPrint(45, 145, "1", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(151, 145, "2", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(257, 145, "3", colorWhite, BOTTOM_SCREEN)
	--====
	Screen.debugPrint(45, 205, "DONE", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(151, 205, "0", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(257, 205, "<-", colorWhite, BOTTOM_SCREEN)
end

function numpadMainLoop()
	while (numpadActive) do
	startDraw();
	clearScreens();
	Screen.debugPrint(0, 0, numpadMessage, colorWhite, TOP_SCREEN)
	Screen.debugPrint(0, 64, numpadInput, colorWhite, TOP_SCREEN)

	drawNumpad()
	getControls();
	getTouch();

	if (isJustPressed(KEY_TOUCH)) then
		checkNumpadTouch();
	end
	
	endDraw();
	end
end


-- ========================================
-- OPTIONS MENU
-- =======================================
local optionsSelected;

function optionsMenuControls()
	if (isJustPressed(KEY_DDOWN)) then
		if (optionsSelected~=1) then
			optionsSelected=optionsSelected+1;
		else
			optionsSelected=0;
		end
	elseif (isJustPressed(KEY_DUP)) then
		if (optionsSelected~=0) then
			optionsSelected=optionsSelected-1;
		else
			optionsSelected=1;
		end
	elseif (isJustPressed(KEY_A)) then
		if (optionsSelected==0) then
			openNumpad("Enter the speed you want.",moveSpeed)
			moveSpeed = tonumber(numpadInput);
		elseif (optionsSelected==1) then
			if (returnPlace) then
				returnPlace=false;
			else
				returnPlace=true;
			end
		end
	end

	if (isJustPressed(KEY_START)) then
		saveOptions();
		currentPlace=1;
		destroyOptionsMenu();
		initializeTitleScreen();
	end
end

function initializeOptionsMenu()
	optionsSelected=0;
end

function optionsMenuDraw()
	Screen.debugPrint(0, 0, "Options", colorWhite, TOP_SCREEN)
	Screen.debugPrint(0, 32+(optionsSelected*16), ">", colorGreen, TOP_SCREEN)
	Screen.debugPrint(16, 32, "Speed - " .. moveSpeed, colorWhite, TOP_SCREEN)
	if (returnPlace) then
		Screen.debugPrint(16, 48, "Return location - Top right", colorWhite, TOP_SCREEN)
	else
		Screen.debugPrint(16, 48, "Return location - Top left", colorWhite, TOP_SCREEN)
	end
	Screen.debugPrint(0, 0, "Up and down to select something", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(0, 16, "Press A to change selected option", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(0, 32, "Press START to go back to the title", colorWhite, BOTTOM_SCREEN)
end

function optionsMenu()
	getControls();
	startDraw();
	clearScreens();
	optionsMenuDraw();
	endDraw();
	optionsMenuControls();
end

function destroyOptionsMenu()
	optionsSelected=nil;
end

-- ===================================
-- DOWNLOADING
-- ==================================
-- Current chapter number downloading
local currentDownloadChapterNumber;
-- current download manga name (in url)
local currentDownloadName;
-- the subdomain for the current page on the website
local currentDownloadSubdomain;
-- the location to save files in. Ends with /
local currentDownloadSaveLocation;
-- The total amount of pages
local currentDownloadTotalPages;
-- Number of retries left
local currentDownloadRetriesLeft;
-- if it's failed.
local downloadFailed;
-- Selected
local downloadMenuSelected;
-- Download options file selected
local downloadOptionsFile;

function initializeDownloadMenu()
	currentDownloadChapterNumber=1;
	currentDownloadName="inuyasha";
	currentDownloadSubdomain="Working...";
	currentDownloadSaveLocation=("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber .. "/");
	currentDownloadRetriesLeft=10;
	downloadMenuSelected=0;
	downloadFailed=false;
	downloadOptionsFile=0;
end

-- Returns page file name random wierd number and subdomain
function downloadGetUrlData(_mangaName,_mangaChapter,_mangaPageNumber)
	local _subdomain="";
	local _fileNumber="";

	local _startImageUrlIndex;
	local _endImageUrlIndex;

	local _currentPageHtml = safeRequestString("http://www.mangareader.net/" .. _mangaName .. "/" .. _mangaChapter .. "/" .. _mangaPageNumber);
	if (downloadFailed) then
		return false, false
	end

	-- First search, this is a dummy one we don't need if it's not the last page we're dealing with.
	a,b = string.find(_currentPageHtml, (".mangareader.net/" .. _mangaName .. "/" .. _mangaChapter .. "/" .. _mangaName .. "-"),1,true)
	-- If it couldn't even find that, we've failed.
	if a==nil and b==nil then
		return false,false
	end

	-- This is usually the one we want
	_startImageUrlIndex,_endImageUrlIndex = string.find(_currentPageHtml, (".mangareader.net/" .. _mangaName .. "/" .. _mangaChapter .. "/" .. _mangaName .. "-"),b,true);

	-- But if this is the last page in the chapter, that one won't be found.
	if _startImageUrlIndex==nil and _endImageUrlIndex==nil then
		-- In that case, we need the first search result.
		_startImageUrlIndex = a;
		_endImageUrlIndex = b;
		-- No longer need these.
		a=nil;
		b=nil;
	end

	-- Okay, we found the start and end index of the url we want. Let's find the number and subdomain now!
	--===================================
	-- THis is the index at which the image numer starts at.
	local numberStartLocation;
	local searchingForNumbersNumero;


	numberStartLocation=(_startImageUrlIndex+string.len(".mangareader.net/" .. _mangaName .. "/" .. _mangaChapter .. "/" .. _mangaName .. "-"))
	searchingForNumbersNumero=numberStartLocation;

	-- This will find the image number. Keep getting the next character, determine if it's a number, if so, add it on to the string and keep going.
	while true do
	if tonumber(string.sub(_currentPageHtml, searchingForNumbersNumero, searchingForNumbersNumero))~=nil then
		_fileNumber = (_fileNumber .. string.sub(_currentPageHtml, searchingForNumbersNumero, searchingForNumbersNumero))
		searchingForNumbersNumero=searchingForNumbersNumero+1
	else
	-- We've reached the end; something that's not a number.
		break
	end
	end

	-- Checks if there's a slash 3 places back. If not, 3 digit subdomain. Otherwise, 2 digit sumdomain.
	-- Do I even need 3 digit subdomain? I'm not sure.
	if (string.sub(_currentPageHtml,_startImageUrlIndex-3,_startImageUrlIndex-3)~="/") then
		_subdomain=string.sub(_currentPageHtml,_startImageUrlIndex-3,_startImageUrlIndex-1)
	else
		_subdomain=string.sub(_currentPageHtml,_startImageUrlIndex-2,_startImageUrlIndex-1)
	end

	return _fileNumber,_subdomain;
end



function destroyDownloadMenu()
	currentDownloadChapterNumber=nil;
	currentDownloadName=nil;
	currentDownloadSubdomain=nil;
	currentDownloadSaveLocation=nil;
	currentDownloadRetriesLeft=nil;
	currentDownloadTotalPages=nil;
	downloadFailed=nil;
	downloadMenuSelected=nil;
	downloadOptionsFile=nil;
end

-- Trys to request string. If it fails, waits 500 milisecodns and retries. Takes one retry every time. If it runs out of retries and fails, returns false.
function safeRequestString(_requestURL)
	if not pcall(function()
	_resultString = Network.requestString(_requestURL)
	end) then
		if (currentDownloadRetriesLeft>0) then
			wait(500);
			currentDownloadRetriesLeft=currentDownloadRetriesLeft-1;
			return safeRequestString(_requestURL);
		else
			downloadFailed=true;
			return false;
		end
	else
		return _resultString;
	end
end

function downloadFindNumberOfPages()
	_mangaPageSample = safeRequestString("http://www.mangareader.net/" .. currentDownloadName .. "/" .. tostring(currentDownloadChapterNumber) .. "/1")
	if (downloadFailed) then
		return false;
	end
	local _checkPage = 2;

	while true do
	a,b = string.find(_mangaPageSample, ('<option value="/' .. currentDownloadName .. '/' .. tostring(currentDownloadChapterNumber) .. '/' .. tostring(_checkPage) .. '"'),1,true)
	if a==nil then
		break
	end
		_checkPage=_checkPage+1;
	end
	currentDownloadTotalPages=_checkPage-1;

end

-- Downloads
function downloadPage(_mangaName,_mangaChapter,_mangaPageNumber,_saveLocation)
	local _subdomain;
	local _fileNumber;
	_fileNumber, _subdomain = downloadGetUrlData(_mangaName,_mangaChapter,_mangaPageNumber);

	startDraw();
	clearScreens();
	Screen.debugPrint(0, 0, (_mangaPageNumber .. "/" .. currentDownloadTotalPages),colorWhite, TOP_SCREEN)
	
	endDraw();
	--wait(5000)

	Network.downloadFile(("http://" .. _subdomain .. ".mangareader.net/" .. _mangaName .. "/" .. _mangaChapter .. "/" .. _mangaName .. "-" .. _fileNumber .. ".jpg"),(_saveLocation .. _mangaPageNumber .. ".jpg"));
end

function downloadDoTheThing()
	System.createDirectory("/Manga/" .. currentDownloadName)
	System.createDirectory("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber)
	
	downloadFindNumberOfPages();
	
	for i=1,currentDownloadTotalPages do
		downloadPage(currentDownloadName,currentDownloadChapterNumber,i,currentDownloadSaveLocation)
	end
	--startDraw();
	--clearScreens();
	--Screen.debugPrint(0, 0, tostring(currentDownloadTotalPages), Color.new(255,255,255), TOP_SCREEN)
	--endDraw();
	--wait(2000)
end

function downloadMenu()
	getControls();
	startDraw();
	clearScreens();
	downloadMenuDraw();
	endDraw();
	downloadMenuControls();
end

-- Saves download options with the variables
function downloadSaveOptions()
	local _fileStream = io.open(("/MangaReader-cfg-dl-" .. downloadOptionsFile),FCREATE);
	local _dataToWrite=(currentDownloadName .. "," .. currentDownloadChapterNumber .. "," .. currentDownloadSaveLocation);
	io.write(_fileStream,0,forceTripleDigitNumber(#_dataToWrite), 3);
	io.write(_fileStream,3,_dataToWrite,#_dataToWrite);
	io.close(_fileStream);
	_fileStream=nil;
	_dataToWrite=nil;
end

function downloadLoadOptions()
	if (System.doesFileExist("/MangaReader-cfg-dl-" .. downloadOptionsFile)==false) then
		return;
	end

	local _readData;
	local _dataSize;
	local _fileStream = io.open(("/MangaReader-cfg-dl-" .. downloadOptionsFile),FCREATE);
	
	_dataSize = tonumber(io.read(_fileStream,0,3));
	_readData = io.read(_fileStream,3,_dataSize)
	io.close(_fileStream);
	

	currentDownloadName, currentDownloadChapterNumber, currentDownloadSaveLocation = _readData:match("([^,]+),([^,]+),([^,]+)")
	currentDownloadChapterNumber = tonumber(currentDownloadChapterNumber);

	_readData=nil;
	_fileStream=nil;
	_dataSize=nil

end

function downloadMenuControls()
	if (isJustPressed(KEY_DDOWN)) then
		if (downloadMenuSelected~=7) then
			downloadMenuSelected=downloadMenuSelected+1;
		else
			downloadMenuSelected=0;
		end
	elseif (isJustPressed(KEY_DUP)) then
		if (downloadMenuSelected~=0) then
			downloadMenuSelected=downloadMenuSelected-1;
		else
			downloadMenuSelected=5;
		end
	elseif (isJustPressed(KEY_A)) then
		if (downloadMenuSelected==0) then
			destroyDownloadMenu();
			currentPlace=1;
			initializeTitleScreen();
		elseif (downloadMenuSelected==1) then
			currentDownloadName = System.startKeyboard(currentDownloadName);
			currentDownloadSaveLocation=("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber .. "/")
		elseif (downloadMenuSelected==2) then
			openNumpad("Which chapter?",currentDownloadChapterNumber)
			currentDownloadChapterNumber = tonumber(numpadInput);
			currentDownloadSaveLocation=("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber .. "/")
		elseif (downloadMenuSelected==3) then
			downloadSaveOptions();
		elseif (downloadMenuSelected==4) then
			downloadLoadOptions();
		elseif (downloadMenuSelected==5) then
			downloadDoTheThing();
			if (downloadFailed) then
				showFailed();
			end
			destroyDownloadMenu();
			currentPlace=1;
			initializeTitleScreen();
		elseif (downloadMenuSelected==7) then
			currentDownloadSaveLocation = System.startKeyboard(currentDownloadSaveLocation);
		end
		
	elseif (isJustPressed(KEY_DLEFT)) then
			if (downloadMenuSelected==2) then
				if (currentDownloadChapterNumber>1) then
					currentDownloadChapterNumber=currentDownloadChapterNumber-1;
					currentDownloadSaveLocation=("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber .. "/")
				end
			elseif (downloadMenuSelected==3 or downloadMenuSelected==4) then
					downloadOptionsFile=downloadOptionsFile-1;
			end
	elseif (isJustPressed(KEY_DRIGHT)) then
			if (downloadMenuSelected==2) then
					currentDownloadChapterNumber=currentDownloadChapterNumber+1;
					currentDownloadSaveLocation=("/Manga/" .. currentDownloadName .. "/chapter-" .. currentDownloadChapterNumber .. "/")
			elseif (downloadMenuSelected==3 or downloadMenuSelected==4) then
					downloadOptionsFile=downloadOptionsFile+1;
			end
	end
end


function showFailed()
	startDraw();
	clearScreens();
	Screen.debugPrint(0, 0, "Failed due to network error", colorWhite, TOP_SCREEN)
	endDraw();
	wait(1000);
end
-- Draws the title screen stuff
function downloadMenuDraw()
	Screen.debugPrint(16, 0, "Back", colorWhite, TOP_SCREEN)
	Screen.debugPrint(16, 16, ("Name - " .. currentDownloadName), colorWhite, TOP_SCREEN)
	Screen.debugPrint(16, 32, ("Chapter number - " .. currentDownloadChapterNumber), colorWhite, TOP_SCREEN)
	Screen.debugPrint(16, 48, "[Save - slot " .. downloadOptionsFile .. "]", colorWhite, TOP_SCREEN)
	Screen.debugPrint(16, 64, "[Load - slot " .. downloadOptionsFile .. "]", colorWhite, TOP_SCREEN)
	Screen.debugPrint(16, 80, "Go", colorWhite, TOP_SCREEN)
	--Screen.debugPrint(16, 96, "Save location:", colorWhite, TOP_SCREEN)
	--Screen.debugPrint(16, 112, currentDownloadSaveLocation, colorWhite, TOP_SCREEN)
	Screen.debugPrint(0, 0, "If you don't know how this works,", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(0, 16, "read the tutorial on the thread.", colorWhite, BOTTOM_SCREEN)
	Screen.debugPrint(0, 32, "(Text and video tutorials avalible)", colorWhite, BOTTOM_SCREEN)
	
	Screen.debugPrint(0, downloadMenuSelected*16, ">", colorGreen, TOP_SCREEN)
end

-- ===================================
-- FUNCTIONS END
-- ===================================

getControls();
getControls();
initializeTitleScreen();

	-- FPS TEST
	--[[
	while (true) do
		detectMangaSettings();
		startDraw();
		clearScreens();
		Screen.debugPrint(0, 0, (lastFps), colorWhite, TOP_SCREEN)
		--Screen.debugPrint(0, 32, currentImageFormat, colorWhite, TOP_SCREEN)
		--Screen.debugPrint(0, 64, (currentPath .. currentPrefix .. currentPage .. currentImageFormat), colorWhite, TOP_SCREEN)
		endDraw();
		frames=frames+1;
		if (Timer.getTime(fpsTimer)>=1000) then
		Timer.reset(fpsTimer);
		lastFps=frames;
		frames=0;
		end
	end
	]]

if (System.getModel()==2 or System.getModel()==4) then
	isNew3ds=true;
end

-- Loads options
loadOptions();

-- This is a loop going on forever that determins where you are in sections.
while (true) do
	if (currentPlace==0) then
		mainRead();
	elseif (currentPlace==1) then
		titleScreen();
	elseif (currentPlace==2) then
		fileSelector();
	elseif (currentPlace==3) then
		downloadMenu();
	elseif (currentPlace==4) then
		optionsMenu();
	end
end
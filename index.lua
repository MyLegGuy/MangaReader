System.setCpuSpeed(NEW_3DS_CLOCK)

function happyfunction()
while true do
	break
end
end
happyfunction()
happyfunction()

local prefix=""
local number=1
local x=0
local y=0

local music=false;

local folder = "/Manga/"
local filetype = ".jpg"
local plus=38
local numbertype=1
local startnumber=1
local dpadspecial=0
local speed=10
local zeros=0

local version=2

local screens=true;
local reallifeinfo=false;
local chapter=1
local name="the-gamer"
local currentnumber=0
local savenumber=1
local subdomain="error"
local numpages=-1

local doshutdown=true

local savename="/Manga/aManga/"

--image = Screen.loadImage("a.jpg")



--=================================================================
--=================================================================
--=================================================================

function quickdisplayxy(davar, x, y)
Screen.waitVblankStart()
Screen.refresh()
Screen.debugPrint(x, y, davar, Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
end

function quickdisplay(davar)
Screen.waitVblankStart()
Screen.refresh()
Screen.debugPrint(130, 0, davar, Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
end

function loadoptions()
fileStream = (io.open("/MangaReaderOptions.cfg",FREAD))

os = io.read(fileStream,2,io.read(fileStream,0,2))
io.close(fileStream)

-- [inbracks] 2,-2 would return inbrackets
pastnumbero=0
dpadspecial=tonumber(string.sub(os,1,1))
zeros=(tonumber(string.sub(os,4,tonumber(string.sub(os,2,3))+3)))
pastnumbero=tonumber(string.sub(os,2,3))+3
speed=tonumber(string.sub(os,pastnumbero+1,pastnumbero+2))
pastnumbero=pastnumbero+2
filetype=string.sub(os,pastnumbero+3,tonumber(string.sub(os,pastnumbero+1,pastnumbero+2))+pastnumbero+2)
pastnumbero=tonumber(string.sub(os,pastnumbero+1,pastnumbero+2))+pastnumbero+2
prefix=string.sub(os,pastnumbero+3,tonumber(string.sub(os,pastnumbero+1,pastnumbero+2))+pastnumbero+2)

if (Controls.check(Controls.read(),KEY_R)) then
while true do

Screen.waitVblankStart()
Screen.refresh()
Screen.debugPrint(0, 0, os, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 16, dpadspecial, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32, zeros, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32+16, speed, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32+32, filetype, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32+32+16, prefix, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32+32+32, "hi", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 64+32+16, pastnumbero, Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 64+32+32, "Those are the loaded options.", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 64+32+32+16, "Press A to continue, B to delete the options.", Color.new(255,255,255), TOP_SCREEN)
Screen.flip()

if (Controls.check(Controls.read(),KEY_B)) then
	System.deleteFile("/MangaReaderOptions.cfg");
	prefix=""
	number=1
	folder = "/Manga/"
	filetype = ".jpg"
	numbertype=1
	startnumber=1
	dpadspecial=0
	speed=10
	zeros=0
	break;
end
if (Controls.check(Controls.read(),KEY_A)) then
	break;
end

end
end

end


function saveoptions(_dpadspecial,_zeros,_speed,_filetype,_prefix)
happytemp=""
if (System.doesFileExist("/MangaReaderOptions.cfg")) then
System.deleteFile("/MangaReaderOptions.cfg")
end

--1, custom, 2, custom, custom

happytemp=tostring(_dpadspecial)
happytemp=(happytemp .. (fixnumbersize2(string.len(_zeros)) .. tostring(_zeros)))
happytemp=(happytemp .. tostring(_speed))
happytemp=(happytemp .. (fixnumbersize2(string.len(_filetype)) .. tostring(_filetype)))
happytemp=(happytemp .. (fixnumbersize2(string.len(_prefix)) .. tostring(_prefix)))
happytemp=(string.len(happytemp) .. happytemp)

fileStream = (io.open("/MangaReaderOptions.cfg",FCREATE))

io.write(fileStream,0,happytemp, string.len(happytemp))
io.close(fileStream)

happytemp=nil
end

function fixnumbersize2(number)
if number<100 then
return (("0" .. tostring(number)))
else
	return number
end
end

function loadnextpage(num)

if image~=nil then
Screen.freeImage(image)
image=nil
end


z=""

if tonumber(zeros)>0 then

if num>9 then
if num>99 then
if tonumber(zeros)>2 then
for k=1, tonumber(zeros)-2 do
z=("0" .. z)
end
end
else
if tonumber(zeros)>1 then
for k=1, tonumber(zeros)-1 do
z=("0" .. z)
end
end
end
else
for k=1, tonumber(zeros) do
z=("0" .. z)
end
end
end

z=(z .. prefix .. tostring(num))


if System.doesFileExist( folder .. z .. filetype) then
image = Screen.loadImage( folder .. z .. filetype)
imagewidth = Screen.getImageWidth(image)
imageheight = Screen.getImageHeight(image)
x=imagewidth-400
y=0
return true
else
return (folder .. z .. filetype)
end
end




function System.wait(milliseconds)
   tmp = Timer.new()
   while Timer.getTime(tmp) < milliseconds do end
   Timer.destroy(tmp)
end




function checkoptions()
if plus<0 then
plus=0
end
end


--=================================================================
--=================================================================
--=================================================================









function read(readnumber)

if (System.doesFileExist( folder .. "page.txt")) then
fileStream = io.open((folder .. "page.txt"),FREAD)
happytemp = io.read(fileStream,0,4)
readnumber=tonumber(happytemp)
number=readnumber
happytemp=nil
io.close(fileStream)
end

if loadnextpage(readnumber)~=true then
System.deleteFile(folder .. "page.txt")

Screen.waitVblankStart()
Screen.refresh()
Screen.debugPrint(0, 0, "Could not load the first page.", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 150, "It should be:", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 200, loadnextpage(readnumber), Color.new(255,255,255), TOP_SCREEN)
Screen.flip()


System.wait(5000)
return
end
tchyx=0
tchy=0
oldtchx=0
oldtchy=0

if music==true then
Sound.play(wav,LOOP)
end

while true do
	Screen.waitVblankStart()
	Screen.refresh()
	Screen.clear(TOP_SCREEN)
	Screen.clear(BOTTOM_SCREEN)
pad = Controls.read()
tchx,tchy = Controls.readTouch()

if music==true then Sound.updateStream() end

cpx,cpy = Controls.readCirclePad()
cppx,cppy = Controls.readCstickPad()

if tchx~=0 and oldtchx~=0 then
if tchx~=oldtchx then
x=x+(oldtchx-tchx)*2
end
if tchy~=oldtchy then
y=y+((oldtchy-tchy)*2)
end
end


if pad~=oldpad then

	if (Controls.check(pad,KEY_R)) then
		number=number+1
		if loadnextpage(number)~=true then
	break
	end
	end
	if (Controls.check(pad,KEY_L)) then
		number=number-1
		if loadnextpage(number)~=true then
		break		
	end
	end



	if (Controls.check(pad,KEY_ZL)) then
		number=number+1
		if loadnextpage(number)~=true then
		break		
	end
	end

	if (Controls.check(pad, KEY_X)) then
	if reallifeinfo==true then reallifeinfo=false else reallifeinfo=true end
end
	end
if (Controls.check(pad,KEY_START)) then
Screen.freeImage(image)
image=nil
oldpad=pad
if (System.doesFileExist( folder .. "page.txt")) then
System.deleteFile(folder .. "page.txt")
end
happytemp=""
fileStream = io.open((folder .. "page.txt"),FCREATE)
if string.len(tostring(number))<4 then
for i=1, 4-string.len(number) do
happytemp=(happytemp .. "0")
end
end

io.write(fileStream,0,(happytemp .. tostring(number)), 4)
io.close(fileStream)
happytemp=nil

if music==true then
music=false
Sound.pause(wav)
Sound.close(wav)
Sound.term()
end

break
end




	if (Controls.check(pad,KEY_DRIGHT)) and dpadspecial==1 then
				number=number+1
		if loadnextpage(number)~=true then
	break
	end
	end
	if (Controls.check(pad,KEY_DLEFT)) and dpadspecial==1 then
				number=number-1
		if loadnextpage(number)~=true then
	break
	end
	end


	if (Controls.check(pad,KEY_DRIGHT)) or cpx>50 or cppx>50 then
		x=x+speed
	end
	if (Controls.check(pad,KEY_DLEFT)) or cpx<-50 or cppx<-50 then
		x=x-speed
	end

	if (Controls.check(pad,KEY_DUP)) or cpy>50 or cppy>50 then
		y=y-speed
	end
	if (Controls.check(pad,KEY_DDOWN)) or cpy<-50 or cppy<-50 then
		y=y+speed
	end




if y<0 then
	y=0
end
if x<0 then
x=0
end
if x+400>imagewidth then
	x=imagewidth-400
end
if y+240>imageheight then
	y=imageheight-240
end

--====================================================================================================
--====================================================================================================

--Screen.drawImage(x,y,image,TOP_SCREEN)
if imageheight>239 and imagewidth>399 then
Screen.drawPartialImage(0,0,x,y,400,240,image,TOP_SCREEN)

if (imageheight-(y+240))<240 then
--Screen.drawPartialImage(0,0,x+plus,((imageheight-(imageheight-(y+240)))),320,(imageheight-(y+240)),image,BOTTOM_SCREEN)
Screen.drawPartialImage(0,0,x+plus,y+240,320,(imageheight-(y+240)),image,BOTTOM_SCREEN)
else
Screen.drawPartialImage(0,0,x+plus,y+240,320,240,image,BOTTOM_SCREEN)
end

else

if imagewidth>399 then
Screen.drawPartialImage(0,0,x,0,400,imageheight,image,TOP_SCREEN)
elseif imageheight>239 then
Screen.drawPartialImage(0,0,0,y,imagewidth,240,image,TOP_SCREEN)
elseif true==true then
Screen.drawImage(0,0,image,TOP_SCREEN)
end

end

if reallifeinfo==true then
h,m,s = System.getTime()
if h>11 then
h=h-12
unit = "PM"
else
unit="AM"
end
Screen.fillRect(0, 320, 214, 239, Color.new(0,155,50), BOTTOM_SCREEN)
if m<10 then
Screen.debugPrint(16, 224, (tostring(h) .. ":" .. "0" .. tostring(m) .. " " .. unit), Color.new(255,255,255), BOTTOM_SCREEN)
else
Screen.debugPrint(16, 224, (tostring(h) .. ":" .. tostring(m) .. " " .. unit), Color.new(255,255,255), BOTTOM_SCREEN)
end
Screen.debugPrint(222, 224, ("Page: " .. tostring(number)), Color.new(255,255,255), BOTTOM_SCREEN)
end

--==========================================================================================================
--=======================================================================================================


oldtchx=tchx
oldtchy=tchy
Screen.flip()
oldpad = pad
end
end












--=================================================================
--=================================================================
--=================================================================








function options()
selected=1
while true do
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
pad = Controls.read()



Screen.debugPrint(130, 0, "Manga Reader", Color.new(0,255,94), TOP_SCREEN)
Screen.debugPrint(130, 16, "Options", Color.new(50,50,0), TOP_SCREEN)

Screen.debugPrint(100, 0, "Image type", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(100, 16, "Prefix", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(100, 32, "Starting number", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(100, 48, "Back", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(100, 64, "Speed", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(50, 80, "Number of additional zeros.", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(112, 112, "Check for updates", Color.new(255,255,255), BOTTOM_SCREEN)
--Screen.debugPrint(35, 112, "Activate new 3ds mode. (No differnece)", Color.new(255,255,255), BOTTOM_SCREEN)

if dpadspecial==1 then
Screen.debugPrint(75, 96, "Dpad switches pages too.", Color.new(0,255,0), BOTTOM_SCREEN)
else
Screen.debugPrint(75, 96, "Dpad switches pages too.", Color.new(255,0,0), BOTTOM_SCREEN)
end

if selected==1 then
Screen.debugPrint(100, 0, "Image type", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==2 then
Screen.debugPrint(100, 16, "Prefix", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==3 then
Screen.debugPrint(100, 32, "Starting number", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==4 then
Screen.debugPrint(100, 48, "Back", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==5 then
Screen.debugPrint(100, 64, "Speed", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==6 then
Screen.debugPrint(50, 80, "Number of additional zeros.", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==8 then
Screen.debugPrint(112, 112, "Check for updates", Color.new(0,255,0), BOTTOM_SCREEN)
end

if pad~=oldpad then

if (Controls.check(pad,KEY_A)) then
if selected==1 then
filetype = System.startKeyboard(filetype)
elseif selected==2 then
prefix=System.startKeyboard(prefix)
elseif selected==3 then
happyvar=System.startKeyboard("1")
startnumber=tonumber(happyvar)
if startnumber==nil then
quickdisplay("Not a number.")
System.wait(3000)
System.exit()
end
happyvar=nil
elseif selected==4 then
selected=2
oldpad=pad
saveoptions(dpadspecial,zeros,speed,filetype,prefix)
break
elseif selected==5 then
happyvar=System.startKeyboard(tostring(speed))
speed=tonumber(happyvar)
if speed==nil or speed>99 then
quickdisplay("Not a number. Or es greater than 99.")
System.wait(3000)
System.exit()
end
happyvar=nil
elseif selected==6 then
zeros=System.startKeyboard(tostring(zeros))
elseif selected==7 then
if dpadspecial==1 then
dpadspecial=0
else
dpadspecial=1
end
elseif selected==8 then

if not pcall(function()
string = Network.requestString("http://mylegguy.x10.mx/MangaReader.txt")
end
) then
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.debugPrint(0, 0, "Could not check for updates. :(", Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
System.wait(3000)
else
if tonumber(string)>version then
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.debugPrint(0, 0, "Update avalible! Go get it! Right now!", Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
System.wait(3000)
else
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.debugPrint(0, 0, "Nope. No new update.", Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
System.wait(3000)
end
end

elseif selected==9 then
end
end
if (Controls.check(pad,KEY_START)) then
System.exit()
end
if (Controls.check(pad,KEY_DUP)) then
selected=selected-1
if selected<1 then
selected=1
end
end
if (Controls.check(pad,KEY_DDOWN)) then
selected=selected+1
if selected>8 then
selected=8
end
end
end


Screen.flip()
oldpad = pad
end

end









--=================================================================
--=================================================================
--=================================================================






function title()
selected=1
while true do
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
pad = Controls.read()

if selected>4 then
selected=4
end

Screen.debugPrint(130, 0, "Manga Reader", Color.new(0,255,94), TOP_SCREEN)
Screen.debugPrint(0, 224, "V 1.8.7", Color.new(0,255,255), TOP_SCREEN)

Screen.debugPrint(130, 0, "Read", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(130, 16, "Download", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(130, 32, "Options", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(130, 48, "Exit", Color.new(255,255,255), BOTTOM_SCREEN)

if selected==1 then
Screen.debugPrint(130, 0, "Read", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==2 then
Screen.debugPrint(130, 16, "Download", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==3 then
Screen.debugPrint(130, 32, "Options", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==4 then
Screen.debugPrint(130, 48, "Exit", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==5 then
Screen.debugPrint(130, 64, "Enable o3ds mode", Color.new(0,255,0), BOTTOM_SCREEN)
elseif selected==6 then
Screen.debugPrint(130, 80, "Secret-er option.", Color.new(0,255,0), BOTTOM_SCREEN)
end

if pad~=oldpad then
if (Controls.check(pad,KEY_A)) then
if selected==1 then
pad=1
oldpad=1
choosemanga()
if returntotitle~=1 then
number=startnumber
read(startnumber)
end
returntotitle=nil
pad=1
oldpad=1
elseif selected==2 then
--mangawarning()
mangadownloadsetup()
downloadmanga()
elseif selected==3 then
pad=1
oldpad=1
options()
elseif selected==4 then
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(BOTTOM_SCREEN)
Screen.debugPrint(0, 0, "Quick! You have 3 seconds to push", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0,16," L+R+B+Down! Or wait through loop.", Color.new(255,255,255),BOTTOM_SCREEN)
Screen.flip()
System.wait(3000)
System.exit()
elseif selected==5 then
System.setCpuSpeed(OLD_3DS_CLOCK)
elseif selected==6 then
if music==true then music=false else
music=true;
Sound.init()
wav = Sound.openWav("/MangaReaderBackground.wav",true)
end
end
end
if (Controls.check(pad,KEY_DUP)) then
selected=selected-1
if selected<1 then
selected=1
end
end
if (Controls.check(pad,KEY_DDOWN)) then
selected=selected+1
if selected>4 then
selected=4
end
end
end

Screen.flip()
oldpad = pad
end
end










--======================================================================
--==============================================================
--====================================================================

function mangawarning()
pad=Controls.read()
oldpad=pad
while true do
pad=Controls.read()
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)

Screen.debugPrint(0, 0, "This feature downloads manga from", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 16, "http://mangareader.net. I am not responsible", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32, "for any content hosted there.", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 64, "Press A to continue.", Color.new(255,255,255), TOP_SCREEN)

if pad~=oldpad then
if (Controls.check(pad,KEY_A)) then
return
end
end

Screen.flip()
oldpad=pad
end
end

function mangadownloadsetup()
pad=Controls.read()
oldpad=pad
menu=2
while true do
pad=Controls.read()
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)

Screen.debugPrint(80, 0, "Manga download settings", Color.new(0,255,0), TOP_SCREEN)

Screen.debugPrint(16, 32, "Name:", Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 48, (name), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 64, ("Chapter: " .. tostring(chapter)), Color.new(255,255,255), TOP_SCREEN)
--Screen.debugPrint(16, 80, ("Number of pages: " .. tostring(numpages)), Color.new(255,255,255), TOP_SCREEN)
--Screen.debugPrint(16, 96, ("Screens on:" .. tostring(screens)), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 80, ("Save folder:" .. savename), Color.new(255,255,255), TOP_SCREEN)
--Screen.debugPrint(16, 128, ("Shutdown when done:" .. tostring(doshutdown)), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 96, ("[Save options]"), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 112, ("[Load options]"), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(16, 128, ("Go!"), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, menu*16, (">"), Color.new(255,255,255), TOP_SCREEN)

--Screen.debugPrint(16,190,tostring(System.getCpuSpeed()),Color.new(255,255,255),TOP_SCREEN)

Screen.debugPrint(0, 0, "This feature downloads manga from", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 16, "http://mangareader.net. I am not", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 32, "responsible for any content hosted", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 48, "there.", Color.new(255,255,255), BOTTOM_SCREEN)


if menu>8 then
menu=2
elseif menu<2 then
menu=8
end

if pad~=oldpad then
if (Controls.check(pad,KEY_DDOWN)) then
menu=menu+1
elseif (Controls.check(pad,KEY_DUP)) then
menu=menu-1
elseif (Controls.check(pad,KEY_A)) then
if menu==2 or menu==3 then
name=System.startKeyboard(name)
savename=("/Manga/" .. name .. "/" .. "chapter" .. "-" .. tostring(chapter))
elseif menu==4 then
chapter = tonumber(System.startKeyboard(chapter))
savename=("/Manga/" .. name .. "/" .. "chapter" .. "-" .. tostring(chapter))
elseif menu==5 then
savename = System.startKeyboard(savename)
elseif menu==6 then
savedloptions()
elseif menu==7 then
loaddloptions()
elseif menu==8 then
break
end
end
end

Screen.flip()
oldpad=pad
end
end

function display(x,y,message, clear)
Screen.waitVblankStart()
Screen.refresh()
if clear==1 then
Screen.clear(TOP_SCREEN)
end
Screen.debugPrint(x, y, message, Color.new(255,255,255), TOP_SCREEN)
Screen.flip()
end

function getnumbers(_name, _chapter, _page)

if not pcall(function()
	string = Network.requestString("http://www.mangareader.net/" .. _name .. "/" .. tostring(_chapter) .. "/" .. tostring(_page))
	end
	) then
return false,false
end


a,b = string.find(string, (".mangareader.net/" .. _name .. "/" .. tostring(_chapter) .. "/" .. _name .. "-"),1,true)
if a==nil and b==nil then
	return false,false
	end
a,b = string.find(string, (".mangareader.net/" .. _name .. "/" .. tostring(_chapter) .. "/" .. _name .. "-"),b,true)


if a==nil and b==nil then
a,b = string.find(string, (".mangareader.net/" .. _name .. "/" .. tostring(_chapter) .. "/" .. _name .. "-"),1,true)
end

----------------------------


numero=(a+string.len((".mangareader.net/" .. name .. "/" .. tostring(_chapter) .. "/" .. name .. "-")))
stringnumbers=""

while true do
if tonumber(string.sub(string, numero, numero))~=nil then
stringnumbers = (stringnumbers .. string.sub(string, numero, numero))
numero=numero+1
else
break
end
end

if (string.sub(string,a-3,a-3)~="/") then
_subdomain=string.sub(string,a-3,a-1)
else
_subdomain=string.sub(string,a-2,a-1)
end

_currentnumber=tonumber(stringnumbers)

return _currentnumber, _subdomain
end

function downloadmanga()
if (screens==false) then
Controls.disableScreen(TOP_SCREEN)
Controls.disableScreen(BOTTOM_SCREEN)
end
System.createDirectory(savename .. "/")
splitneeded(savename .. "/")

page=2
numpages=1
string=nil
i=nil


string = Network.requestString("http://www.mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/1")

while true do

a,b = string.find(string, ('<option value="/' .. name .. '/' .. tostring(chapter) .. '/' .. tostring(page) .. '"'),1,true)
if a==nil then
break
end
numpages=numpages+1
page=page+1
end

page=1


for i=1,numpages do

Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
Screen.debugPrint(0, 0, ("Downloading page " .. tostring(page) .. "/" .. tostring(numpages)), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 0, ("Subdomain:" .. subdomain), Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 16, ("page:" .. tostring(page)), Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 32, ("currentnumber:" .. tostring(currentnumber)), Color.new(255,255,255), BOTTOM_SCREEN)
Screen.flip()

--[[
status, err = pcall(function()
Network.downloadFile(("http://" .. subdomain .. ".mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/" .. name .. "-" .. tostring(currentnumber) .. ".jpg"),("/Manga/" .. savename .. "/" .. tostring(page) .. ".jpg"))
end)
]]
--if not status then


currentnumber, subdomain = getnumbers(name, chapter, page)
Network.downloadFile(("http://" .. subdomain .. ".mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/" .. name .. "-" .. tostring(currentnumber) .. ".jpg"),(savename .. "/" .. tostring(page) .. ".jpg"))

page=page+1
currentnumber=currentnumber+1
end




if (screens==false) then
Controls.enableScreen(TOP_SCREEN)
Controls.enableScreen(BOTTOM_SCREEN)
end
if doshutdown==true then
end
end



--=================================================================
--=================================================================
--=================================================================


function choosemanga()
folder="/Manga/"
dir={}
dir = System.listDirectory(folder)
selected=1
offset=0
returntotitle=0

if dir[1]==nil then
quickdisplayxy("No manga found in /Manga/",100,100)
System.wait(2000)
returntotitle=1
return
end


while true do
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
pad = Controls.read()

Screen.debugPrint(0, 0, folder, Color.new(0,255,0), BOTTOM_SCREEN)
--Screen.debugPrint(0, 100, tostring(selected), Color.new(0,255,0), BOTTOM_SCREEN)
Screen.debugPrint(0, 16, "Press A to open selected folder as a", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 32, "a manga folder.", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 48, "Press X to open selected folder as a", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 64, "a folder that contains manga folders.", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 80, "Press B to go back a directory.", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, 96, "Press Y to access the mini-menu.", Color.new(255,255,255), BOTTOM_SCREEN)


if #dir<=14 then

for i=1, #dir do
if selected==i then
Screen.debugPrint(0, 16*i, dir[i+offset].name, Color.new(0,255,0), TOP_SCREEN)
else
Screen.debugPrint(0, 16*i, dir[i+offset].name, Color.new(255,255,255), TOP_SCREEN)
end
end

else

for i=1, 14 do
if selected==i then
Screen.debugPrint(0, 16*i, dir[i+offset].name, Color.new(0,255,0), TOP_SCREEN)
else
Screen.debugPrint(0, 16*i, dir[i+offset].name, Color.new(255,255,255), TOP_SCREEN)
end
end

end

if pad~=oldpad then
if (Controls.check(pad,KEY_X)) then
folder=(folder .. (dir[selected+offset].name .. "/"))
dir={}
dir = System.listDirectory(folder)
selected=1
offset=0
if dir[1]==nil then
quickdisplayxy("Nothing found in the folder you entered.",0,0)
System.wait(3000)
folder="/"
dir = System.listDirectory(folder)
end
end

if (Controls.check(pad, KEY_B)) then
oldpad=Controls.read()
for i=2, string.len(folder) do
if string.sub(folder,i*-1,i*-1)=="/" then
folder = string.sub(folder, 0, (i*-1))
break
end
end

dir = System.listDirectory(folder)
selected=1
offset=0
end

if (Controls.check(pad,KEY_A)) then
folder=(folder .. (dir[selected+offset].name .. "/"))
break
end

if (Controls.check(pad,KEY_DUP)) then
selected=selected-1
if selected<1 then
if offset>0 then
offset=offset-1
selected=1
else
if #dir>14 then
selected=14
offset=#dir-14
else
selected=#dir
offset=0
end
end
end
end

if (Controls.check(pad,KEY_DDOWN)) then
if selected==14 then
offset=offset+1
else
selected=selected+1
end
if selected+offset>#dir then
selected=1
offset=0
end
end


if (Controls.check(pad,KEY_START)) then
returntotitle=1
break
end

if (Controls.check(pad,KEY_Y)) then
minimenu()
end


end

Screen.flip()
oldpad = pad
end

end

function mysplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end




function splitneeded(filepath)

a = mysplit(filepath, "/")
if #a<1 then
return
end


for i=1, #a do
astring=""
for h=1, i do
astring = (astring .. "/" .. a[h] )
end
System.createDirectory(astring .. "/")
end
end




function savedloptions()
astring=""

astring = (astring .. name .. ",")
astring = (astring .. chapter .. ",")
astring = (astring .. numpages .. ",")

if screens==true then
astring = (astring .. "1" .. ",")
else
astring = (astring .. "0" .. ",")
end
astring = (astring .. savename .. ",")
if doshutdown==true then
astring = (astring .. "1")
else
astring = (astring .. "0")
end



fileStream = io.open("/MangaReaderDlOptions.cfg",FCREATE)
astring = (tostring(string.len(astring)) .. astring)
io.write(fileStream,0,astring, string.len(astring))
io.close(fileStream)

end
function loaddloptions()
fileStream = (io.open("/MangaReaderDlOptions.cfg",FREAD))

os = io.read(fileStream,2,io.read(fileStream,0,2))
io.close(fileStream)

name,chapter,numpages,screens,savename,doshutdown = os:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
chapter = tonumber(chapter)
numpages = tonumber(numpages)

if screens=="0" then screens=false else screens=true end
if doshutdown=="0" then doshutdown=false else doshutdown=true end


os=nil


end





function minimenu()
menu=0
oldpad=Controls.read()
while true do
pad=Controls.read()
Screen.waitVblankStart()
Screen.refresh()
Screen.clear(BOTTOM_SCREEN)
Screen.debugPrint(16, 0, "Delete selected manga", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(16, 16, "Download next chapter", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(16, 32, "Back", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.debugPrint(0, menu*16, ">", Color.new(255,255,255), BOTTOM_SCREEN)
Screen.flip()

if pad~=oldpad then
if Controls.check(pad,KEY_DUP) then
menu=menu-1
end
if Controls.check(pad,KEY_DDOWN) then
menu=menu+1
end
if Controls.check(pad,KEY_A) then
if menu==0 then
happy = System.listDirectory((folder .. (dir[selected+offset].name .. "/")))
for i=1, #dir do
System.deleteFile(folder .. dir[selected+offset].name .. "/" .. happy[i].name)
end
System.deleteDirectory((folder .. (dir[selected+offset].name)))
happy=nil
dir=System.listDirectory(folder)
return
elseif menu==1 then

elseif menu==2 then
return
end
end

oldpad=pad
end

if menu<0 then menu=2 end
if menu>2 then menu=0 end

end
end








checkoptions()
System.createDirectory("/Manga/")
if (System.doesFileExist("/MangaReaderOptions.cfg")) then
loadoptions()
end
title()

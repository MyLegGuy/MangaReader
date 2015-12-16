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




function downloadmanga(skip)

page=2
numpages=1
string=nil
i=nil
name="yuyushiki"
chapter=math.random(1,5)
subdomain="This won't ever be used."
savename="/Manga/PlzWork"
noobvar=true
currentnumber=0

Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.clear(BOTTOM_SCREEN)
Screen.debugPrint(0, 0, (tostring(page)), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 16, (tostring(chapter)), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 32, (("http://www.mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/1")), Color.new(255,255,255), TOP_SCREEN)
Screen.debugPrint(0, 48, ((name .. "/" .. tostring(chapter) .. "/1")), Color.new(255,255,255), TOP_SCREEN)
Screen.flip()


string = Network.requestString("http://www.mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/1")


if skip==0 then

--while noobvar do
for i=1, 99 do

a,b = string.find(string, ('<option value="/' .. name .. '/' .. tostring(chapter) .. '/' .. tostring(page) .. '"'),1,true)

if a==nil then
break
end
numpages=numpages+1
page=page+1

end


else
numpages=2
page=1
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

currentnumber, subdomain = getnumbers(name, chapter, page)
Network.downloadFile(("http://" .. subdomain .. ".mangareader.net/" .. name .. "/" .. tostring(chapter) .. "/" .. name .. "-" .. tostring(currentnumber) .. ".jpg"),(savename .. "/" .. tostring(page) .. ".jpg"))

page=page+1
currentnumber=currentnumber+1
end

end


downloadmanga(0)
downloadmanga(0)
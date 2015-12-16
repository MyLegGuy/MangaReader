name="the-gamer"
chapter=1
page=1
function noob(time)

Screen.waitVblankStart()
Screen.refresh()
Screen.clear(TOP_SCREEN)
Screen.debugPrint(0, 0, tostring(time), Color.new(255,255,255), TOP_SCREEN)
Screen.flip()


string = Network.requestString("http://www.mangareader.net/the-gamer/1/1")


for i=1, 99 do

a,b = string.find(string, ('a'),1,true)
if i==3 then
	 break
	end
end

end

noob(1)
noob(2)
noob(3)
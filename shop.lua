--[[
V0.9
BETA
Finished touchBeat; Fixed some errors in drawButton(); Fixed some errors in grabItems(); Added the free cobble button; Preparation for Information Panel
]]


--[[
    SIMPLIFY Shop
made by fatmanchummy
----Free to use, do not redistribute
]]


--[[ToDo:
----------IMPORTANTEST THING
INFORMATION DISPLAY TO DISPLAY THE KRIST ADDRESS THAT THE BUYER SHOULD SEND MONEY TO, ALONG WITH OTHER USEFUL INFORMATIONS
----------------------------
Helpfile
Refund stuff
More customization
Single chest rather than modem chests
Updater
Fix them errors
]]


if not fs.exists("w.lua") then
    shell.run("wget","https://raw.githubusercontent.com/justync7/w.lua/master/w.lua","w.lua")
end
if not fs.exists("r.lua") then
    shell.run("wget","https://raw.githubusercontent.com/justync7/r.lua/master/r.lua","r.lua")
end
if not fs.exists("k.lua") then
    shell.run("wget","https://raw.githubusercontent.com/justync7/k.lua/master/k.lua","k.lua")
end
if not fs.exists("json.lua") then
    shell.run("pastebin","get","4nRg9CHU","json.lua")
end
if not fs.exists("jua.lua") then
    shell.run("wget","https://raw.githubusercontent.com/justync7/Jua/master/jua.lua","jua.lua")
end
if not fs.exists("logger") then
    shell.run("wget","https://raw.githubusercontent.com/fatboychummy/Simplify-Shop/master/Logger.lua","logger")
end


local w = require("w")
local r = require("r")
local k = require("k")
os.loadAPI("json.lua")
local json = _G.json
_G.json = nil
local jua = require("jua")
w.init(jua)
r.init(jua)
k.init(jua,json,w,r)



---------------------------------------------------
os.unloadAPI("logger")
os.loadAPI("logger")
logger.openLog()

----------
local fatData = "fatItemData"
local fatCustomization = "fatShopCustomization"
local mon = nil
local mName = nil
local tName = nil
local items = nil
local privKey = nil
local pubKey = nil
local custom = {}
local chests = {}
local sIL = {}
local selection = 1
local page = 1
local mxPages = 1
local mX = 0
local mY = 0
local ws
local buttons = {}
local recentPress = false
local rPressTimer = "nothing to see yet"

if fs.exists(".turtle") then
    local hd = fs.open(".turtle","r")
    tName = hd.readLine()
    hd.close()
else
    local juan = nil
    for k,v in pairs(peripheral.getNames()) do
        if v:find("chest") then juan = v break end
    end
    if not juan then
        error("No chests connected to the network")
    end
    juan = peripheral.wrap(juan)
    local tmp = juan.getTransferLocations()
    for i = 1,#tmp do
        if tmp[i]:find("turtle") then
            tName = tmp[i]
            logger.info("Connected to turtle "..tName)
            break
        end
    end
end

if fs.exists(".monitor") then
    local hd = fs.open(".monitor","r")
    mName = hd.readLine()
    if peripheral.find(mName) then
        mon = peripheral.wrap(mName)
    end
    hd.close()
end

if not mon then
    local pers = peripheral.getNames()
    for i = 1,#pers do
        if peripheral.getType(pers[i]) == "monitor" then
            mName = pers[i]
            mon = peripheral.wrap(pers[i])
        end
    end
    if not mon then
        error("Could not find monitor")
    end
end

logger.info("Connected to monitor "..mName)
mon.setTextScale(0.5)
mX,mY = mon.getSize()


local function writeBlankPrivKey()
    local hd = fs.open(".privKey","w")
    hd.writeLine("--by default, so long as this returns your privateKey and public Krist Address, it will work.")
    hd.writeLine("--  You may use whatever encryption methods.")
    hd.writeLine("--It is recommended to use a different kristWallet than your main, as it may cause problems.")
    hd.writeLine("return false,false")
    hd.close()
    error("Private key not valid.  Edit .privKey to change it.")
end
if not fs.exists(".privKey") then
    writeBlankPrivKey()
else
    privKey,pubKey = dofile(".privKey")
    if type(privKey) ~= "string" or type(pubKey) ~= "string" then
        fs.move(".privKey","badPrivateKey")
        printError("Your old private key has been moved to \"badPrivateKey\"")
        writeBlankPrivKey()
    end
    privKey = k.toKristWalletFormat(privKey)
end



if not fs.exists(fatData) then
    local hd = fs.open(fatData,"w")
    local function ao(a)
        hd.writeLine(a)
    end
    ao("local tmp = {")
    ao("  {")
    ao("    display = \"Iron Ingot\",")
    ao("    price = 1,")
    ao("    find = \"minecraft:iron_ingot\",")
    ao("    damage = 0,")
    ao("  },")
    ao("  {")
    ao("    display = \"Coal\",")
    ao("    price = 0.2,")
    ao("    find = \"minecraft:coal\",")
    ao("    damage = 0,")
    ao("  },")
    ao("  {")
    ao("    display = \"Charcoal\",")
    ao("    price = 0.1,")
    ao("    find = \"minecraft:coal\",")
    ao("    damage = 1,")
    ao("  },")
    ao("}")
    ao("return tmp")
    --hd.write(textutils.serialise(tmp))
    hd.close()
    logger.warn("file "..fatData.." does not exist, wrote default item data.")
    items = dofile(fatData)
else
    items = dofile(fatData)
    logger.info("Items found in data: "..#items)
end



function refund(to,amt,rsn)
    local success,err = await(k.makeTransaction,privKey,to,amt,rsn and "message="..rsn or "message=Unknown error occured, take your money back")
    if not success then
        logger.severe("Failed to send refund")
        print(textutils.serialise(err))
        error("Failed to refund money due to "..err.error)
    else
        logger.info("Sent refund")
    end
end


--get user preferences
local function writeCustomization(name)
    local hd = fs.open(name,"w")
    local function ao(txt)
        hd.writeLine(txt)
    end
    ao("data = {")
    ao("  LOGGER = {")
    ao("    doInfoLogging = false,")
    ao("    doWarnLogging = true,")
    ao("    LOG_LOCATION = \"logs\",")
    ao("    LOG_NAME = \"Log\",")
    ao("  },")
    ao("  owner = \"nobody\",")
    ao("  shopName = \"Unnamed Shop\",")
    ao("  showCustomInfo = true,")
    ao("  customInfo = {")
    ao("    [ 1 ] = \"Edit customInfo variable to change me\",")
    ao("    [ 2 ] = \"Up to two lines are permitted\",")
    ao("  },")
    ao("  showCustomBigInfo = false,")
    ao("  customBigInfo = {")
    ao("    [ 1 ] = \"Edit customBigInfo variable to change me\",")
    ao("    [ 2 ] = \"the word PUBKEY will be translated\",")
    ao("    [ 3 ] = \"to your public krist address.\",")
    ao("    [ 4 ] = \"Up to four lines are permitted\",")
    ao("  },")
    ao("  touchHereForCobbleButton = true,")
    ao("  dropSide = \"top\", -- the side the turtle will drop from, accepts 'top', 'bottom', and 'front'")
    ao("  itemsDrawnAtOnce = 7,")
    ao("  farthestBackground = {")
    ao("    bg = colors.black,")
    ao("  },")
    ao("  background = {")
    ao("    bg = colors.gray,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  nameBar = {")
    ao("    bg = colors.purple,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  itemInfoBar = {")
    ao("    bg = colors.blue,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  infoBar = {")
    ao("    bg = colors.purple,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  buttons = {")
    ao("    bg = colors.blue,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  disabledButtons = {")
    ao("    bg = colors.lightGray,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  selection = {")
    ao("    bg = colors.white,")
    ao("    fg = colors.black,")
    ao("  },")
    ao("  bigSelection = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  bigInfo = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  itemTableColor1 = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  itemTableColor2 = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("}")
    ao("return data")
    hd.close()
end

if not fs.exists(fatCustomization) then
    writeCustomization(fatCustomization)
    logger.warn("No customization file, wrote default customization file.")
    custom = dofile(fatCustomization)
else
    custom = dofile(fatCustomization)
end

function checkCustomization()
    logger.info("Checking Customization file")
    writeCustomization(".temp")
    local c2 = dofile(".temp")
    fs.delete(".temp")
    if type(custom) ~= "table" then
        logger.severe("Customization file should return a table")
        error()
    end
    local function typeWarn(k,exp)
        logger.severe(k..": expected "..exp..", got "..type(custom[k]))
    end
    for k,v in pairs(c2) do
        if type(v) ~= type(custom[k]) then
            typeWarn(k,type(v))
        end
        if type(v) == "table" then
            for k2,v2 in pairs(v) do
                if type(custom[k]) == "table" then
                    if type(v2) ~= type(custom[k][k2]) then
                        logger.severe("Table "..k.."'s item '"..k2.."' should be of type "..type(v)..", but is of type "..type(custom[k][k2]))
                    end
                end
            end
        end
    end
    return true
end

function checkData()
    logger.info("Checking items, "..#items)
    if type(items) ~= "table" then
        logger.severe("Item file should return a table!")
    end
    for i = 1,#items do
        if type(items[i]) ~= "table" then
            logger.severe("Each item should be a table of four keys, #"..i..": got "..type(items[i])..", expected table")
        else
            local c = items[i]
            local function typeWarn(k,exp)
                logger.severe("Item #"..i.."'s "..k..": expected "..exp..", got "..type(c[k])..".")
            end
            if type(c.display) ~= "string" then
                typeWarn("display","string")
            end
            if type(c.price) ~= "number" then
                typeWarn("price","number")
            end
            if type(c.find) ~= "string" then
                typeWarn("find","string")
            end
            if type(c.damage) ~= "number" then
                typeWarn("damage","number")
            end
        end
    end
    return true
end

function checkAllTheThings()
    checkCustomization()
    checkData()
end



--------begin inventory and monitor manip

function refreshChests()
    chests = {}
    local allPs = peripheral.getNames()
    for i = 1,#allPs do
        if allPs[i]:find("chest") then
            table.insert(chests,allPs[i])
        end
    end
end

function sortItems()
    sIL = {}
    local a = #items
    for i = 1,a do
        local smallestIndex = a --because why the fuck does this error if I dont
        while items[smallestIndex] == nil do
            smallestIndex = smallestIndex - 1
        end
        for o = a,1,-1 do
            if items[o] ~= nil and items[o].display < items[smallestIndex].display then
                smallestIndex = o
            end
        end
        if smallestIndex ~= -1 then
            sIL[i] = {}
            for k,v in pairs(items[smallestIndex]) do
                sIL[i][k] = v
            end
            items[smallestIndex] = nil
        end
    end
end

function refreshItems()
    refreshChests()
    for i = 1,#sIL do
        sIL[i].count = 0
    end
    for i = 1,#chests do
        local cChest = peripheral.wrap(chests[i])
        local cInv = cChest.list()
        for o = 1,cChest.size() do
            if cInv[o] then
                for p = 1,#sIL do
                    if cInv[o].name == sIL[p].find and cInv[o].damage == sIL[p].damage then
                        sIL[p].count = sIL[p].count + cInv[o].count
                    end
                end
            end
        end
    end
end

function grabItems(name,dmg,count)
  refreshChests()
  local amountTransfered = 0
  if count ~= 0 then
    for i = 1,#chests do
      local cChest = peripheral.wrap(chests[i])
      local cur = cChest.list()
      local sz = cChest.size()
      for o = 1,sz do
        if cur[o] and cur[o].name == name and cur[o].damage == dmg then
          if count-amountTransfered > 0 then
            amountTransfered = amountTransfered + cChest.pushItems(tName,o,count-amountTransfered)
          end
          if custom.dropSide == "top" then
            turtle.dropUp()
          elseif custom.dropSide == "bottom" then
            turtle.dropDown()
          elseif custom.dropSide == "front" then
            turtle.drop()
          else
            logger.severe("dropSide not configured correctly, dropping from the front.")
            turtle.drop()
          end
          if amountTransfered == count then
            break
          end
        end
        if amountTransfered == count then
          break
        end
      end
    end
  end
  return amountTransfered
end

function getPages()
    mxPages = math.ceil(#sIL/custom.itemsDrawnAtOnce)
end

--Monitor
function draw(sel,first)
    if first then
        mon.setBackgroundColor(custom.farthestBackground.bg)
        mon.clear()
        square(2,4,mX-1,mY-4,custom.background.bg)
        square(2,1,mX-1,3,custom.nameBar.bg)
        mon.setCursorPos(mX/2-(custom.shopName:len()/2),2)
        mon.write(custom.shopName)
        square(2,mY-3,mX-1,mY,custom.infoBar.bg)
        if not custom.showCustomInfo then
            local ln1 = "This shop was made by fatmanchummy"
            local ln2 = "This shop is owned by "..custom.owner
            mon.setCursorPos(mX/2-(ln1:len()/2),mY-2)
            mon.write(ln1)
            mon.setCursorPos(mX/2-(ln2:len()/2),mY-1)
            mon.write(ln2)
        else
            if type(custom.customInfo[1]) == "string" then
                mon.setCursorPos(mX/2-(custom.customInfo[1]:len()/2),mY-2)
                mon.write(custom.customInfo[1])
                if type(custom.customInfo[2]) == "string" then
                    mon.setCursorPos(mX/2-(custom.customInfo[2]:len()/2),mY-1)
                    mon.write(custom.customInfo[2])
                end
            end
        end
    end

    local toDraw = custom.itemsDrawnAtOnce
    getPages()
    square(3,5,mX/2+3,7,custom.itemInfoBar.bg)
    mon.setTextColor(custom.itemInfoBar.fg)
    mon.setCursorPos(4,6)
    mon.write("Item")
    mon.setCursorPos(mX/3-5,6)
    mon.write("Stock")
    mon.setCursorPos(mX/2-2,6)
    mon.write("Price")
    square(3,8,mX/2+3,8+toDraw,custom.background.bg)
    for i = 1,toDraw do
      local cur = i+(#sIL-1)*(page-1)
      cur = sIL[cur]
      if cur then
        if i%2 == 1 then
          square(3,i+7,mX/2+3,i+7,custom.itemTableColor1.bg)
          mon.setTextColor(custom.itemTableColor1.fg)
        else
          square(3,i+7,mX/2+3,i+7,custom.itemTableColor2.bg)
          mon.setTextColor(custom.itemTableColor2.fg)
        end
        mon.setCursorPos(4,i+7)
        mon.write(cur.display)
        mon.setCursorPos(mX/3-tostring(cur.count):len(),i+7)
        mon.write(tostring(cur.count))
        local a = tostring(cur.price):find("%.")
        mon.setCursorPos(mX/2,i+7)
        mon.write(".00")
        if a then
          mon.setCursorPos(mX/2+a-3,i+7)
        else
          mon.setCursorPos(mX/2-1-(tostring(cur.price):len()/2)+0.5,i+7)
        end
        mon.write(tostring(cur.price))
      end
    end
    if page == mxPages then
      buttons.pgUp.enabled = false
    else
      buttons.pgUp.enabled = true
    end
    if page == 1 then
      buttons.pgDwn.enabled = false
    else
      buttons.pgDwn.enabled = true
    end
    drawButton(buttons.pgUp)
    drawButton(buttons.pgDwn)
    if sel then
      local i = sel-7
      selection = i+(page-1)*(#sIL-1)
      local cur = sIL[selection]
      square(3,sel,mX/2+3,sel,custom.selection.bg)
      mon.setTextColor(custom.selection.fg)
      mon.setCursorPos(4,i+7)
      mon.write(cur.display)
      mon.setCursorPos(mX/3-tostring(cur.count):len(),i+7)
      mon.write(tostring(cur.count))
      local a = tostring(cur.price):find("%.")
      mon.setCursorPos(mX/2,i+7)
      mon.write(".00")
      if a then
        mon.setCursorPos(mX/2+a-3,i+7)
      else
        mon.setCursorPos(mX/2-1-(tostring(cur.price):len()/2)+0.5,i+7)
      end
      mon.write(tostring(cur.price))
    end
    square(mX/2+5,8,mX-5,16,custom.bigInfo.bg)
    mon.setTextColor(custom.bigInfo.fg)
    mon.setCursorPos((3*mX)/4-6,9)
    mon.write("Information")
    if custom.showCustomBigInfo then
      for i = 1,4 do
        custom.customBigInfo[i] = custom.customBigInfo[i]:gsub("PUBKEY",pubKey)
      end
      mon.setCursorPos((3*mX)/4-custom.customBigInfo[1]:len()/2,11)
      mon.write(custom.customBigInfo[1])
      mon.setCursorPos((3*mX)/4-custom.customBigInfo[2]:len()/2,12)
      mon.write(custom.customBigInfo[2])
      mon.setCursorPos((3*mX)/4-custom.customBigInfo[3]:len()/2,13)
      mon.write(custom.customBigInfo[3])
      mon.setCursorPos((3*mX)/4-custom.customBigInfo[4]:len()/2,14)
      mon.write(custom.customBigInfo[4])
    else
      local ln1 = "This shop's address is:"
      local ln2 = pubKey
      local ln3 = "Send Krist to this address after"
      local ln4 = "selecting an item to buy."
      mon.setCursorPos((3*mX)/4-ln1:len()/2,11)
      mon.write(ln1)
      mon.setCursorPos((3*mX)/4-ln2:len()/2,12)
      mon.write(ln2)
      mon.setCursorPos((3*mX)/4-ln3:len()/2,13)
      mon.write(ln3)
      mon.setCursorPos((3*mX)/4-ln4:len()/2,14)
      mon.write(ln4)
    end

    if custom.touchHereForCobbleButton then
      buttons.cobble.enabled = true
      drawButton(buttons.cobble)
    end
end

function square(x1,y1,x2,y2,c)
    if c then
        mon.setBackgroundColor(c)
    end
    local dist = x2-x1+1
    dist = string.rep(" ",dist)
    for i = y1,y2 do
        mon.setCursorPos(x1,i)
        mon.write(dist)
    end
end

function inBetween(x1,y1,x2,y2,x,y)
    return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

buttons = {
    cobble = {
      x1 = 29,
      y1 = mY-7,
      x2 = 41,
      y2 = mY-5,
      content = "Free Cobble",
      enabled = false,
    },
    pgUp = {
        x1 = 17,
        y1 = mY-7,
        x2 = 27,
        y2 = mY-5,
        content = "Next Page",
        enabled = false,
    },
    pgDwn = {
        x1 = 5,
        y1 = mY-7,
        x2 = 15,
        y2 = mY-5,
        content = "Prev Page",
        enabled = false,
    },
}
function drawButton(BUTT)
    if BUTT.enabled then
        mon.setBackgroundColor(custom.buttons.bg)
        mon.setTextColor(custom.buttons.fg)
    else
        mon.setBackgroundColor(custom.disabledButtons.bg)
        mon.setTextColor(custom.disabledButtons.fg)
    end
    local dist = BUTT.x2 - BUTT.x1+1
    dist = string.rep(" ",dist)
    for o = BUTT.y1,BUTT.y2 do
        mon.setCursorPos(BUTT.x1,o)
        mon.write(dist)
    end
    mon.setCursorPos(BUTT.x1+(BUTT.x2-BUTT.x1)/2-(BUTT.content:len()/2)+0.5,BUTT.y1+(BUTT.y2-BUTT.y1)/2)
    mon.write(BUTT.content)
end
function whichPress(x,y)
    for k,v in pairs(buttons) do
        if v.enabled and inBetween(v.x1,v.y1,v.x2,v.y2,x,y) then
            return k
        end
    end
    return "None"
end


-------------BEGIN-------------
checkAllTheThings()
sortItems()
refreshItems()

jua.on("timer",function(evt,tmr)
  if tmr == rPressTimer then
    recentPress = false
    logger.info("30 second timer expired.")
    selection = false
  end
end)

jua.on("monitor_resize",function()
    mX,mY = mon.getSize()
    draw(nil,true)
end)

jua.on("monitor_touch",function(nm,side,x,y)
    if side == mName then
        logger.info("Started 30 second timer, there was a touch to the monitor.")
        recentPress = true
        rPressTimer = os.startTimer(30)
        local pressed = whichPress(x,y)
        local max = #sIL
        if inBetween(3,8,mX/2+3,8+custom.itemsDrawnAtOnce,x,y) then
          draw(y)
        end

        if pressed == "pgUp" then
          page = page + 1
          draw()
        elseif pressed == "pgDwn" then
          page = page - 1
          draw()
        elseif pressed == "cobble" then
          grabItems("minecraft:cobblestone",0,64)
        end
    end
end)



function mainJua()
jua.setInterval(function()
  logger.info("Redraw")
  if not recentPress then
    refreshItems()
    draw()
  end
end,30)

jua.on("terminate",function()
  if ws then ws.close() end
  jua.stop()
  bsod("Terminated")
  logger.severe("Ah fuck we've been terminated")
  logger.closeLog()
  printError("I can't believe you've done this.")
end)


jua.go(function()
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.clear()
    mon.setCursorPos(1,1)
    mon.write("We're setting things up")
    draw(nil,true)
    local success,ws = await(k.connect,privKey)
    if success then
        logger.info("Connected to websocket")
        ws.on("hello",function(data)
            logger.info("MOTD: "..data.motd)
            local success = await(ws.subscribe,"transactions",function(data)
                local tx = data.transaction
                --if tx.from ~= pubKey then
                logger.info("Payment to: "..tx.to.." (we are "..pubKey..")")
                local meta = nil
                if tx.metadata then
                    meta = k.parseMeta(tx.metadata)
                end
                if not meta.meta["return"] and tx.to == pubKey then
                    refund(tx.from,tx.value,"Use /pay, do not transfer directly from another address.")
                end
                if selection and tx.to == pubKey then
                    logger.info("Payment being processed.")
                    local item = sIL[selection]
                    if item.count > 0 then
                      local paid = tx.value
                      local items_required = math.floor(paid/item.price)
                      local items_grabbed = grabItems(item.find,item.damage,items_required)
                      local over = paid%item.price
                      local refundAmt = math.floor((items_required - items_grabbed)*item.price+over)
                      if item.price > paid then
                        refund(meta.meta["return"],tx.value,"You seem to have underpaid.")
                      else
                        if refundAmt > 0 then
                          refund(meta.meta["return"],refundAmt,"Here is your change.")
                          logger.info("Sent refund of "..refundAmt.." due to overpay.")
                        end
                      end
                    else
                      refund(meta.meta["return"],tx.value,"We seem to have run out of that item!")
                      logger.warn("Sent refund of "..tx.value.." due to not having the item selected.")
                    end
                else
                    if tx.to == pubKey then
                        logger.warn("No item selected, but we were payed!  Returning...")
                        if meta.meta["return"] then
                            refund(meta.meta["return"],tx.value,"There is no item selected.")

                        end
                    end
                end
                --end
            end)
            logger.ree()
            if success then
                logger.info("Subscribed to transactions")
            else
                jua.stop()
                logger.severe("Failed to subscribe")
                error()
            end
        end)
    else
        jua.stop()
        logger.severe("Failed to connect to kriststuff")
        error()
    end
end)
end

--------------------------
local function writeLine(txt)
    local bX,bY = mon.getCursorPos()
    mon.write(txt)
    mon.setCursorPos(1,bY+1)
end
function bsod(err)
    mon.setTextScale(0.5)
    mon.setBackgroundColor(colors.blue)
    mon.clear()
    local mxX,mxY = mon.getSize()
    mon.setCursorPos(1,mxY/2)
    writeLine("The shop encountered an error it could not recover from")
    writeLine(err)
end




local suc,err = pcall(mainJua)

if not suc then
    logger.severe(err)
    bsod(err)
    logger.closeLog()
    if err ~= "Terminated" then
      writeLine("Reboot in 30 seconds.")
      os.sleep(30)
      os.reboot()
    end
end

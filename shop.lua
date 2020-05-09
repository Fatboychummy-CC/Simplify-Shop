--[[
18
Increase version number to stop update check


    SIMPLIFY Shop
made by fatmanchummy
----https://github.com/Fatboychummy-CC/Simplify-Shop/blob/master/LICENSE
]]

local version = 18
local tArgs = {...}

local params = {
  "setupText",
  "setupVisuals",
}
shell.setCompletionFunction(shell.getRunningProgram(),
function(shell,par,cur)
  if par == 1 then
    local res = {}
    for i = 1,#params do
      if params[i]:sub(1,#cur) == cur then
        res[#res+1] = params[i]:sub(#cur+1)
      end
    end
    return res
  end
  return {}
end
)




if not fs.exists("w.lua") then
  shell.run("wget","https://raw.githubusercontent.com/justync7/w.lua/master/w.lua")
end
if not fs.exists("r.lua") then
  shell.run("wget","https://raw.githubusercontent.com/justync7/r.lua/master/r.lua")
end
if not fs.exists("k.lua") then
  shell.run("wget","https://raw.githubusercontent.com/justync7/k.lua/master/k.lua")
end
if not fs.exists("json.lua") then
  shell.run("pastebin","get","4nRg9CHU","json.lua")
end
if not fs.exists("jua.lua") then
  shell.run("wget","https://raw.githubusercontent.com/justync7/Jua/master/jua.lua")
end
if not fs.exists("Logger.lua") then
  shell.run("wget https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop/master/Logger.lua Logger.lua")
end

------CHECK FOR UPDATES
os.unloadAPI("Logger.lua")
os.loadAPI("Logger.lua")
local logger = Logger
if true then
  local didUpdate = false
  local handle = http.get("https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop/master/shop.lua")
  handle.readLine()
  local v = tonumber(handle.readLine())
  local notes = handle.readLine()
  if v < version then
    print(v,"<",version)
  elseif v == version then
    print(v,"=",version)
  else
    print(v,">",version)
  end
  handle.close()
  if v > version then
    print("There is an update available.")
    print("Update notes: ")
    print("--------------------------------")
    print(notes)
    print("--------------------------------")
    print("Would you like to do the update now? (Y/N)")
    local utm = os.startTimer(30)
    while true do
      local a = {os.pullEvent()}
      if a[1] == "char" then
        if a[2] == "y" then
          fs.delete(shell.getRunningProgram())
          shell.run("wget https://raw.githubusercontent.com/Fatboychummy-CC/Simplify-Shop/master/shop.lua startup")
          print("Update complete.")
          didUpdate = true
          break
        elseif a[2] == "n" then
          break
        end
      elseif a[1] == "timer" and a[2] == utm then
        break
      end
    end
    if not didUpdate then
      print("Timed out or skipping update.")
    end
  else
    print("Up to date.")
  end

  if logger.isUpdate(version) then
    if logger.update() then
      didUpdate = true
    end
  else
    logger.info("Logger is up to date.")
  end


  if didUpdate then
    print("Rebooting.")
    os.sleep(2)
    os.reboot()
  end
end
------END

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

if logger.canLogBeOpened then
  logger.openLog()
end
if logger.canPurchaseLogBeOpened then
  logger.openPurchaseLog()
end


local function checkKristAddress(a)
  return k.makev2address(k.toKristWalletFormat(a))
end


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
local selection = false
local recentPressCount = 0
local oldY = 0
local oldNotice = "no"
local page = 1
local mxPages = 1
local mX = 0
local mY = 0
local ws
local buttons = {}
local recentPress = false
local recentNotice = false
local purchaseTimer = "nothing to see yet"
local cobCount = 0
local chatEvent = "chat_message"
local function chatFunc(event, player, message, uuid)
  return message
end

local function fixCustomization(key)
  logger.info("Attempting to fix customization file.")
  local hand = "h"
  local function ao(a)
    hand.writeLine(a)
    hand.flush()
  end
  local function chk(a)
    return type(a) == "table"
  end
  local clr = {
    [1] = "colors.white",
    [2] = "colors.orange",
    [4] = "colors.magenta",
    [8] = "colors.lightBlue",
    [16] = "colors.yellow",
    [32] = "colors.lime",
    [64] = "colors.pink",
    [128] = "colors.gray",
    [256] = "colors.lightGray",
    [512] = "colors.cyan",
    [1024] = "colors.purple",
    [2048] = "colors.blue",
    [4096] = "colors.brown",
    [8192] = "colors.green",
    [16384] = "colors.red",
    [32768] = "colors.black",
  }
  hand = fs.open(fatCustomization,"w")

  if chk(custom) then
    ao("data = {")
    ao(custom.owner and "  owner = \""..custom.owner.."\"," or "  owner = \"Nobody\",")
    ao(custom.shopName and "  shopName = \""..custom.shopName.."\"," or  "  shopName = \"Unnamed Shop\",")
    ao(type(custom.drawBottomInfoBar) == "boolean" and "  drawBottomInfoBar = "..tostring(custom.drawBottomInfoBar).."," or "  drawBottomInfoBar = true,")
    ao(type(custom.showCustomInfo) == "boolean" and "  showCustomInfo = "..tostring(custom.showCustomInfo).."," or "  showCustomInfo = true,")
    ao("  customInfo = {")
    if chk(custom.customInfo) then
      ao((custom.customInfo and custom.customInfo[1]) and "    [ 1 ] = \"" .. custom.customInfo[1] .. "\"," or "    [ 1 ] = \"Edit customInfo variable to change me\",")
      ao((custom.customInfo and custom.customInfo[2]) and "    [ 2 ] = \"" .. custom.customInfo[2] .. "\"," or "    [ 2 ] = \"Up to two lines are permitted\",")
    else
      ao("    [ 1 ] = \"Edit customInfo variable to change me\",")
      ao("    [ 2 ] = \"Up to two lines are permitted\",")
    end
    ao("  },")
    ao(type(custom.showCustomBigInfo) == "boolean" and "  showCustomBigInfo = "..tostring(custom.showCustomBigInfo).."," or "  showCustomBigInfo = false,")
    ao("  customBigInfo = {")
    if chk(custom.customBigInfo) then
      ao((custom.customBigInfo and custom.customBigInfo[1]) and "    [ 1 ] = \""..custom.customBigInfo[1].."\"," or "    [ 1 ] = \"Edit customBigInfo variable to change me\",")
      ao((custom.customBigInfo and custom.customBigInfo[2]) and "    [ 2 ] = \""..custom.customBigInfo[2].."\"," or "    [ 2 ] = \"the word PUBKEY will be translated\",")
      ao((custom.customBigInfo and custom.customBigInfo[3]) and "    [ 3 ] = \""..custom.customBigInfo[3].."\"," or "    [ 3 ] = \"to your public krist address.\",")
      ao((custom.customBigInfo and custom.customBigInfo[4]) and "    [ 4 ] = \""..custom.customBigInfo[4].."\"," or "    [ 4 ] = \"Up to four lines are permitted\",")
    else
      ao("    [ 1 ] = \"Edit customBigInfo variable to change me\",")
      ao("    [ 2 ] = \"the word PUBKEY will be translated\",")
      ao("    [ 3 ] = \"to your public krist address.\",")
      ao("    [ 4 ] = \"Up to four lines are permitted\",")
    end
    ao("  },")
    ao(type(custom.touchHereForCobbleButton) == "boolean" and "  touchHereForCobbleButton = "..tostring(custom.touchHereForCobbleButton).."," or "  touchHereForCobbleButton = true,")
    ao(custom.dropSide and "  dropSide = \""..custom.dropSide.."\", -- the side the turtle will drop from, accepts 'top', 'bottom', and 'front'" or "  dropSide = \"unset\", -- the side the turtle will drop from, accepts 'top', 'bottom', and 'front'")
    ao(custom.itemsDrawnAtOnce and "  itemsDrawnAtOnce = "..tostring(custom.itemsDrawnAtOnce).."," or "  itemsDrawnAtOnce = 7,")
    ao(type(custom.useBothChestTypes) == "boolean" and "  useBothChestTypes = "..tostring(custom.useBothChestTypes).."," or "  useBothChestTypes = false,")
    ao(type(custom.useSingleChest) == "boolean" and "  useSingleChest = "..tostring(custom.useSingleChest)..", --if useBothChestTypes is true, this value does not matter.  If useBothChestTypes is false, and there is a network attached, the turtle will ignore everything except the single chest." or "  useSingleChest = false, --if useBothChestTypes is true, this value does not matter.  If useBothChestTypes is false, and there is a network attached, the turtle will ignore everything except the single chest.")
    ao(custom.chestSide and "  chestSide = \""..custom.chestSide.."\",--You can use a single chest attached to a network by typing it's network name here (eg: \"minecraft:chest_666\")" or "  chestSide = \"bottom\",--You can use a single chest attached to a network by typing it's network name here (eg: \"minecraft:chest_666\")")
    ao(type(custom.doPurchaseForwarding) == "boolean" and "  doPurchaseForwarding = "..tostring(custom.doPurchaseForwarding).."," or "  doPurchaseForwarding = false," )
    ao(custom.purchaseForwardingAddress and "  purchaseForwardingAddress = \""..custom.purchaseForwardingAddress.."\"," or "  purchaseForwardingAddress = \"fakeAddress\"," )
    ao(type(custom.compactMode) == "boolean" and "  compactMode = "..tostring(custom.compactMode).."," or "  compactMode = false,")
    ao("  farthestBackground = {")
    if chk(custom.farthestBackground) then
      ao(custom.farthestBackground.bg and "    bg = "..clr[custom.farthestBackground.bg].."," or "    bg = colors.black,")
    else
      ao("    bg = colors.black,")
    end
    ao("  },")
    ao("  background = {")
    if chk(custom.background) then
      ao(custom.background.bg and "    bg = "..clr[custom.background.bg].."," or "    bg = colors.gray,")
      ao(custom.background.fg and "    fg = "..clr[custom.background.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.gray,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  nameBar = {")
    if chk(custom.nameBar) then
      ao(custom.nameBar.bg  and "    bg = "..clr[custom.nameBar.bg].."," or "    bg = colors.purple,")
      ao(custom.nameBar.fg  and "    fg = "..clr[custom.nameBar.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.purple,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  itemInfoBar = {")
    if chk(custom.itemInfoBar) then
      ao(custom.itemInfoBar.bg  and "    bg = "..clr[custom.itemInfoBar.bg].."," or "    bg = colors.blue,")
      ao(custom.itemInfoBar.fg  and "    fg = "..clr[custom.itemInfoBar.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.blue,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  infoBar = {")
    if chk(custom.infoBar) then
      ao(custom.infoBar.bg  and "    bg = "..clr[custom.infoBar.bg].."," or "    bg = colors.purple,")
      ao(custom.infoBar.fg  and "    fg = "..clr[custom.infoBar.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.purple,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  buttons = {")
    if chk(custom.buttons) then
      ao(custom.buttons.bg  and "    bg = "..clr[custom.buttons.bg].."," or "    bg = colors.blue,")
      ao(custom.buttons.fg  and "    fg = "..clr[custom.buttons.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.blue,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  disabledButtons = {")
    if chk(custom.disabledButtons) then
      ao(custom.disabledButtons.bg  and "    bg = "..clr[custom.disabledButtons.bg].."," or "    bg = colors.lightGray,")
      ao(custom.disabledButtons.fg  and "    fg = "..clr[custom.disabledButtons.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.lightGray,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  selection = {")
    if chk(custom.selection) then
      ao(custom.selection.bg  and "    bg = "..clr[custom.selection.bg].."," or "    bg = colors.white,")
      ao(custom.selection.fg  and "    fg = "..clr[custom.selection.fg].."," or "    fg = colors.black,")
    else
      ao("    bg = colors.white,")
      ao("    fg = colors.black,")
    end
    ao("  },")
    ao("  bigSelection = {")
    if chk(custom.bigSelection) then
      ao(custom.bigSelection.bg  and "    bg = "..clr[custom.bigSelection.bg].."," or "    bg = colors.black,")
      ao(custom.bigSelection.bg  and "    fg = "..clr[custom.bigSelection.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  selectedEmptyStock = {")
    if chk(custom.selectedEmptyStock) then
      ao(custom.selectedEmptyStock.bg and "   bg = "..clr[custom.selectedEmptyStock.bg].."," or "   bg = colors.red,")
      ao(custom.selectedEmptyStock.fg and "   fg = "..clr[custom.selectedEmptyStock.fg].."," or "   fg = colors.white,")
    else
      ao("    bg = colors.red,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  bigSelectionEmptyStock = {")
    if chk(custom.bigSelectionEmptyStock) then
      ao(custom.bigSelectionEmptyStock.bg and "   bg = "..clr[custom.bigSelectionEmptyStock.bg].."," or "   bg = colors.red,")
      ao(custom.bigSelectionEmptyStock.fg and "   fg = "..clr[custom.bigSelectionEmptyStock.fg].."," or "   fg = colors.white,")
    else
      ao("    bg = colors.red,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  bigInfo = {")
    if chk(custom.bigInfo) then
      ao(custom.bigInfo.bg  and "    bg = "..clr[custom.bigInfo.bg].."," or "    bg = colors.black,")
      ao(custom.bigInfo.fg  and "    fg = "..clr[custom.bigInfo.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  itemTableColor1 = {")
    if chk(custom.itemTableColor1) then
      ao(custom.itemTableColor1.bg  and "    bg = "..clr[custom.itemTableColor1.bg].."," or "    bg = colors.black,")
      ao(custom.itemTableColor1.bg  and "    fg = "..clr[custom.itemTableColor1.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  itemTableColor2 = {")
    if chk(custom.itemTableColor2) then
      ao(custom.itemTableColor2.bg  and "    bg = "..clr[custom.itemTableColor2.bg].."," or "    bg = colors.black,")
      ao(custom.itemTableColor2.fg  and "    fg = "..clr[custom.itemTableColor2.fg].."," or "    fg = colors.white,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.white,")
    end
    ao("  },")
    ao("  itemTableEmptyStock1 = {")
    if chk(custom.itemTableEmptyStock1) then
      ao(custom.itemTableEmptyStock1.bg and "    bg = "..clr[custom.itemTableEmptyStock1.bg].."," or "    bg = colors.black,")
      ao(custom.itemTableEmptyStock1.fg and "    fg = "..clr[custom.itemTableEmptyStock1.fg].."," or "    fg = colors.red,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.red,")
    end
    ao("  },")
    ao("  itemTableEmptyStock2 = {")
    if chk(custom.itemTableEmptyStock2) then
      ao(custom.itemTableEmptyStock2.bg and "    bg = "..clr[custom.itemTableEmptyStock2.bg].."," or "    bg = colors.black,")
      ao(custom.itemTableEmptyStock2.fg and "    fg = "..clr[custom.itemTableEmptyStock2.fg].."," or "    fg = colors.red,")
    else
      ao("    bg = colors.black,")
      ao("    fg = colors.red,")
    end
    ao("  },")
    ao("  chatty = {")
    if chk(custom.chatty) then
      ao(type(custom.chatty.enabled) == "boolean" and custom.chatty.enabled and "    enabled = true," or "    enabled = false,")
      ao(custom.chatty.prefix and "    prefix = \"" .. custom.chatty.prefix .. "\"," or "    prefix = \"shop" .. math.random(100000, 999999) .. "\",")
      ao(type(custom.chatty.showNotice) == "boolean" and custom.chatty.showNotice and "    showNotice = true," or type(custom.chatty.showNotice) == "boolean" and "    showNotice = false," or "    showNotice = true,")
      ao("    -- change the above value if you state that chatty is enabled elsewhere (like in big info or bottom info bar)")
      ao(custom.chatty.noticeFG and "    noticeFG = " .. custom.chatty.noticeFG .. "," or "    noticeFG = colors.white,")
      ao(custom.chatty.noticeFG and "    noticeBG = " .. custom.chatty.noticeBG .. "," or "    noticeBG = colors.black,")
      ao("    -- the above are the colors of the notice that displays just above the bottom info bar.")
      ao(custom.chatty.infoFG and "    infoFG = " .. custom.chatty.infoFG .. "," or "    infoFG = colors.white,")
      ao(custom.chatty.infoBG and "    infoBG = " .. custom.chatty.infoBG .. "," or "    infoBG = colors.red,")
      ao("    -- the above are the colors of the popup when someone chats something and chatty reacts.")
    else
      ao("    enabled = false,")
      ao("    prefix = \"shop" .. math.random(100000, 999999) .. "\",")
      ao("    showNotice = true,")
      ao("    -- change the above value if you state that chatty is enabled elsewhere (like in big info or bottom info bar)")
      ao("    noticeFG = colors.white,")
      ao("    noticeBG = colors.black,")
      ao("    -- the above are the colors of the notice that displays just above the bottom info bar.")
      ao("    infoFG = colors.white,")
      ao("    infoBG = colors.red,")
      ao("    -- the above are the colors of the popup when someone chats something and chatty reacts.")
    end
    ao("  },")
    ao("  REFUNDS = {")
    if chk(custom.REFUNDS) then
      ao(custom.REFUNDS.noItemSelected and "    noItemSelected = \""..custom.REFUNDS.noItemSelected.."\"," or "    noItemSelected = \"There is no item selected!\",")
      ao(custom.REFUNDS.underpay and "    underpay = \""..custom.REFUNDS.underpay .."\"," or "    underpay = \"You seem to have underpaid.\",")
      ao(custom.REFUNDS.change and "    change = \""..custom.REFUNDS.change .."\"," or "    change = \"You overpaid by a small amount, here's your change!\",")
      ao(custom.REFUNDS.outOfStock and "    outOfStock = \""..custom.REFUNDS.outOfStock .."\"," or "    outOfStock = \"We do not have any stock of that item!\",")
      ao(custom.REFUNDS.UPDATE and "    UPDATE = \""..custom.REFUNDS.UPDATE.."\"," or "    UPDATE = \"The shop is updating it's stocks and an error occured!\",")
    else
      ao("    noItemSelected = \"There is no item selected!\",")
      ao("    underpay = \"You seem to have underpaid.\",")
      ao("    change = \"You overpaid by a small amount, here's your change.\",")
      ao("    outOfStock = \"We do not have any stock of that item!\",")
      ao("    UPDATE = \"The shop is updating it's stocks and an error occured!\",")
    end
    ao("  },")
    ao("  LOGGER = {")
    if chk(custom.LOGGER) then
      ao(type(custom.LOGGER.doNormalLogging) == "boolean" and "    doNormalLogging = "..tostring(custom.LOGGER.doNormalLogging)..", --If you are getting errors, set this to true.  It tends to spam files." or "    doNormalLogging = false, --If you are getting errors, set this to true.  It tends to spam files.")
      ao(type(custom.LOGGER.doPurchaseLogging) == "boolean" and "    doPurchaseLogging = "..tostring(custom.LOGGER.doPurchaseLogging).."," or "    doPurchaseLogging = true,")
      ao(type(custom.LOGGER.doInfoLogging) == "boolean" and "    doInfoLogging = "..tostring(custom.LOGGER.doInfoLogging)..", --HIGHLY recommended to not enable this.  Every time the screen redraws an info event is created." or "    doInfoLogging = false, --HIGHLY recommended to not enable this.  Every time the screen redraws an info event is created.")
      ao(type(custom.LOGGER.doWarnLogging) == "boolean" and "    doWarnLogging = "..tostring(custom.LOGGER.doWarnLogging).."," or "    doWarnLogging = true,")
      ao(custom.LOGGER.LOG_LOCATION and "    LOG_LOCATION = \""..custom.LOGGER.LOG_LOCATION.."\"," or "\"logs/\",")
      ao(custom.LOGGER.LOG_NAME and "    LOG_NAME = \""..custom.LOGGER.LOG_NAME.."\"," or "    LOG_NAME = \"Log\",")
      ao(custom.LOGGER.PURCHASE_LOG_LOCATION and "    PURCHASE_LOG_LOCATION = \""..custom.LOGGER.PURCHASE_LOG_LOCATION.."\"," or "    PURCHASE_LOG_LOCATION = \"purchases/\",")
      ao(custom.LOGGER.PURCHASE_LOG_NAME and "    PURCHASE_LOG_NAME = \""..custom.LOGGER.PURCHASE_LOG_NAME.."\"," or "    PURCHASE_LOG_NAME = \"PurchaseLog\",")
    else
      ao("    doNormalLogging = false, --If you are getting errors, set this to true.  It tends to spam files.")
      ao("    doPurchaseLogging = true,")
      ao("    doInfoLogging = false, --HIGHLY recommended to not enable this.  Every time the screen redraws an info event is created.")
      ao("    doWarnLogging = true,")
      ao("    LOG_LOCATION = \"logs/\",")
      ao("    LOG_NAME = \"Log\",")
      ao("    PURCHASE_LOG_LOCATION = \"purchases/\",")
      ao("    PURCHASE_LOG_NAME = \"PurchaseLog\",")
    end
    ao("  },")
    ao("}")
    ao("return data")
  else
    fs.move(fatShopCustomization,"BadShopCustomization")
    writeCustomization(fatShopCustomization)
    logger.severe("The fatShopCustomization file should return a table.  The old file has been moved to BadShopCustomization, and a new one has been written in it's place.")
    logger.info("Rebooting in 10 seconds.")
    os.sleep(10)
    os.reboot()
  end
  logger.info("Potential fix for customization file. Rebooting.")
  os.sleep(4)
  os.reboot()
end





if tArgs[1] == "setupText" then
  logger.info("Entering setup.")
  sleep(3)
  term.clear()
  term.setCursorPos(1,1)
  print("Before continuing, be sure you are alone and nobody else is on/able to access this computer.")
  print("Nothing will be hidden, and everything written to the screen during the setup will be in plaintext.")
  print()
  print("Press any key to continue")
  os.pullEvent("key")
  sleep()

  local qa = {
    kristAddress = {
      t = "boolean",
    },
    kristPword = {
      q = "Please enter the private-key for your krist address.",
    },
    confirmPword = {
      q = "Please confirm the key by typing it again.",
    },
    customInfo1 = {
      t = "string",
      q = "Enter line 1, leave blank for nothing.",
    },
    customInfo2 = {
      t = "string",
      q = "Enter line 2, leave blank for nothing.",
    },
    useSingleChest = {
      t = "boolean",
      q = "Will you be using a chest directly beside the turtle?",
    },
    chestSide = {
      q = "What side of the turtle is the chest on?",
    },
    useModemChest = {
      t = "boolean",
      q = "Will you be using a storage network attached to a modem?",
    },
  }
  local q = {
    owner = {
      t = "string",
      q = "Who owns this shop?",
    },
    shopName = {
      t = "string",
      q = "What would you like this shop to be called?",
    },
    showCustomInfo = {
      t = "boolean",
      q = "Would you like to use a custom information bar?",
    },
    touchHereForCobbleButton = {
      t = "boolean",
      q = "Would you like to display a \"Free Cobble\" button?",
    },
    itemsDrawnAtOnce = {
      t = "number",
      q = "How many items should be drawn per page?",
    },
    dropSide = {
      t = "string",
      q = "What side of the turtle would you like to drop items? (front, top, or bottom)",
      list = {
        "front",
        "top",
        "bottom",
      },
    },
  }
  local function resolveAnswer(q,a)
    if q.list and (q.t == "string" or q.t == "number") then
      local inList = false
      for i = 1,#q.list do
        if a == q.list[i] then
          inList = true
        end
      end
      return a,inList;
    else
      if q.t == "string" then
        return a,true;
      elseif q.t == "boolean" then
        a = string.lower(a)
        if a == "yes" or a == "true" or a == "1" or a == "y" then
          return true,true;
        elseif a == "no" or a == "false" or a == "0" or a == "n" then
          return false,true;
        else
          return nil,false;
        end
      elseif q.t == "number" then
        a = tonumber(a)
        return a,type(a) == "number"
      end
    end
    return "Something failed.",false;
  end


  local function c()
    term.clear()
    term.setCursorPos(1,1)
  end
  local function pq(q)
    print(q.q,"(" .. q.t .. ")")
    term.write("->")
  end

  local tries = 0
  repeat
    local complete = false
    tries = 0
    repeat
      c()
      if tries > 0 then
        print("Those are not the same!")
      end
      print(qa.kristPword.q)
      term.write("->")
      qa.kristPword.a = io.read()
      print()
      print(qa.confirmPword.q)
      term.write("->")
      qa.confirmPword.a = io.read()
      print()
      tries = 1
      qa.kristAddress.a = checkKristAddress(qa.kristPword.a)
    until qa.kristPword.a == qa.confirmPword.a
    tries = 0
    repeat
      if tries > 0 then
        print("That is not a valid answer!")
      end
      print("Is",checkKristAddress(qa.kristPword.a),"your krist address? (boolean)")
      term.write("->")
      local tmp = io.read()
      local a,b = resolveAnswer(qa.kristAddress,tmp)
      print(a,b)
      if a and b then complete = true end
      tries = 1
    until b
  until complete

  tries = 0
  repeat
    c()
    if tries > 0 then
      print("That is not a valid answer!")
    end
    print(qa.useSingleChest.q)
    term.write("->")
    local tmp = "empty"
    local a,b = resolveAnswer(qa.useSingleChest,io.read())
    if a and b then
      print(qa.chestSide.q)
      term.write("->")
      tmp = io.read()
    end
    qa.chestSide.a = tmp
    qa.useSingleChest.a = a
    tries = 1
  until b

  tries = 0
  repeat
    c()
    if tries > 0 then
      print("That is not a valid answer!")
    end
    print(qa.useModemChest.q)
    term.write("->")
    local a,b = resolveAnswer(qa.useModemChest,io.read())
    qa.useModemChest.a = a
    tries = 1
  until b

  local function customInfoRead()
    c()
    pq(qa.customInfo1)
    qa.customInfo1.a = io.read()
    print()
    c()
    pq(qa.customInfo2)
    qa.customInfo2.a = io.read()
  end



  for k,v in pairs(q) do
    tries = 0
    repeat
      local tmp = nil
      c()
      if tries > 0 then
        print("That is not a valid answer!")
      end
      pq(v)
      local a,b = resolveAnswer(v,io.read())
      q[k].a = a
      if k == "showCustomInfo" and a and b then
        customInfoRead()
      end
      tries = tries + 1
    until b
  end

  custom = {}
  for k,v in pairs(q) do
    if v.a ~= nil then
      custom[k] = v.a
    end
  end

  custom.customInfo = {
    [ 1 ] = qa.customInfo1.a,
    [ 2 ] = qa.customInfo2.a,
  }
  custom.useSingleChest = qa.useSingleChest.a
  custom.chestSide = qa.chestSide.a
  custom.useBothChestTypes = qa.useModemChest.a and qa.useSingleChest.a
  local hand = fs.open(".privKey","w")
  hand.writeLine("return \""..qa.kristPword.a.."\",\""..qa.kristAddress.a.."\"")
  hand.close()

  fixCustomization()
end




if fs.exists(".turtle") then
    local hd = fs.open(".turtle","r")
    tName = hd.readLine()
    hd.close()
else
    local juan = nil
    for k,v in pairs(peripheral.getNames()) do
        if peripheral.getType(v):find("chest") then juan = v break end
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
    logger.severe("Private key not valid.  Edit .privKey to change it.  Purchases will likely not work.")
end
if not fs.exists(".privKey") then
    writeBlankPrivKey()
else
    privKey,pubKey = dofile(".privKey")
    if type(privKey) ~= "string" or type(pubKey) ~= "string" then
        fs.move(".privKey","badPrivateKey")
        logger.severe("Your private key is messed up.  Your old private key has been moved to \"badPrivateKey\"")
        logger.warn("Purchases will not work currently.  Without the private key the shop will crash!")
        writeBlankPrivKey()
    end
    if privKey then
      privKey = k.toKristWalletFormat(privKey)
    end
end


local function writeData()
  local hd = fs.open(fatData,"w")
  local function ao(a)
      hd.writeLine(a)
  end
  ao("local items = {")
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
  ao("return items")
  hd.close()
end

if not fs.exists(fatData) then
  writeData()
  logger.warn("file "..fatData.." does not exist, wrote default item data.")
  items = dofile(fatData)
else
  items = dofile(fatData)
  if type(items) ~= "table" then
    logger.severe(fatData.." should return a table!")
  else
    logger.info("Items found in data: "..#items)
  end
end



local function refund(to,amt,rsn,gbad)
    local success,err = await(k.makeTransaction,privKey,to,amt,( rsn and gbad and "message="..rsn ) or ( rsn and not gbad and "error="..rsn ) or ( "error=Unknown error occured, take your money back" ) )
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
    ao("  owner = \"nobody\",")
    ao("  shopName = \"Unnamed Shop\",")
    ao("  drawBottomInfoBar = true,")
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
    ao("  useBothChestTypes = false,")
    ao("  useSingleChest = false, --if useBothChestTypes is true, this value does not matter.  If useBothChestTypes is false, and there is a network attached, the turtle will ignore everything except the single chest.")
    ao("  chestSide = \"bottom\",--You can use a single chest attached to a network by typing it's network name here (eg: \"minecraft:chest_666\")")
    ao("  doPurchaseForwarding = false,")
    ao("  purchaseForwardingAddress = \"fakeAddress\",")
    ao("  compactMode = false,")
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
    ao("  selectedEmptyStock = {")
    ao("    bg = colors.red,")
    ao("    fg = colors.white,")
    ao("  },")
    ao("  bigSelectionEmptyStock = {")
    ao("    bg = colors.red,")
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
    ao("  itemTableEmptyStock1 = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.red,")
    ao("  },")
    ao("  itemTableEmptyStock2 = {")
    ao("    bg = colors.black,")
    ao("    fg = colors.red,")
    ao("  },")
    ao("  chatty = {")
    ao("    enabled = false,")
    ao("    prefix = \"shop" .. math.random(100000, 999999) .. "\",")
    ao("    showNotice = true,")
    ao("    -- change the above value if you state that chatty is enabled elsewhere (like in big info or bottom info bar)")
    ao("    noticeFG = colors.white,")
    ao("    noticeBG = colors.black,")
    ao("    -- the above are the colors of the notice that displays just above the bottom info bar.")
    ao("    infoFG = colors.white,")
    ao("    infoBG = colors.red,")
    ao("    -- the above are the colors of the popup when someone chats something and chatty reacts.")
    ao("  },")

    ao("  REFUNDS = {")
    ao("    noItemSelected = \"There is no item selected!\",")
    ao("    underpay = \"You seem to have underpaid.\",")
    ao("    change = \"You overpaid by a small amount, here's your change!\",")
    ao("    outOfStock = \"We do not have any stock of that item!\",")
    ao("    UPDATE = \"The shop is updating it's stocks and an error occured!\",")
    ao("  },")
    ao("  LOGGER = {")
    ao("    doNormalLogging = false, --If you are getting errors, set this to true.  It tends to spam files.")
    ao("    doPurchaseLogging = true,")
    ao("    doInfoLogging = false, --HIGHLY recommended to not enable this.  Every time the screen redraws an info event is created.")
    ao("    doWarnLogging = true,")
    ao("    LOG_LOCATION = \"logs/\",")
    ao("    LOG_NAME = \"Log\",")
    ao("    PURCHASE_LOG_LOCATION = \"purchases/\",")
    ao("    PURCHASE_LOG_NAME = \"PurchaseLog\",")
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

local function checkCustomization()
  logger.info("Checking Customization file")
  writeCustomization(".temp")
  local c2 = dofile(".temp")
  fs.delete(".temp")
  if type(custom) ~= "table" then
    fixCustomization()
  end
  local function typeWarn(k,exp)
    logger.severe(k..": expected "..exp..", got "..type(custom[k]))
    fixCustomization()
  end
  local function typeInWarn(k,k2,v2)
    logger.severe("Table "..k.."'s item '"..k2.."' should be of type "..type(v2)..", but is of type "..type(custom[k][k2]))
    fixCustomization()
  end
  for k,v in pairs(c2) do
    if type(v) ~= type(custom[k]) then
      typeWarn(k,type(v))
    end
    if type(v) == "table" then
      for k2,v2 in pairs(v) do
        if type(custom[k]) == "table" then
          if type(v2) ~= type(custom[k][k2]) then
            typeInWarn(k,k2,v2)
          end
        end
      end
    end
  end
  return true
end

local function checkData()
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

local function checkKey()
  if k.makev2address(privKey) ~= pubKey then
    logger.severe("Your private-key and public-key are mismatched!")
    printError("Your private-key evaluates to...",k.makev2address(privKey))
    printError("Your public-key is written as...",pubKey)
    error("Private-key must evaluate to public-key.")
  else
    logger.info("Private-key and public-key match.")
  end
end

local function checkAllTheThings()
  checkCustomization()
  checkData()
  checkKey()
end



--------begin inventory and monitor manip

local function refreshChests()
  chests = {}
  if not custom.useSingleChest or custom.useBothChestTypes then
    local allPs = peripheral.getNames()
    for i = 1,#allPs do
      if allPs[i]:find("chest") or allPs[i]:find("shulker") then
        table.insert(chests,allPs[i])
      end
    end
  end
  if custom.useSingleChest or custom.useBothChestTypes then
    local yay = true
    for i = 1,#chests do
      if chests[i] == custom.chestSide then
        yay = false
      end
    end
    if yay then
      table.insert(chests,custom.chestSide)
    end
  end
end

local function recursiveCopy(from,to)
  if type(from) == "table" then
    for k,v in pairs(from) do
      if type(v) == "table" then
        to[k] = {}
        recursiveCopy(from[k],to[k])
      else
        to[k] = v
      end
    end
  end
end



local function refreshItems()
  refreshChests()
  local sIL2 = {}
  recursiveCopy(sIL,sIL2)
  for i = 1,#sIL2 do
    sIL2[i].count = 0
  end
  cobCount = 0
  for i = 1,#chests do
    local cChest = peripheral.wrap(chests[i])
    if type(cChest) ~= "table" then
      logger.warn("Chest \""..tostring(chests[i]).."\" (Index "..tostring(i)..") is seemingly missing from the network! Skipping it.")
    else
      local cInv = cChest.list()
      for o = 1,cChest.size() do
        if cInv[o] then
          for p = 1,#sIL2 do
            if cInv[o].name == sIL2[p].find and cInv[o].damage == sIL2[p].damage then
              sIL2[p].count = sIL2[p].count + cInv[o].count
            end
          end
          if custom.touchHereForCobbleButton and cInv[o].name == "minecraft:cobblestone" and cInv[o].damage == 0 then
            cobCount = cobCount + cInv[o].count
          end
        end
      end
    end
  end
  buttons.cobble.content = "Free Cobble ("..cobCount..")"
  local b = buttons.cobble.content
  buttons.cobble.x2 = buttons.cobble.x1+1+b:len()
  return sIL2
end

local function doRefresh()
  local ok = false
  ok,sIL = pcall(refreshItems)
  if not ok and type(sIL)  == "string" then
    logger.warn("Item refresh failed with code: "..sIL.."... skipping.")
  elseif not ok then
    logger.warn("Item refresh failed with unknown code... skipping.")
  end
end

local function sortItems()
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



local function grabItems(name,dmg,count)
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
            if ( custom.useBothChestTypes or custom.useSingleChest ) and chests[i] == custom.chestSide then
              if custom.chestSide == "front" or custom.chestSide == "bottom" or custom.chestSide == "top" or custom.chestSide == "left" or custom.chestSide == "right" or custom.chestSide == "back" then
                amountTransfered = amountTransfered + cChest.drop(o,count-amountTransfered)
              else
                amountTransfered = amountTransfered + cChest.pushItems(tName,o,count-amountTransfered)
              end
            else
              amountTransfered = amountTransfered + cChest.pushItems(tName,o,count-amountTransfered)
            end
          end
          if custom.dropSide == "top" then
            turtle.dropUp()
          elseif custom.dropSide == "bottom" then
            turtle.dropDown()
          elseif custom.dropSide == "front" then
            turtle.drop()
          else
            logger.warn("dropSide not configured correctly, dropping from the front.")
            turtle.drop()
          end
          if amountTransfered >= count then
            return amountTransfered
          end
        end
        if amountTransfered >= count then
          return amountTransfered
        end
      end
    end
  end
  return amountTransfered
end

local function getPages()
  if custom.itemsDrawnAtOnce == 0 or #sIL == 0 then
    mxPages = 1
  else
    mxPages = math.ceil(#sIL/custom.itemsDrawnAtOnce)
  end
end

--Monitor


buttons = {
  cobble = {
    x1 = 29,
    y1 = mY-7,
    x2 = 41,
    y2 = mY-5,
    content = "Free Cobble (UNKNOWN)",
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

local function refreshButtons()
  buttons.cobble.enabled = custom.touchHereForCobbleButton
  if custom.compactMode then
    if custom.drawBottomInfoBar then
      if buttons.cobble.enabled then
        buttons.cobble.y1 = mY-2
        buttons.cobble.y2 = mY-2
        buttons.cobble.x1 = 16
        buttons.cobble.content = "Free Cobble ("..cobCount..")"
        local b = buttons.cobble.content
        buttons.cobble.x1 = buttons.cobble.x1-b:len()/2-1
        buttons.cobble.x2 = buttons.cobble.x1+1+b:len()
        buttons.pgUp.y1 = mY-4
        buttons.pgUp.y2 = mY-4
        buttons.pgDwn.y1 = mY-4
        buttons.pgDwn.y2 = mY-4
      else
        buttons.pgUp.y1 = mY-3
        buttons.pgUp.y2 = mY-3
        buttons.pgDwn.y1 = mY-3
        buttons.pgDwn.y2 = mY-3
      end
    else
      if buttons.cobble.enabled then
        buttons.cobble.y1 = mY
        buttons.cobble.y2 = mY
        buttons.cobble.x1 = 16
        buttons.cobble.content = "Free Cobble ("..cobCount..")"
        local b = buttons.cobble.content
        buttons.cobble.x1 = buttons.cobble.x1-b:len()/2-1
        buttons.cobble.x2 = buttons.cobble.x1+1+b:len()
        buttons.pgUp.y1 = mY-2
        buttons.pgUp.y2 = mY-2
        buttons.pgDwn.y1 = mY-2
        buttons.pgDwn.y2 = mY-2
      else
        buttons.pgUp.y1 = mY
        buttons.pgUp.y2 = mY
        buttons.pgDwn.y1 = mY
        buttons.pgDwn.y2 = mY
      end
    end
  else
    if buttons.cobble.enabled then
      if custom.drawBottomInfoBar then
        buttons.cobble.y1 = mY-7
        buttons.cobble.y2 = mY-5
        buttons.cobble.x1 = 29
        buttons.cobble.content = "Free Cobble ("..cobCount..")"
        local b = buttons.cobble.content
        buttons.cobble.x2 = buttons.cobble.x1+1+b:len()
        buttons.pgUp.y1 = mY-7
        buttons.pgUp.y2 = mY-5
        buttons.pgDwn.y1 = mY-7
        buttons.pgDwn.y2 = mY-5
      else
        buttons.cobble.y1 = mY-3
        buttons.cobble.y2 = mY-1
        buttons.cobble.x1 = 29
        buttons.cobble.content = "Free Cobble ("..cobCount..")"
        local b = buttons.cobble.content
        buttons.cobble.x2 = buttons.cobble.x1+1+b:len()
        buttons.pgUp.y1 = mY-3
        buttons.pgUp.y2 = mY-1
        buttons.pgDwn.y1 = mY-3
        buttons.pgDwn.y2 = mY-1
      end
    else
      if custom.drawBottomInfoBar then
        buttons.pgUp.y1 = mY-7
        buttons.pgUp.y2 = mY-5
        buttons.pgDwn.y1 = mY-7
        buttons.pgDwn.y2 = mY-5
      else
        buttons.pgUp.y1 = mY-3
        buttons.pgUp.y2 = mY-1
        buttons.pgDwn.y1 = mY-3
        buttons.pgDwn.y2 = mY-1
      end
    end
  end


end

local function drawButton(BUTT)
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

local function inBetween(x1,y1,x2,y2,x,y)
  return x >= x1 and x <= x2 and y >= y1 and y <= y2
end

local function whichPress(x,y)
  for k,v in pairs(buttons) do
    if v.enabled and inBetween(v.x1,v.y1,v.x2,v.y2,x,y) then
      return k
    end
  end
  return "None"
end

local function square(x1,y1,x2,y2,c)
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

local function drawBG()
  local topPad = 3
  local botPad = 3
  if custom.compactMode then
    topPad = 1
    botPad = 1
  end
  mon.setBackgroundColor(custom.farthestBackground.bg)
  mon.clear()
  square(2,topPad+1,mX-1,mY,custom.background.bg)
  square(2,1,mX-1,topPad,custom.nameBar.bg)
  mon.setCursorPos(mX/2-(custom.shopName:len()/2),topPad/2+0.5)
  mon.setTextColor(custom.nameBar.fg)
  mon.write(custom.shopName)
  if custom.drawBottomInfoBar then
    square(2,mY-botPad,mX-1,mY,custom.infoBar.bg)
    mon.setTextColor(custom.infoBar.fg)
    local ln1y = mY-2
    local ln2y = mY-1
    if custom.compactMode then
      ln1y = mY-1
      ln2y = mY
    end
    if not custom.showCustomInfo then
      local ln1 = "This shop was made by fatmanchummy"
      local ln2 = "This shop is owned by "..custom.owner
      mon.setCursorPos(mX/2-(ln1:len()/2),ln1y)
      mon.write(ln1)
      mon.setCursorPos(mX/2-(ln2:len()/2),ln2y)
      mon.write(ln2)
    else
      if type(custom.customInfo[1]) == "string" then
        mon.setCursorPos(mX/2-(custom.customInfo[1]:len()/2),ln1y)
        mon.write(custom.customInfo[1])
        if type(custom.customInfo[2]) == "string" then
          mon.setCursorPos(mX/2-(custom.customInfo[2]:len()/2),ln2y)
          mon.write(custom.customInfo[2])
        end
      end
    end
  end
end

local function draw(sel,override,errText)
  oldY = sel
  refreshButtons()
  local toDraw = custom.itemsDrawnAtOnce
  getPages()
  local skip = 7
  local infoBarHeight = 7
  local infoBarBottom = 5
  local infoBarWords = 6
  if custom.compactMode then
    skip = 3
    infoBarHeight = 3
    infoBarBottom = 3
    infoBarWords = 3
  end
  square(3,infoBarBottom,mX/2+3,infoBarHeight,custom.itemInfoBar.bg)
  mon.setTextColor(custom.itemInfoBar.fg)
  mon.setCursorPos(4,infoBarWords)
  mon.write("Item")
  mon.setCursorPos(mX/3-5,infoBarWords)
  mon.write("Stock")
  mon.setCursorPos(mX/2-2,infoBarWords)
  mon.write("Price")
  square(3,infoBarHeight+1,mX/2+3,(infoBarHeight+1)+toDraw,custom.background.bg)
  for i = 1,toDraw do
    local cur = i+(toDraw)*(page-1)
    local cur1 = cur
    cur = sIL[cur]
    if cur then
      if cur.count == 0 then
        if i%2 == 1 then
          square(3,i+skip,mX/2+3,i+skip,custom.itemTableEmptyStock1.bg)
          mon.setTextColor(custom.itemTableEmptyStock1.fg)
        else
          square(3,i+skip,mX/2+3,i+skip,custom.itemTableEmptyStock2.bg)
          mon.setTextColor(custom.itemTableEmptyStock2.fg)
        end
      else
        if i%2 == 1 then
          square(3,i+skip,mX/2+3,i+skip,custom.itemTableColor1.bg)
          mon.setTextColor(custom.itemTableColor1.fg)
        else
          square(3,i+skip,mX/2+3,i+skip,custom.itemTableColor2.bg)
          mon.setTextColor(custom.itemTableColor2.fg)
        end
      end
      mon.setCursorPos(4,i+skip)
      mon.write(cur.display)
      mon.setCursorPos(mX/3-tostring(cur.count):len(),i+skip)
      mon.write(tostring(cur.count))
      local a = tostring(cur.price):find("%.")
      mon.setCursorPos(mX/2,i+skip)
      mon.write(".00")
      if a then
        mon.setCursorPos(mX/2+a-3,i+skip)
      else
        mon.setCursorPos(mX/2-tostring(cur.price):len(),i+skip)
      end
      mon.write(tostring(cur.price))
    end
  end
  if not override then
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
  end
  drawButton(buttons.pgUp)
  drawButton(buttons.pgDwn)
  local bigSelStart = 18
  local bigSelEnd = 25
  local displStart = 19
  if custom.compactMode then
    bigSelStart = 9
    bigSelEnd = 14
    displStart = 9
  end
  if sel and sel > skip then
    local i = sel-skip
    selection = i+(page-1)*(toDraw)
    local cur = sIL[selection]
    if cur and i <= toDraw then
      if cur.count == 0 then
        square(3,sel,mX/2+3,sel,custom.selectedEmptyStock.bg)
        mon.setTextColor(custom.selectedEmptyStock.fg)
      else
        square(3,sel,mX/2+3,sel,custom.selection.bg)
        mon.setTextColor(custom.selection.fg)
      end
      mon.setCursorPos(4,i+skip)
      mon.write(cur.display)
      mon.setCursorPos(mX/3-tostring(cur.count):len(),i+skip)
      mon.write(tostring(cur.count))
      local a = tostring(cur.price):find("%.")
      mon.setCursorPos(mX/2,i+skip)
      mon.write(".00")
      if a then
        mon.setCursorPos(mX/2+a-3,i+skip)
      else
        mon.setCursorPos(mX/2-tostring(cur.price):len(),i+skip)
      end
      mon.write(tostring(cur.price))

      if cur.count == 0 then
        square(mX/2+5,bigSelStart,mX-5,bigSelEnd,custom.bigSelectionEmptyStock.bg)
        mon.setTextColor(custom.bigSelectionEmptyStock.fg)
      else
        square(mX/2+5,bigSelStart,mX-5,bigSelEnd,custom.bigSelection.bg)
        mon.setTextColor(custom.bigSelection.fg)
      end
      mon.setCursorPos(mX/2+6,displStart)
      mon.write(cur.display)
      mon.setCursorPos(mX/2+6,displStart+1)
      mon.write(tostring(cur.price).."KST each")
      mon.setCursorPos(mX/2+6,displStart+2)
      mon.write("x"..tostring(cur.count))
      mon.setCursorPos(mX/2+6,displStart+3)
      local tPrice = math.ceil(cur.count*cur.price)
      mon.write("Whole stock price: "..tostring(tPrice))
      if cur.price < 1 then
        mon.setCursorPos(mX/2+6,displStart+4)
        mon.write("Items for 1 KST: "..tostring(math.floor(1/cur.price+0.5)))
      end
      mon.setCursorPos(mX/2+6,displStart+5)
      mon.write("/pay "..pubKey.." "..tPrice)
    else
      square(mX/2+5,bigSelStart,mX-5,bigSelEnd,custom.background.bg)
    end
  else
    square(mX/2+5,bigSelStart,mX-5,bigSelEnd,custom.background.bg)
  end
  if errText then
    square(mX/2+5,bigSelStart,mX-5,bigSelEnd,custom.chatty.infoBG)
    mon.setTextColor(custom.chatty.infoFG)
    for i = 0, 5 do
      mon.setCursorPos(mX/2+6,displStart + i)
      mon.write(errText[i + 1] and string.sub(errText[i + 1], 1, (mX-5) - (mX/2+5) - 1) or "")
    end
  end

  local bigInfoBegin = 8
  local bigInfoEnd = 16
  local inform = 9
  local bistart = 11
  if custom.compactMode then
    bigInfoBegin = 3
    bigInfoEnd = 7
    inform = 3
    bistart = 4
  end

  square(mX/2+5,bigInfoBegin,mX-5,bigInfoEnd,custom.bigInfo.bg)
  mon.setTextColor(custom.bigInfo.fg)
  mon.setCursorPos((3*mX)/4-6,inform)
  mon.write("Information")
  if custom.showCustomBigInfo then
    for i = 1,4 do
      custom.customBigInfo[i] = custom.customBigInfo[i]:gsub("PUBKEY",pubKey)
    end
    mon.setCursorPos((3*mX)/4-custom.customBigInfo[1]:len()/2,bistart)
    mon.write(custom.customBigInfo[1])
    mon.setCursorPos((3*mX)/4-custom.customBigInfo[2]:len()/2,bistart+1)
    mon.write(custom.customBigInfo[2])
    mon.setCursorPos((3*mX)/4-custom.customBigInfo[3]:len()/2,bistart+2)
    mon.write(custom.customBigInfo[3])
    mon.setCursorPos((3*mX)/4-custom.customBigInfo[4]:len()/2,bistart+3)
    mon.write(custom.customBigInfo[4])
  else
    local ln1 = "This shop's address is:"
    local ln2 = pubKey
    local ln3 = "Send Krist to this address after"
    local ln4 = "selecting an item to buy."
    mon.setCursorPos((3*mX)/4-ln1:len()/2,bistart)
    mon.write(ln1)
    mon.setCursorPos((3*mX)/4-ln2:len()/2,bistart+1)
    mon.write(ln2)
    mon.setCursorPos((3*mX)/4-ln3:len()/2,bistart+2)
    mon.write(ln3)
    mon.setCursorPos((3*mX)/4-ln4:len()/2,bistart+3)
    mon.write(ln4)
  end
  if custom.touchHereForCobbleButton then
    buttons.cobble.enabled = true
    drawButton(buttons.cobble)
  end
end


if true then

  local selection = false
  local s2 = false

  local oCT = {
    [1] = {color = colors.pink,x = mX/2-11,y = 4,y2 = 12,},
    [2] = {color = colors.magenta,x = mX/2-8,y = 4,y2 = 12,},
    [3] = {color = colors.purple,x = mX/2-5,y = 4,y2 = 12,},
    [4] = {color = colors.lightBlue,x = mX/2-2,y = 4,y2 = 12,},
    [5] = {color = colors.cyan,x = mX/2+1,y = 4,y2 = 12,},
    [6] = {color = colors.blue,x = mX/2+4,y = 4,y2 = 12,},
    [7] = {color = colors.green,x = mX/2+7,y = 4,y2 = 12,},
    [8] = {color = colors.lime,x = mX/2+10,y = 4,y2 = 12,},
    [9] = {color = colors.yellow,x = mX/2-11,y = 7,y2 = 15,},
    [10] = {color = colors.orange,x = mX/2-8,y = 7,y2 = 15,},
    [11] = {color = colors.red,x = mX/2-5,y = 7,y2 = 15,},
    [12] = {color = colors.brown,x = mX/2-2,y = 7,y2 = 15,},
    [13] = {color = colors.white,x = mX/2+1,y = 7,y2 = 15,},
    [14] = {color = colors.lightGray,x = mX/2+4,y = 7,y2 = 15,},
    [15] = {color = colors.gray,x = mX/2+7,y = 7,y2 = 15,},
    [16] = {color = colors.black,x = mX/2+10,y = 7,y2 = 15,},
    cancel = {color = colors.blue,y1=mY/2+4,y2=mY/2+6,contain = "cancel",},
  }

  local function getColorPress(x,y,selected)
    local y1 = oCT[1].y
    local y2 = oCT[9].y
    local yy1 = oCT[1].y2
    local yy2 = oCT[9].y2
    if type(selected) == "table" then
      if type(selected.bg) == "number" then
        for i = 1,8 do
          if inBetween(oCT[i].x,y1,oCT[i].x+1,y1+1,x,y) then
            return i,1
          end
        end
        for i = 9,16 do
          if inBetween(oCT[i].x,y2,oCT[i].x+1,y2+1,x,y) then
            return i,1
          end
        end
      end
      --------------------
      if type(selected.fg) == "number" then
        for i = 1,8 do
          if inBetween(oCT[i].x,yy1,oCT[i].x+1,yy1+1,x,y) then
            return i,2
          end
        end
        for i = 9,16 do
          if inBetween(oCT[i].x,yy2,oCT[i].x+1,yy2+1,x,y) then
            return i,2
          end
        end
      end
    end
    if inBetween(mX/2-oCT.cancel.contain:len()/2-2.5,mY/2+4,mX/2+oCT.cancel.contain:len()/2-0.5,mY/2+6,x,y) then
      selection = false
    end
  end

  local function drawColorBox(colorBox,iter)
    local iterD = "y"
    if iter ~= 1 then
      iterD = "y2"
    end
    mon.setBackgroundColor(colorBox.color)
    mon.setCursorPos(colorBox.x,colorBox[iterD])
    mon.write("  ")
    mon.setCursorPos(colorBox.x,colorBox[iterD]+1)
    mon.write("  ")
  end

  local function drawBoxColors2(writ,selected)
    square(mX/2-11.5,11,mX/2+12.5,17,colors.black)
    mon.setCursorPos(mX/2-writ:len()/2+0.5,11)
    mon.setTextColor(colors.white)
    mon.write(writ)
    for i = 1,16 do
      drawColorBox(oCT[i],2)
    end
  end

  local function drawBoxColors1(writ,selected)
    square(mX/2-11.5,3,mX/2+12.5,9,colors.black)
    mon.setCursorPos(mX/2-writ:len()/2+0.5,3)

    mon.setTextColor(colors.white)
    mon.write(writ)

    for i = 1,16 do
      drawColorBox(oCT[i],1)
    end
  end


  local function drawColors(selected)
    if type(selected) == "table" then
      drawBoxColors1("BACKGROUND",selected)
      if selected.fg then
        drawBoxColors2("TEXT",selected)
      end
    end
    mon.setBackgroundColor(colors.blue)
    if selected ~= nil and type(selected) ~= "boolean" then
      for i = 1,3 do
        mon.setCursorPos(mX/2-oCT.cancel.contain:len()/2-1.5,mY/2+3+i)
        mon.write(string.rep(" ",oCT.cancel.contain:len()+2))
      end
      mon.setCursorPos(mX/2-oCT.cancel.contain:len()/2-0.5,mY/2+5)
      mon.write(oCT.cancel.contain)
    end
  end


  local function select(x,y)
    if x == 1 or x == mX then
      selection = custom.farthestBackground
      s2 = "farthestBackground"
    elseif inBetween(2,1,mX-1,3,x,y) then
      selection = custom.nameBar
      s2 = "nameBar"
    elseif inBetween(2,mY-3,mX-1,mY,x,y) then
      selection = custom.infoBar
      s2 = "infoBar"
    elseif inBetween(3,5,mX/2+3,7,x,y) then
      selection = custom.itemInfoBar
      s2 = "itemInfoBar"
    elseif inBetween(3,8,mX/2+3,8,x,y) then
      selection = custom.itemTableColor1
      s2 = "itemTableColor1"
    elseif inBetween(3,9,mX/2+3,9,x,y) then
      selection = custom.itemTableColor2
      s2 = "itemTableColor2"
    elseif inBetween(3,10,mX/2+3,10,x,y) then
      selection = custom.selection
      s2 = "selection"
    elseif inBetween(3,11,mX/2+3,11,x,y) then
      selection = custom.itemTableEmptyStock2
      s2 = "itemTableEmptyStock2"
    elseif inBetween(3,12,mX/2+3,12,x,y) then
      selection = custom.itemTableEmptyStock1
      s2 = "itemTableEmptyStock1"
    elseif inBetween(mX/2+5,18,mX-5,25,x,y) then
      selection = custom.bigSelection
      s2 = "bigSelection"
    elseif inBetween(mX/2+5,8,mX-5,16,x,y) then
      selection = custom.bigInfo
      s2 = "bigInfo"
    elseif inBetween(5,mY-7,15,mY-5,x,y) then
      selection = custom.disabledButtons
      s2 = "disabledButtons"
    elseif inBetween(17,mY-7,27,mY-5,x,y)  then
      selection = custom.buttons
      s2 = "buttons"
    elseif inBetween(2,4,mX-1,mY-4,x,y) then--FINAL ELSEIF
      selection = custom.background
      s2 = "background"
    end
  end


  if tArgs[1] == "setupVisuals" then
    custom = dofile(fatCustomization)
    local oldCobble = custom.touchHereForCobbleButton
    local oldCompact = custom.compactMode
    local oldName = custom.shopName
    custom.touchHereForCobbleButton = false
    custom.compactMode = false
    custom.shopName = "Tap somewhere to change it's colors!"
    buttons.pgUp.content = "Enabled"
    buttons.pgUp.enabled = true
    buttons.pgDwn.content = "Disabled"
    buttons.pgDwn.enabled = false
    sIL = {
      {
        display = "Item List 1",
        find = "minecraft:cobblestone",
        damage = 0,
        price = 1.5,
        count = 100,
      },
      {
        display = "Item List 2",
        find = "minecraft:iron_ingot",
        damage = 0,
        price = 0.5,
        count = 5,
      },
      {
        display = "Selected Item",
        find = "minecraft:logs",
        damage = 0,
        price = 0.01,
        count = 9999,
      },
      {
        display = "Empty Stock Item 2",
        find = "minecraft:fuck",
        damage = 0,
        price = 100,
        count = 0,
      },
      {
        display = "Empty Stock Item 1",
        find = "minecraft:empty",
        damage = 0,
        price = 1000,
        count = 0,
      },
    }
    drawBG()
    draw(10,true)
    term.clear()
    term.setCursorPos(1,1)
    logger.info("Entering Visual Setup")
    print("Press the \"t\" key to exit.")
    print("This may not support smaller screens.")
    while true do
      drawBG()
      draw(10,true)
      drawColors(selection)
      local event = ({os.pullEvent()})
      if event[1] == "key" and event[2] == keys.t then
        mon.setBackgroundColor(custom.farthestBackground.bg)
        mon.clear()
        mon.setTextColor(custom.background.fg)
        mon.setTextScale(2)
        mon.setCursorPos(1,1)
        mon.write("Exiting customization.")
        break
      end
      if selection then
        if event[1] == "monitor_touch" then
          local index, bfg = getColorPress(event[3],event[4],selection)
          if index ~= nil then
            if bfg == 1 then
              custom[s2].bg = oCT[index].color
            elseif bfg == 2 then
              custom[s2].fg = oCT[index].color
            end
          end
        end
      else
        if event[1] == "monitor_touch" then
          select(event[3],event[4])
        end
      end

    end
    logger.info("Done, saving settings.")
    custom.touchHereForCobbleButton = oldCobble
    custom.shopName = oldName
    custom.compactMode = oldCompact
    fixCustomization()
    return 1
  end
end




-------------BEGIN-------------
checkAllTheThings()
sortItems()
doRefresh()

drawBG()



local function writeLine(txt)
  local bX,bY = mon.getCursorPos()
  mon.write(txt)
  mon.setCursorPos(1,bY+1)
end
local function bsod(err)
  mon.setTextScale(0.5)
  mon.setBackgroundColor(colors.blue)
  mon.setTextColor(colors.white)
  mon.clear()
  local mxX,mxY = mon.getSize()
  mon.setCursorPos(1,mxY/2)
  writeLine("The shop encountered an error it could not recover from")
  writeLine(err)
end






local function doPurchase(data,updoot)
  local tx = data.transaction or json.decode(data)
  local meta = nil
  local tf = false
  if tx.metadata then
    meta = k.parseMeta(tx.metadata)
  else
    meta = {meta = {}}
  end
  if not meta or not meta.meta or not meta.meta["return"] then
    returnTo = tx.from
  else
    returnTo = meta.meta["return"]
  end
  if meta.meta.username then
    tf = true
  end
  if selection and tx.to == pubKey then
    logger.info("Payment being processed.")
    local item = sIL[selection]
    if item.count > 0 then
      local paid = tx.value
      local items_required = math.floor(paid/item.price)
      local items_grabbed = grabItems(item.find,item.damage,items_required)
      if items_grabbed > 0 then
        logger.purchaseLog(item.find..":"..item.damage,items_grabbed,paid,meta.meta.username or tx.from,tf)
      end
      local over = paid%item.price
      local refundAmt = math.floor((items_required - items_grabbed)*item.price+over)

      if item.price > paid then
        refund(returnTo,tx.value,custom.REFUNDS.underpay,false)
      else
        if refundAmt > 0 then
          refund(returnTo,refundAmt,custom.REFUNDS.change,true)
          logger.purchase("Sent refund of "..refundAmt.." due to overpay.")
        end
      end
      if custom.doPurchaseForwarding and items_grabbed*item.price > 0  then
        refund(custom.purchaseForwardingAddress,math.ceil(items_grabbed*item.price),(meta.meta.username and "player "..meta.meta.username.." bought "..tostring(items_grabbed).." of "..item.display.." at "..custom.shopName ) or ( tx.from and "address "..tx.from.." bought "..tostring(items_grabbed).." of "..item.display.." at "..custom.shopName ) or "Purchase-Forwarding ("..custom.shopName..")",true )
      end
    else
      if updoot then
        refund(returnTo,tx.value,custom.REFUNDS.UPDATE,false)
        logger.purchase("Sent refund of "..tx.value.."due to UPDATING_STOCKS")
      else
        refund(returnTo,tx.value,custom.REFUNDS.outOfStock,false)
        logger.purchase("Sent refund of "..tx.value.." due to not having the item selected.")
      end
    end
  else
    if tx.to == pubKey then
      logger.purchase("No item selected, but we were payed!  Returning...")
      if returnTo then
        refund(returnTo,tx.value,custom.REFUNDS.noItemSelected,false)
      end
    end
  end
end


local function redraw()
  logger.info("Redraw")
  mon.setCursorPos(1,1)
  mon.setBackgroundColor(custom.farthestBackground.bg ~= colors.red and colors.red or colors.blue)
  mon.write(" ")
  parallel.waitForAll(
  function()
    sIL = refreshItems()
    if recentPressCount == 0 then selection = false recentPress = false oldY = false oldNotice = false end

    if recentNotice then
      draw(nil, nil, oldNotice)
      recentPressCount = recentPressCount - 1
    elseif recentPress then
      draw(oldY)
      recentPressCount = recentPressCount - 1
    else
      draw()
    end
  end)
  mon.setBackgroundColor(custom.farthestBackground.bg)
  mon.setCursorPos(1,1)
  mon.write(" ")
end




local function mainJua()
  jua.on("timer",function(evt,tmr)
    if tmr == purchaseTimer then
      mon.setCursorPos(1,2)
      mon.setBackgroundColor(custom.farthestBackground.bg)
      mon.write(" ")
    end
  end)

  jua.on("monitor_resize",function()
    mX,mY = mon.getSize()
    mon.setTextScale(0.5)
    refreshButtons()
    drawBG()
    draw()
  end)

  jua.on(chatEvent,function(...)
    if not custom.chatty.enabled then
      return
    end
    local message = chatFunc(...)

    local function chattyNotice(t1, t2, t3, t4, t5, t6)
      recentPressCount = 1
      recentNotice = true
      oldNotice = {t1, t2, t3, t4, t5, t6}
      draw(nil, nil, oldNotice)
    end

    if string.match(message, "^" .. custom.chatty.prefix) then
      local split = {n = 0}
      for word in string.gmatch(message, "%w+") do
        split.n = split.n + 1
        split[split.n] = word
      end
      local textFuncs = {
        next = function()
          if page < mxPages then
            page = page + 1
            draw()
            return
          end
          chattyNotice(
            "Chatty error:",
            "Already at last page!"
          )
        end,
        previous = function()
          if page > 1 then
            page = page - 1
            draw()
            return
          end
          chattyNotice(
            "Chatty error:",
            "Already at first page!"
          )
        end,
        back = function()
          if page > 1 then
            page = page - 1
            draw()
            return
          end
          chattyNotice(
            "Chatty error:",
            "Already at first page!"
          )
        end,
        select = function(num)
          local nnum = tonumber(num)
          if nnum then
            recentPress = true
            recentPressCount = 3
            draw(custom.compactMode and 3 + nnum or 7 + nnum)
            return
          end
          chattyNotice(
            "Chatty error:",
            "Expected number as third arg."
          )
        end,
        cobble = function()
          if custom.touchHereForCobbleButton then
            grabItems("minecraft:cobblestone",0,64)
            return
          end
          chattyNotice(
            "Chatty error:",
            "Cobble dispenser disabled."
          )
        end
      }
      if textFuncs[split[2]] then
        mon.setCursorPos(1, 3)
        mon.setBackgroundColor(custom.farthestBackground.bg ~= colors.yellow and colors.yellow or colors.black)
        mon.write(" ")
        textFuncs[split[2]](table.unpack(split, 3, split.n))
        os.sleep(0.2)
        mon.setCursorPos(1, 3)
        mon.setBackgroundColor(custom.farthestBackground.bg)
        mon.write(" ")
        return
      end
      chattyNotice(
        "Chatty error:",
        "No function '" .. tostring(split[2]) .. "'."
      )
    end
  end)

  jua.on("monitor_touch",function(nm,side,x,y)
    if side == mName then
      recentPress = true
      recentPressCount = 3
      local pressed = whichPress(x,y)
      if inBetween(3,1,mX/2+3,mY,x,y) then
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

  jua.on("terminate",function()
    if ws then ws.close() end
    jua.stop()
    bsod("Terminated")
    logger.severe("Why would you terminate me like this?")
    if logger.canLogBeOpened then
      logger.closeLog()
    end
    if logger.canPurchaseLogBeOpened then
      logger.closePurchaseLog()
    end
    printError("I can't believe you've done this.")
  end)


  jua.go(function()
    local success,ws = await(k.connect,privKey)
    if success then
      logger.info("Connected to websocket")
      ws.on("hello",function(data)
        logger.info("MOTD: "..data.motd)
        local success = await(ws.subscribe,"transactions",function(data)
          doPurchase(data)
          mon.setCursorPos(1,2)
          mon.setBackgroundColor(custom.farthestBackground.bg ~= colors.blue and colors.blue or colors.red)
          mon.write(" ")
          purchaseTimer = os.startTimer(3)
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


local suc = true
local err = "none"
local function bego()
  suc,err = pcall(mainJua)
end
parallel.waitForAny(bego,function()
  redraw()
  local tim = os.startTimer(10)
  while true do
    local event = {os.pullEvent("timer")}
    if event[2] == tim then
      redraw()
      tim = os.startTimer(10)
    end
  end
end)
if not suc then
  logger.severe(err)
  bsod(err)
  if logger.canLogBeOpened then
    logger.closeLog()
  end
  if logger.canPurchaseLogBeOpened then
    logger.closePurchaseLog()
  end
  if err ~= "Terminated" then
    writeLine("Reboot in 30 seconds.")
    os.sleep(30)
    os.reboot()
  end
end

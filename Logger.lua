--[[
2
noRequire
Made the logger open a single log file.  No more spammy names.
Logger, designed for Krist Shops.  You may edit and reuse this to your heart's content.
]]

logVersion = 2
local custom = false

local LOG_LOCATION = false
local LOG_NAME = false
local PLOG_LOCATION = false
local PLOG_NAME = false
local doInfoLogging = false
local doWarnLogging = false
canLogBeOpened = false
canPurchaseLogBeOpened = false
local fileHandle=false
local pFileHandle = false
if fs.exists("fatShopCustomization") then
  custom = dofile("fatShopCustomization")

  custom = custom.LOGGER
  LOG_LOCATION = custom.LOG_LOCATION
  LOG_NAME = custom.LOG_NAME
  PLOG_LOCATION = custom.PURCHASE_LOG_LOCATION
  PLOG_NAME = custom.PURCHASE_LOG_NAME
  canLogBeOpened = custom.doNormalLogging
  canPurchaseLogBeOpened = custom.doPurchaseLogging
  doInfoLogging = custom.doInfoLogging
  doWarnLogging = custom.doWarnLogging


  function openLog()
    local logName = LOG_LOCATION..LOG_NAME
    if not fs.exists(LOG_LOCATION) then
      fs.makeDir(LOG_LOCATION)
    end
    fileHandle = fs.open(logName,"a")
    if fileHandle then
      info("File is opened for logging")
    else
      severe("Could not open a file for logging.")
    end

  end
  function openPurchaseLog()
    local logName = PLOG_LOCATION..PLOG_NAME
    if not fs.isDir(PLOG_LOCATION) then
      fs.makeDir(PLOG_LOCATION)
    end
    if fs.exists(logName) then
      pFileHandle = fs.open(logName,"a")
    else
      pFileHandle = fs.open(logName,"w")
    end
    if pFileHandle then
      info("File is opened for purchase logging")
      fileHandle.writeLine("-----[START LOG]-----")
      fileHandle.flush()
    else
      severe("Could not open a file for purchase logging.")
    end
  end
  function closeLog()
    if fileHandle then
      fileHandle.flush()
      fileHandle.close()
      info("Log has been closed")
    else
      warn("Cannot close a log if it is not opened.")
    end

  end
  function closePurchaseLog()
    if pFileHandle then
      pFileHandle.flush()
      pFileHandle.close()
      info("Purchase log has been closed.")
    else
      warn("Cannot close purchase log if it is not opened.")
    end
  end
end

function isUpdate()
  local handle = http.get("https://raw.githubusercontent.com/fatboychummy/Simplify-Shop/master/Logger.lua")
  handle.readLine()
  local v = tonumber(handle.readLine())
  handle.close()
  if v < logVersion then
    print("LOGGER:",logVersion,">",v)
  elseif v > logVersion then
    print("LOGGER:",logVersion,"<",v)
  else
    print("LOGGER:",logVersion,"=",v)
  end
  return v > logVersion
end
function update()
  print("An update to the logger is available.")
  local h1 = http.get("https://raw.githubusercontent.com/fatboychummy/Simplify-Shop/master/Logger.lua")
  h1.readLine()
  local v = tonumber(h1.readLine())
  local required = h1.readLine()
  local notes = h1.readLine()
  h1.close()
  local doUpdate = false
  if required == "REQUIRED" then
    doUpdate = true
    print("Update is a required update.  Updating in 5 seconds.")
    print("-----------------")
    print(notes)
    print("-----------------")
    os.sleep(5)
  else
    print("Update is not a required update.")
    print("-----------------")
    print(notes)
    print("-----------------")
    print("Would you like to update now? (y/n)")
    local utm = os.startTimer(30)
    while true do
      local a = {os.pullEvent()}
      if a[1] == "char" then
        if a[2] == "y" then
          doUpdate = true
          break
        elseif a[2] == "n" then
          break
        end
      elseif a[1] == "timer" and a[2] == utm then
        break
      end
    end
    if not doUpdate then
      print("Timed out or skipping update.")
      return false
    end
  end

  if doUpdate then
    local handle = http.get("https://raw.githubusercontent.com/fatboychummy/Simplify-Shop/master/Logger.lua")
    fs.delete("logger.lua")
    local h2 = fs.open("logger.lua","w")
    h2.write(handle.readAll())
    handle.close()
    h2.close()
    return true
  end
  return false
end


function purchase(a)
  if term.isColor and term.isColor() then
    local oldC = term.getTextColor()
    term.write("[")
    term.setTextColor(colors.green)
    term.write("PURCHASE")
    term.setTextColor(oldC)
    term.write("]: ")
  else
    term.write("[PURCHASE]: ")
  end
  print(a)
  if pFileHandle then
    pFileHandle.writeLine(a)
    pFileHandle.flush()
  end
end
function purchaseLog(item,amount,price,addplay,tf)
  local function err(nm,exp,tp)
    return "purchaseLog Bad argument #"..tostring(nm)..": expected "..exp..", got "..tp.."."
  end
  assert(type(item) == "string",err(1,"string",type(item)))
  assert(type(amount) == "number",err(2,"number",type(amount)))
  assert(type(price) == "number",err(3,"number",type(price)))
  assert(type(addplay) == "string",err(4,"string",type(addplay)))
  assert(type(tf) == "boolean" ,err(5,"boolean",type(tf)))
  if term.isColor and term.isColor() then
    local oldC = term.getTextColor()
    term.write("[")
    term.setTextColor(colors.green)
    term.write("PURCHASE")
    term.setTextColor(oldC)
    term.write("]: ")
  else
    term.write("[PURCHASE]: ")
  end
  print(tf and "player "..addplay.." bought "..item.."["..tostring(amount).."] for "..tostring(price).."."  or "address "..addplay.." bought "..item.."["..tostring(amount).."] for "..tostring(price)..".")
  if pFileHandle then
    pFileHandle.writeLine(tf and "--[PURCHASE]: player "..addplay.." bought "..item.."["..tostring(amount).."] for "..tostring(price).."."  or "--[PURCHASE]: address "..addplay.." bought "..item.."["..tostring(amount).."] for "..tostring(price)..".")
    pFileHandle.flush()
  end
end
function info(notif)
    print(notif and "[INFO]: "..notif or "[INFO]: ?")
    if doInfoLogging and fileHandle then
      fileHandle.writeLine(notif and "[INFO]: "..notif or "[INFO]: ?")
      fileHandle.flush()
    end
end
function ree()
    print("[REE]: REEEEEEEEEEEEEEEEEEEEEEEEE")
end
function warn(notif)
    if term.isColor and term.isColor() then
      local oldC = term.getTextColour()
      term.write("[")
      term.setTextColor(colors.yellow)
      term.write("WARN")
      term.setTextColor(oldC)
    else
      term.write("[WARN")
    end
    print(notif and "]: "..notif or "]: ?")
    if doWarnLogging and fileHandle then
      fileHandle.writeLine(notif and "[WARN]: "..notif or "[WARN]: ?")
      fileHandle.flush()
    end
end
function severe(notif)
    if term.isColor and term.isColor() then
      local oldBC = term.getTextColor()
      term.write("[")
      term.setTextColor(colors.red)
      term.write("SEVERE")
      term.setTextColor(oldBC)
    else
      term.write("[SEVERE")
    end
    print(notif and "]: "..notif or "]: ?")
    if fileHandle then
      fileHandle.writeLine(notif and "[SEVERE]: "..notif or "[SEVERE]: ?")
      fileHandle.flush()
    end
end

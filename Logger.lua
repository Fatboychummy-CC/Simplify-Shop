local custom = false

local LOG_LOCATION = false
local LOG_NAME = false
local doInfoLogging = false
local doWarnLogging = false
_G.canLogBeOpened = false
local fileHandle=false
if fs.exists("fatShopCustomization") then
  custom = dofile("fatShopCustomization")
  _G.canLogBeOpened = true
  custom = custom.LOGGER
  LOG_LOCATION = custom.LOG_LOCATION
  LOG_NAME = custom.LOG_NAME
  doInfoLogging = custom.doInfoLogging
  doWarnLogging = custom.doWarnLogging


  function openLog()
    local logName = LOG_LOCATION..LOG_NAME
    if not fs.exists(LOG_LOCATION) then
      fs.makeDir(LOG_LOCATION)
      fileHandle = fs.open(logName.."1","w")
    else
      local i = 1
      local logName2 = logName..tostring(i)
      repeat
        i = i + 1
      until not fs.exists(logName..tostring(i))
        fileHandle = fs.open(logName..tostring(i),"w")
    end
    if fileHandle then
      info("File is opened for logging")
    else
      severe("Could not open a file for logging.")
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
end
function purchaseLog(item,amount,price)
  local function err(nm,exp,tp)
    return "purchaseLog Bad argument #"..tostring(nm)..": expected "..exp..", got "..tp.."."
  end
  assert(type(item) == "string",err(1,"string",type(item)))
  assert(type(amount) == "number",err(2,"number",type(amount)))
  assert(type(price) == "number",err(3,"number",type(price)))
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
  print(item.."["..tostring(amount).."] for "..tostring(price)..".")
  if fileHandle then
    fileHandle.writeLine("--[PURCHASE]: "..tostring(amount).." of "..item.." for "..tostring(price).." krist.")
    fileHandle.flush()
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

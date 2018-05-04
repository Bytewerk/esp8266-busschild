-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

timers = {
  ["data"] = 0;
}

function progmode()
  for _,t in pairs(timers) do
    tmr.unregister(t)
  end
  uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
end

__require = require
function _G.require(m)
  status, pkg = pcall(function() return __require(m) end)
  if status then
    return pkg
  else
    print(pkg)
    return nil
  end
end

config = require("config")

function init_wifi()
  local ssid = nil
  if wifi.getmode() == wifi.STATION then
    ssid, _, _, _ = wifi.sta.getconfig()
  end
  if ssid then
    function p(...) uart.write(0, string.format(...)) end
    wifi.sta.sethostname(config.hostname)
  else
    print("WLAN nicht\r\nkonfiguriert.")
  end
end


xpcall(function()
  init_wifi()
  busschild = require("busschild")
end, function(err)
  print(err)
end)

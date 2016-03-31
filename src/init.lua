-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

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
  wifi.setmode(wifi.STATION)
  if config.hostname then wifi.sta.sethostname(config.hostname) end
  if config.ssid then
    local passphrase = config.passphrase and config.passphrase or ""
    wifi.sta.config(config.ssid, passphrase, 1)
  else
    print("WLAN nicht\r\nkonfiguriert.")
  end
end

telnet = require("telnet")

xpcall(function()
  telnet.createServer(config.telnetport and config.telnetport or 23)
  init_wifi()
end, function(err)
  print(err)
end)

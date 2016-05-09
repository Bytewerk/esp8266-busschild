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
  local ssid = nil
  if wifi.getmode() == wifi.STATION then
    ssid, _, _, _ = wifi.sta.getconfig()
  end
  if ssid then
    function p(...) uart.write(0, string.format(...)) end
    wifi.sta.eventMonReg(wifi.STA_IDLE, function() p("\r\nWLAN nicht verbunden.") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() p("\r\nVerbinde mit WLAN\r\nESSID %s", ssid) end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() p("\r\nWLAN-Passwort falsch") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() p("\r\nWLAN-AP nicht gefunden\r\nESSID %s", ssid) end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function() p("\r\nWLAN-Verbindung fehlgeschlagen\r\nESSID %s", ssid) end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() p("\r\nIP-Adresse bezogen\r\n%s", wifi.sta.getip()) end)
    wifi.sta.eventMonStart()
  else
    print("WLAN nicht\r\nkonfiguriert.")
  end
end


xpcall(function()
  telnet = require("telnet")
  telnet.createServer(config.telnetport and config.telnetport or 23)
  init_wifi()
  busschild = require("busschild")
end, function(err)
  print(err)
end)

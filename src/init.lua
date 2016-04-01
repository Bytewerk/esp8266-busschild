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
    wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("\r\nWLAN nicht verbunden.") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("\r\nVerbinde mit WLAN") end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("\r\nWLAN-Passwort falsch") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("\r\nWLAN-AP nicht gefunden") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("\r\nWLAN-Verbindung fehlgeschlagen") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() print("\r\nIP-Adresse bezogen") end)
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

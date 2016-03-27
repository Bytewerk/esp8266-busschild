-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

timers = {
  ["HTTP"] = 0;
  ["display"] = 1;
}
config = require("config")
telnet = require("telnet")
display = require("display")
departures = {}
scroll_idx = 1

function stradj(s, len)
  return s:sub(1, len) .. string.rep(" ", len - s:len())
end

function format_departure(d)
  err, str = pcall(function()
    time = tonumber(d.strTime:gsub("(%d+).*", "%1"), 10)
    strTime = (time == 0) and " JETZT" or string.format(" %dm", time)
    route = d.route:gsub("%s+", "") .. " " .. d.destination
    len = config.display.columns - strTime:len()
    return stradj(route, len) .. strTime
  end)
  if err then
    return str
  else
    return ""
  end
end

function update_display()
  display.setcursor(0,0)
  if #departures == 0 then
    display.setcursor(0,0)
    uart.write(0, stradj("Ich seh keinen Bus.", config.display.columns)
      .. "\r\n" .. stradj("Heimlaufen?", config.display.columns))
  else
    for i=1, math.min(config.display.lines-1, #departures) do
      display.setcursor(0, i)
      uart.write(0, format_departure(departures[i]))
    end
    if #departures >= config.display.lines then
      scroll_idx = scroll_idx >= #departures and config.display.lines or scroll_idx + 1
      display.setcursor(0, config.display.lines)
      uart.write(0, format_departure(departures[scroll_idx]))
    end
  end
end

function update_data()
  http.get(config.url, nil, function(code, _data)
    if (code >= 0) then
      departures = cjson.decode(_data).departures
      update_display()
      tmr.alarm(timers["display"], config.display.interval*1000, tmr.ALARM_AUTO, update_display)
    else
      display.setcursor(0,0)
      uart.write(0, stradj("Konnte Daten nicht", config.display.columns)
        .. "\r\n" .. stradj("holen: HTTP-Fehler.", config.display.columns))
      tmr.unregister(timers["display"])
    end
  end)
end

function init()
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  display.setcursor(0,0)
  uart.write(0, "      bytewerk      \r\n Busabfahrtsanzeige ")
  tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
    wifi.setmode(wifi.STATION)
    wifi.sta.eventMonReg(wifi.STA_IDLE, function()  print("\r\nSTA_IDLE") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function()  print("\r\nVerbinde mit WLAN") end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function()  print("\r\nWLAN-Passwort falsch") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function()  print("\r\nWLAN-AP nicht gefunden") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function()  print("\r\nWLAN-Verbindung fehlgeschlagen") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function()  print("\r\nIP-Adresse bezogen")
      update_data()
    end)
    wifi.sta.eventMonStart()
    wifi.sta.config(config.ssid, config.passphrase)
    wifi.sta.sethostname(config.hostname)
    wifi.sta.connect()
    tmr.register(timers["HTTP"], config.interval*1000, tmr.ALARM_AUTO, update_data)
    tmr.start(0)
    telnet.createServer(config.telnetport)
  end)
end

function progmode()
  for _,t in pairs(timers) do
    tmr.unregister(t)
  end
  uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
end

init()

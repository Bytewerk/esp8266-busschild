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
    print(str)
    return ""
  end
end

function update_display()
  display.reset()
  if #departures == 0 then
    display.write{"Ich seh keinen Bus.", "Heimlaufen?"}
  else
    for i=1, math.min(config.display.lines-1, #departures) do
      display.lines[i] = format_departure(departures[i])
    end
    if #departures >= config.display.lines then
      scroll_idx = scroll_idx >= #departures and config.display.lines or scroll_idx + 1
      display.lines[config.display.lines] = format_departure(departures[scroll_idx])
    end
    display.flush()
  end
end

function update_data()
  http.get(config.url, nil, function(code, _data)
    if (code >= 0) then
      departures = cjson.decode(_data).departures
      update_display()
      tmr.alarm(timers["display"], config.display.interval*1000, tmr.ALARM_AUTO, update_display)
    else
      display.write{"Konnte Daten nicht", "holen: HTTP-Fehler."}
      tmr.unregister(timers["display"])
    end
  end)
end

function init()
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  display.write{"      bytewerk      ", " Busabfahrtsanzeige "}
  tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
    wifi.setmode(wifi.STATION)
    local w = display.write
    wifi.sta.eventMonReg(wifi.STA_IDLE, function() w("\r\nSTA_IDLE") end)
    wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() w("\r\nVerbinde mit WLAN") end)
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() w("\r\nWLAN-Passwort falsch") end)
    wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() w("\r\nWLAN-AP nicht gefunden") end)
    wifi.sta.eventMonReg(wifi.STA_FAIL, function() w("\r\nWLAN-Verbindung fehlgeschlagen") end)
    wifi.sta.eventMonReg(wifi.STA_GOTIP, function() w("\r\nIP-Adresse bezogen")
      update_data()
    end)
    wifi.sta.eventMonStart()
    wifi.sta.sethostname(config.hostname)
    wifi.sta.config(config.ssid, config.passphrase, 1)
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

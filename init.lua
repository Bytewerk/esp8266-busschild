TIMERS = {
  ["HTTP"] = 0;
}
UPDATE_INTERVAL = 30*1000
RT_URL = "http://www.invg.de/rt/getRealtimeData.action?stopPoint=2&station=IN-Klini&sid=273"
SSID = "Freifunk"
PASSPHRASE = ""
LINES = 2

function setcursor(x,y)
  uart.write(0, string.format("\27[%d;%dH", y, x))
end

function clear()
  uart.write(0, "\27[2J")
end

function do_update()
  http.get(RT_URL, nil, function(code, _data)
    if (code >= 0) then
      departures = cjson.decode(_data).departures
      setcursor(0,0)
      if #departures == 0 then
        setcursor(0,0)
        uart.write(0, "Ich seh keinen Bus.\r\nHeimlaufen?")
      else
        n = math.min(#departures, LINES)
        for i=1, n do
          setcursor(0, i)
          d = departures[i]
          route = string.sub(d.route:gsub("%s+", "") .. " " .. d.destination, 1, 16)
          route = route .. string.rep(" ", 17-route:len())
          time = d.strTime:gsub("(%d+).*", "%1") .. "m"
          uart.write(0, route)
          uart.write(0, time)
        end
      end
    else
      setcursor(0,0)
      uart.write(0, "Konnte Daten nicht\r\nholen: HTTP-Fehler.")
    end
  end)
end

function init()
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  setcursor(0,0)
  uart.write(0, "      bytewerk      \r\n Busabfahrtsanzeige ")
  wifi.setmode(wifi.STATION)
  wifi.sta.eventMonReg(wifi.STA_IDLE, function()  print("\r\nSTA_IDLE") end)
  wifi.sta.eventMonReg(wifi.STA_CONNECTING, function()  print("\r\nVerbinde mit WLAN") end)
  wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function()  print("\r\nWLAN-Passwort falsch") end)
  wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function()  print("\r\nWLAN-AP nicht gefunden") end)
  wifi.sta.eventMonReg(wifi.STA_FAIL, function()  print("\r\nWLAN-Verbindung fehlgeschlagen") end)
  wifi.sta.eventMonReg(wifi.STA_GOTIP, function()  print("\r\nIP-Adresse bezogen")
    do_update()
  end)
  wifi.sta.eventMonStart()
  wifi.sta.config(SSID, PASSPHRASE)
  wifi.sta.connect()
  tmr.register(TIMERS["HTTP"], UPDATE_INTERVAL, tmr.ALARM_AUTO, do_update)
  tmr.start(0)
end

function progmode()
  tmr.unregister(0)
  uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
end

init()

TIMERS = {
  ["HTTP"] = 0;
}
UPDATE_INTERVAL = 30*1000
DISPLAY_UPDATE_INTERVAL = 5
RT_URL = "http://www.invg.de/rt/getRealtimeData.action?stopPoint=2&station=IN-Klini"
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
      data = cjson.decode(_data)
      departures = data["departures"]
      clear()
      if #departures == 0 then
        setcursor(0,0)
        uart.write(0, "Ich seh keinen Bus.\r\nHeimlaufen?")
      else
        for i=1, math.min(#departures, LINES) do
          setcursor(0, i)
          d = departures[i]
          uart.write(string.format("%s %s %s"), d["route"], d["destination"], d["strTime"])
        end
      end
    end
  end)
end

function init()
  wifi.setmode(wifi.STATION)
  wifi.sta.config(SSID, PASSPHRASE)
  wifi.sta.connect()
  tmr.register(TIMERS["HTTP"], UPDATE_INTERVAL, tmr.ALARM_AUTO, do_update)
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  tmr.start(0)
end

function progmode()
  tmr.unregister(0)
  uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
end

init()

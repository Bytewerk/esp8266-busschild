-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

timers = {
  ["HTTP"] = 0;
  ["display"] = 1;
}
config = require("config")
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
  tmr.stop(timers["display"])
  http.get(config.url, nil, function(code, _data)
    if (code >= 0) then
      local data = cjson.decode(_data)
      if data then
        departures = data.departures
      else
        departures = {}
      end
      update_display()
      tmr.start(timers["display"])
    else
      display.write{"Konnte Daten nicht", "holen: HTTP-Fehler."}
    end
  end)
end

function init()
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  display.write{"      bytewerk      ", " Busabfahrtsanzeige "}
  tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
    tmr.alarm(timers["HTTP"], config.interval*1000, tmr.ALARM_AUTO, update_data)
    tmr.register(timers["display"], config.display.interval*1000, tmr.ALARM_AUTO, update_display)
  end)
end

init()

-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

config = require("config")
display = require("display")
departures = {}
scroll_idx = 1

function banner()
  ip = wifi.sta.getip()
  display.write{" BA66++ by bytewerk ", ip and ip..":"..config.dataport or "<keine IP>"}
end

function on_data(_, data)
  tmr.start(timers["data"])
  uart.write(0, data)
end

function init()
  uart.setup(0, 9600, 8, uart.PARITY_ODD, uart.STOPBITS_1, 1)
  banner()
  tmr.alarm(timers["data"], 60000, tmr.ALARM_SEMI, banner)
  srv = net.createServer(net.TCP, 180)
  srv:listen(config.dataport, function(conn)
    conn:on("receive", on_data)
  end)
end

init()

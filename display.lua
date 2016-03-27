-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

config = require("config")

local display = {
  lines = {};
}

function display.reset()
  display.content = {}
  for i=1, config.display.lines do
    display.lines[i] = string.rep(" ", config.display.columns)
  end
end

function display.flush()
  display.setcursor(0, 0)
  for i, line in ipairs(display.lines) do
    uart.write(0, line)
    if i < #display.lines then uart.write(0, "\r\n") end
  end
end

function display.clear()
  uart.write(0, "\27[2J")
end

function display.setcursor(x,y)
  uart.write(0, string.format("\27[%d;%dH", y, x))
end

display.reset()

return display

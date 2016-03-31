-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

config = require("config")

local display = {
  lines = {};
}

function stradj(s, l)
    l = l and l or config.display.columns
    return s:sub(1, l) .. string.rep(" ", l - s:len())
end

function display.reset()
  display.lines = {}
end

function display.flush()
  display.setcursor(0, 0)
  for i, line in ipairs(display.lines) do
    line = stradj(line)
    uart.write(0, line)
    if i < #display.lines then uart.write(0, "\r\n") end
  end
  for i = #display.lines+1, config.display.lines do
    display.setcursor(0, i)
    uart.write(0, string.rep(" ", config.display.columns))
  end
end

function display.clear()
  uart.write(0, "\27[2J")
end

function display.setcursor(x,y)
  uart.write(0, string.format("\27[%d;%dH", y, x))
end

function display.write(t)
  display.reset()
  if type(t) == "string" then
    lines = {}
    for s in t:gmatch("[^\r\n]+") do
      lines[#lines + 1] = s
    end
    display.write(lines)
  elseif type(t) == "table" then
    for i=1, math.min(#t, config.display.lines) do
      display.lines[i] = t[i]
    end
  else
    display.lines[0] = tostring(t)
  end
  display.flush()
end

display.reset()

return display

local telnet = {}
local sockets = {}

node.output(function(str)
  for s,_ in pairs(sockets) do
    s:send(str)
  end
end, 0)

function telnet.createServer(port)
  s=net.createServer(net.TCP,180)
  s:listen(port, function(c)
    sockets[c] = true
    c:on("receive",function(c,l)
      node.input(l)
    end)
    c:on("disconnection",function(c)
      sockets[c] = nil
    end)
    print(">")
  end)
  return s
end

return telnet

local telnet = {}

function telnet.createServer(port)
  s=net.createServer(net.TCP,180)
  s:listen(port, function(c)
      function s_output(str)
        if(c~=nil)
          then c:send(str)
        end
      end
      node.output(s_output, 0)
      c:on("receive",function(c,l)
        node.input(l)
      end)
      c:on("disconnection",function(c)
        node.output(nil)
      end)
  end)
  return s
end

return telnet

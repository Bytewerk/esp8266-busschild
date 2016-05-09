-- © 2016 Peter Brantsch <peter@bingo-ev.de>, see license.txt

local config = {
  url = "http://www.invg.de/rt/getRealtimeData.action?stopPoint=2&station=IN-Klini&sid=273";
  interval = 30;
  display = {
    interval = 5;
    lines = 4;
    columns = 20;
  };
  hostname = "busschild-01";
  telnetport = 23;
}

return config

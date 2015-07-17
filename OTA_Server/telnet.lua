--@otaIP 192.168.1.79
--
-- Firmware for ESP8266 OTA Server.
--  Copyright (C) 2015 Nicola Cimmino

--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.

--   This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.

--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see http://www.gnu.org/licenses/.

-- This code has been tested on an ESP-12 module running NodeMCU

-- Global flag indicating a remote client is connected.
tnetClient = false

-- Start to listen on TCP 23
-- If a remote connects redirect all incoming traffic to
-- the LUA interpreter and output from the interpreter back
-- to the clent.
function startServer()
   
  server=net.createServer(net.TCP, 180)
  server:listen(23,   function(conn)
    tnetClient = true
    tmr.stop(0) -- Prevent our watchdog to shut down the ESP while client connected.
   
    -- Grab all client traffic and redirect it to node input
    conn:on("receive", function(conn, data)
      node.input(data)
      tmr.wdclr() -- Prevent system watchdog resetting the device       
    end)
    
    -- Redirect node output stream to the client
    function s_output(str)
       if (conn~=nil) then
          conn:send(str)
       end
    end
    node.output(s_output,0)

    -- When the client disconnects, shut down
    conn:on("disconnection",function(conn) 
       node.output(nil) 
       if shutdownOnDisconnect then
        shutdown() -- We just shut down when client is gone
       end
    end)
  end) -- server:listen   
  
end
 
startServer()




--@otaIP 192.168.1.80
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


-- We start in both station and AP so that if the device
-- is moved to a new WiFi it's still possible to telnet
-- into it and set new WiFi credentials.
-- The device will show as NodeXXXX, connect to the AP
-- telnet 192.168.4.1 and use:
--  wifi.sta.config("SSID","PASSWORD")
-- to configure a new WiFi.
wifi.setmode(wifi.STATIONAP)
wifi.sta.autoconnect(1)

-- We randomize the node name, this is mainly an
-- hack as, for some reason, Windows machines refused
-- to connect to the AP after the first sucessfull connection!
-- But changing the AP name fixes the issue. This should be 
-- investigated. 
math.randomseed(tmr.now())
apConfig={}
apConfig.ssid="Node" ..  math.random(99999)
apConfig.pwd="mypassword"
wifi.ap.config(apConfig)

-- Set config flags
dofile("config.lua")

-- If you have a ssd1306 display this will show vital
-- information such as the AP name and current IP and status.
-- If not comment this.
dofile("display.lc")

dofile("cli.lc")

-- The actual telnet server that will be contacted by the
-- OTA utility to send up the new files.
dofile("telnet.lc")

-- A set of useful command line commands.
--dofile("user.lc")


-- Bring down the ESP to deep sleep.
function shutdown()
  tmr.stop(0)
  disp:sleepOn() 
	node.dsleep(0, nil)
end



-- Watchdog, if nothing happens (ie no remote connection)
-- shuth down after 2 minutes to preserve battery.
--tmr.alarm(0, 120000, 0, function() shutdown() end)

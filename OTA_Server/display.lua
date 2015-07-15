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

-- Basic display setup.
-- Fix for your pins configuration. I have an SPI with the following connections:
--
-- SCL GPIO14
-- SDA GPIO13
-- D/C GPIO2
-- RES GPIO16
--
function initDisplay()
  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
  disp = u8g.ssd1306_128x64_spi(8, 4, 0)

  disp:begin()
  disp:setFont(u8g.font_6x10)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setFontPosTop ()
  disp:firstPage()

  repeat
   disp:drawStr(2,25, "Booting....")
  until disp:nextPage() == false
end
     
 -- Basic screen showing the AP we are connecting to, the IP we got
 -- from that AP, the connection status as well as our SSID and IP address.
 --
 function showSystemInfo()
     
  -- IP if we have one else the connection status
  local addr = wifi.sta.getip();
  if addr == nil then
  local status = wifi.sta.status()
  if status == 0 then
    addr = "Idle"
  elseif status == 1 then
    addr = "Connecting..."
  elseif status == 2 then
    addr = "Wrong pwd"
  elseif status == 3 then
    addr = "No AP"
  elseif status == 4 then
    addr = "Fail"
  else
      addr = "Unknown"
  end
  end

  -- Our SSID
  local ssid, other = wifi.sta.getconfig()
  if ssid == nil then
  ssid = ""
  end

  -- The AP IP (ie our IP if someone connects to our AP)
  local apip = wifi.ap.getip()
  if apip == nil then
  apip = ""
  end
  
  -- Draw loop
  disp:firstPage()
  repeat
   disp:drawStr(2,0, "AP: ")
   disp:drawStr(40,0, ssid)
   disp:drawStr(2,10, "IP: ")
   disp:drawStr(40,10, addr)
   disp:drawStr(2,25, "SSID: ")
   disp:drawStr(40,25, apConfig.ssid)
   disp:drawStr(2,35, "IP: ")
   disp:drawStr(40,35, apip)
   if tnetClient == true then
    disp:drawStr(2,50, "Remote connected.")
   end
  until disp:nextPage() == false      
end

initDisplay()

-- Redraw the info screen once a second.
tmr.alarm(1, 1000, 1, function() showSystemInfo() end)

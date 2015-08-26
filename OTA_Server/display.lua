--@otaIP 192.168.1.81

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

-- Basic display setup.
-- Fix for your pins configuration. I have an SPI with the following connections:
--
-- SCL GPIO14  nodeio5
-- SDA GPIO13 nodeio 7 
-- D/C GPIO2
-- RES GPIO16
--
function initDisplay()

sda = 7
scl = 5
i2c.setup(0, sda, scl, i2c.SLOW)

sla = 0x3c
disp = u8g.ssd1306_128x64_i2c(sla)

 -- spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
 -- disp = u8g.ssd1306_128x64_spi(8, 4, 0)

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
 function drawCurrentScreen()
     
  -- IP if we have one else the connection status
  addr = wifi.sta.getip();
  if addr == nil then
  status = wifi.sta.status()
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
  ssid, other = wifi.sta.getconfig()
  if ssid == nil then
  ssid = ""
  end

  -- The AP IP (ie our IP if someone connects to our AP)
  apip = wifi.ap.getip()
  if apip == nil then
  apip = ""
  end
  
  -- Draw loop
  disp:firstPage()
  repeat
    drawHeader()
    if currentScreen == 0 then
      drawWiFiInfoScreen()
    elseif currentScreen == 1 then
      drawSystemInfoScreen()
    elseif currentScreen == 2 then  
      drawFileSystemInfoScreen()
    end
  until disp:nextPage() == false  
end

currentScreen = 0

function drawWiFiInfoScreen()
     disp:drawStr(2,20, "AP: ")
     disp:drawStr(40,20, ssid)
     disp:drawStr(2,30, "IP: ")
     disp:drawStr(40,30, addr)
     disp:drawStr(2,45, "SSID: ")
     disp:drawStr(40,45, apConfig.ssid)
     disp:drawStr(2,55, "IP: ")
     disp:drawStr(40,55, apip)
end

function drawHeader()
  if tnetClient == true then
    disp:drawStr(2,0, "RMT")
  end
  if showVoltage == true then
    disp:drawStr(50,0, string.format("Vbat: %.3fv", adc.readvdd33()/1000))
  end
end

function drawSystemInfoScreen()
  majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info()
  disp:drawStr(2,20,"NodeMCU V"..majorVer.."."..minorVer.."."..devVer)
  disp:drawStr(2,30,"Chip ID: "..chipid);
  disp:drawStr(2,40,"Flash ID: "..flashid);
  disp:drawStr(2,50,"Flash Size: "..flashsize.." kb");
end

function drawFileSystemInfoScreen()
  free, used, total=file.fsinfo()
  disp:drawStr(2,20,"Total: "..total.." Bytes")
  disp:drawStr(2,30,"Used:  "..used.." Bytes")
  disp:drawStr(2,40,"Free:  "..free.." Bytes")
end

function nextScreen()
  currentScreen = currentScreen + 1
  if currentScreen == 3 then
    currentScreen = 0
  end
  pcall(drawCurrentScreen)
end

gpio.mode(6, gpio.INT)
gpio.trig(6, "up", nextScreen)

initDisplay()

-- Redraw the info screen once a second.
tmr.alarm(1, 1000, 1, function() pcall(drawCurrentScreen) end)

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

function df()
  free, used, total=file.fsinfo()
  print("Total:\t"..total.." Bytes")
  print("Used: \t"..used.." Bytes")
  print("Free: \t"..free.." Bytes\n")
end

function info()
  majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed = node.info();
  print("NodeMCU V"..majorVer.."."..minorVer.."."..devVer)
  print("Chip ID:\t"..chipid);
  print("Flash ID:\t"..flashid);
  print("Flash Size:\t"..flashsize.." bytes");
end

function ls()
  files = file.list();
  for name,size in pairs(files) do
    print(name.."\t\t"..size)
  end
end

function ledon()
  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.HIGH)
end

function ledoff()
  gpio.mode(4, gpio.OUTPUT)
  gpio.write(4, gpio.LOW)
end

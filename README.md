The goal of this project is to produce a command line utility that given a LUA file will transfer it OTA to an ESP8266 running NodeMCU.

This presumes telnet running on the ESP, see NodeMCU (http://nodemcu.com/) for examples of telnet server scripts.

The rough idea at the moment is to have this as a single command line utility taking as the only input parameter the LUA script file name.
Configuration would be instead included as decorations to the script itself. This allows to set the tool in text editors, such as Notepad++, and 
upload it by simply pressing F5 or another key shortcut.

To test this have a LUA script, for instance in Notepad++, decorated as in the example below:

      
      --@otaIP 192.168.1.79
      --@otaDestination otatest2.lua
      
      print(wifi.sta.getip())
      print("OK")
      

Define a shortcut to NodeMCU_OTA.exe and specify the current fileame as the parameter. This is achieved in Notepad++ uder the Run/Run... menu with 
a command path like:

    "C:\NodeMCU_OTA\NodeMCU_OTA\bin\Debug\NodeMCU_OTA.exe" "$(FULL_CURRENT_PATH)"

TODO list:

* refactor code, this is just a dirty hack to prove the concept
* add support for .configure files so that the source doesn't need to be decorated and IP can be set in a single place
* extend the functionality to serial

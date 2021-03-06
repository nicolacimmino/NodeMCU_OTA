﻿// Program.cs main module and entry point of NodeMCU_OTA.
// This appliation allows to send files OTA to an ESP8266 running NodeMCU.
//
//  Copyright (C) 2014 Nicola Cimmino
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see http://www.gnu.org/licenses/.
//
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.IO.Ports;

namespace NodeMCU_OTA
{
    class Program
    {
        static void Main(string[] args)
        {
            String inputFile = args[0];

            StreamReader inFile = new StreamReader(inputFile);
            String fileContent = inFile.ReadToEnd();
            inFile.Close();
            List<String> lines = new List<String>(fileContent.Split('\n'));

            Preprocessor preprop = new Preprocessor();
            preprop.Parse(lines);

            CodeBody codeBody = new CodeBody();
            codeBody.Parse(lines);
            String destinationFile = preprop.OtaDestination??Path.GetFileName(inputFile);
            codeBody.Prepare(lines, destinationFile);

            Stream stream = null;

            TcpClient tcpClient = null;
            if (!String.IsNullOrEmpty(preprop.OtaIP))
            {
                tcpClient = new TcpClient();
                tcpClient.Connect(preprop.OtaIP, 23);
                stream = tcpClient.GetStream();
            }

            SerialPort serialPort = null;
            if (!String.IsNullOrEmpty(preprop.OtaCOM))
            {
                serialPort = new SerialPort(preprop.OtaCOM);
                serialPort.BaudRate = 9600;
                serialPort.Open();
                stream = serialPort.BaseStream;
            }

            if(stream == null)
            {
                return;
            }

            foreach(String line in lines)
            {
                sendCommand(stream, line);
            }

            if(preprop.Compile)
            {
                sendCommand(stream, "node.compile(\"" + destinationFile + "\")");
                sendCommand(stream, "file.remove(\"" + destinationFile + "\")");
            }

            if (tcpClient != null)
            {
                tcpClient.Close();
            }

            if(serialPort != null)
            {
                serialPort.Close();
            }

            Console.WriteLine("Ready");
            Thread.Sleep(2000);
        }

        private static void sendCommand(Stream stream, String line)
        {
            Console.WriteLine(line);
                var buf = Encoding.ASCII.GetBytes(line + "\r\n");
                stream.Write(buf, 0, buf.Length);

                int read = 0;
                while(read != (int)'>')
                {
                    read = stream.ReadByte();
                    Console.Write((char)read);
                }
        }
    }
}

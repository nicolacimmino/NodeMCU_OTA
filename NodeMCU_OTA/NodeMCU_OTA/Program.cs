// Program.cs main module and entry point of NodeMCU_OTA.
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

namespace NodeMCU_OTA
{
    class Program
    {
        static void Main(string[] args)
        {
            StreamReader inFile = new StreamReader(args[0]);
            String fileContent = inFile.ReadToEnd();
            inFile.Close();
            List<String> lines = new List<String>(fileContent.Split('\n'));

            Preprocessor preprop = new Preprocessor();
            preprop.Parse(lines);

            CodeBody codeBody = new CodeBody();
            codeBody.Parse(lines);
            codeBody.Prepare(lines, preprop.OtaDestination);

            foreach(String line in lines)
            {
                Console.WriteLine(line);
            }
            Console.WriteLine(preprop.OtaIP);

            String toSend = String.Join("\r\n", lines);
            byte[] bytesToSend = System.Text.Encoding.UTF8.GetBytes(toSend);

            TcpClient tcpClient = new TcpClient();
            IPAddress ipAddress = Dns.GetHostAddresses(preprop.OtaIP)[0];
            IPEndPoint ipEndPoint = new IPEndPoint(ipAddress, 23);
            tcpClient.Connect(ipEndPoint);

            TextWriter output = new StreamWriter(tcpClient.GetStream());
            //tcpClient.GetStream().Write(bytesToSend, 0, bytesToSend.Length);
            foreach(String line in lines)
            {
                Console.WriteLine(line);
                output.Write(line + "\n");
               Thread.Sleep(1000);  
            }
            Thread.Sleep(5000); 
            tcpClient.Close();
            Console.WriteLine("Ready");
            Console.ReadKey();
        }
    }
}

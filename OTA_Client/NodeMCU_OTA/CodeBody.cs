// CodeBody.cs The actual source code contained in the file to send.
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

namespace NodeMCU_OTA
{
    class CodeBody
    {
        public void Parse(List<String> lines)
        {
            List<String> processedCode = new List<String>();

            foreach (String rawLine in lines)
            {
                String line = rawLine.Trim().Trim('\t');

                if (line.StartsWith("--"))
                {
                    continue;
                }

                if (line == "")
                {
                    continue;
                }

                String processedLine = line.Trim().Replace("\t", "");
                processedCode.Add(processedLine);
            }

            lines.Clear();
            lines.AddRange(processedCode);
        }

        public void Prepare(List<String> lines, String destination)
        {
            List<String> processedCode = new List<String>();
            processedCode.Add("file.remove(\"" + destination + "\")");
            processedCode.Add("file.open(\"" + destination + "\", \"w+\")");

            foreach (String line in lines)
            {
                String processedLine = line.Replace("\"", "\\\"");
                processedLine = "file.writeline(\"" + processedLine + "\")";
                processedCode.Add(processedLine);
            }

            processedCode.Add("file.close()");

            lines.Clear();
            lines.AddRange(processedCode);
        }
    }
}

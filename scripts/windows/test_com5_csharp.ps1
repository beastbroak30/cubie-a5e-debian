$csharp = @"
using System;
using System.IO;
using System.Threading;
using System.IO.Ports;

public class ComTester {
    public static void Test() {
        using (var sp = new SerialPort("COM5", 115200, Parity.None, 8, StopBits.One)) {
            sp.DtrEnable = true;
            sp.RtsEnable = true;
            sp.ReadTimeout = 500;
            sp.WriteTimeout = 500;
            sp.Open();
            sp.DiscardInBuffer();

            Console.WriteLine("Opened COM5. Writing newline...");
            sp.WriteLine("");
            sp.WriteLine("radxa");
            Thread.Sleep(500);

            string s = sp.ReadExisting();
            Console.WriteLine("Received: [" + s + "]");
        }
    }
}
"@

Add-Type -TypeDefinition $csharp -ReferencedAssemblies System.dll -PassThru | Out-Null
[ComTester]::Test()

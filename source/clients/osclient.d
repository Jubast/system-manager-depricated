module clients.osclient;

import std.stdio;
import std.string;
import std.process : spawnProcess, execute;

import std.array;
import std.algorithm;

class UsbDevice
{
    string name;
    string vendorId;
    string productId;

    this(string name, string vendorId, string productId)
    {
        this.name = name;
        this.vendorId = vendorId;
        this.productId = productId;
    }
}

UsbDevice[] listUsbDevices()
{
    auto usbResponse = execute(["lsusb"]);
    if (usbResponse.status != 0)
    {
        return null;
    }

    UsbDevice[] list;
    auto lines = splitLines(usbResponse.output);
    foreach (line; lines)
    {
        if (line is null || line.strip == "")
        {
            continue;
        }

        // lsusb output:
        // Bus 004 Device 001: ID 2f4g:0003 Product Name 9000
        string[] tokens = line.splitter(" ").array;
        if (tokens.length < 6)
        {
            continue; // something isn't right, skip dis line
        }

        auto ids = tokens[5].splitter(":").array;
        if (ids.length != 2)
        {
            continue; // something isn't right, skip dis token
        }

        string name = "";
        for (int i = 6; i < tokens.length; ++i)
        {
            name ~= tokens[i] ~ " ";
        }

        list ~= new UsbDevice(name.stripRight, ids[0], ids[1]);
    }

    return list;
}

@("listUsbDevices should succeed")
unittest
{
    auto usbDevices = listUsbDevices();
    assert(usbDevices !is null);
}

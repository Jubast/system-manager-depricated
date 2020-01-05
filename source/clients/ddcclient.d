module clients.ddcclient;

import std.stdio;
import std.typecons;
import std.stdint;

import ddbus;
import ddbus.c_lib;
import ddbus.util;

import helpers.searching;

private alias Tuple!(string[], Tuple!(byte)[], string[], Tuple!(byte)[]) DDCCONTROL_GET_MONITORS;
private alias Tuple!(string, string) DDCCONTROL_OPEN_MONITOR;
private Connection connection;

static this()
{
    connection = connectToBus(DBusBusType.DBUS_BUS_SYSTEM);
}

static ~this()
{
    connection.close();
}

private struct Monitor
{
    string bus;
    string name;
    string pnpid;
    string caps;

    byte supported;
    byte digital;
}

private Monitor[] toMonitors(DDCCONTROL_GET_MONITORS source)
{
    Monitor[] monitors;

    for (int i = 0; i < source[0].length; ++i)
    {
        string bus = source[0].indexOrInit(i);
        byte supported = source[1].indexOrInit(i)[0];
        string name = source[2].indexOrInit(i);
        byte digital = source[3].indexOrInit(i)[0];

        Monitor m = {
            bus: bus, name: name, supported: supported, digital: digital
        };
        monitors ~= m;
    }

    return monitors;
}

Monitor[] listMonitors()
{
    Message request = Message(busName("ddccontrol.DDCControl"),
            ObjectPath("/ddccontrol/DDCControl"),
            interfaceName("ddccontrol.DDCControl"), "GetMonitors");
    Message response = connection.sendWithReplyBlocking(request);

    auto data = response.readTuple!(DDCCONTROL_GET_MONITORS)();
    auto monitors = data.toMonitors();
    return monitors;
}

void populateMonitorInfo(Monitor* mon)
{
    assert(mon !is null, "Monitr must not be null!");
    assert(mon.bus !is null, "Monitor.bus must not be null!");

    Message request = Message(busName("ddccontrol.DDCControl"),
            ObjectPath("/ddccontrol/DDCControl"),
            interfaceName("ddccontrol.DDCControl"), "OpenMonitor");
    request.build(mon.bus);

    Message response = connection.sendWithReplyBlocking(request);
    auto data = response.readTuple!(DDCCONTROL_OPEN_MONITOR)();
    mon.pnpid = data[0];
    mon.caps = data[1];
}

void changeMonitorInputSource(Monitor* mon, uint32_t address, uint32_t value)
{
    assert(mon !is null, "Monitr must not be null!");
    assert(mon.bus !is null, "Monitor.bus must not be null!");
    
    Message request = Message(busName("ddccontrol.DDCControl"),
            ObjectPath("/ddccontrol/DDCControl"),
            interfaceName("ddccontrol.DDCControl"), "SetControl");
    request.build(mon.bus, address, value);
    connection.sendBlocking(request);
}

/* unittest
{
    listMonitors();
}

unittest
{
    auto monitors = listMonitors();
    populateMonitorInfo(&monitors[0]);
}

unittest
{
    auto monitors = listMonitors();
    changeMonitorInputSource(&monitors[1], 0x60, 17);
} */

unittest
{
    auto monitors = listMonitors();
    foreach(mon; monitors)
    {
        populateMonitorInfo(&mon);
        writeln(mon);
    }
}

module handlers.requesthandlers;

import vibe.d;
import asdf;
import std.path;
import std.conv;
import std.file;
import std.stdio;

import helpers.searching;
import helpers.configdirectory;
import handlers.models;

import clients.ddcclient;
import clients.virshclient;

static void switchToLinux(HTTPServerRequest req, HTTPServerResponse res)
{
//	writeln("here");
	
    auto type = req.query.get("type");
    if (type == req.query.ValueType.init)
        return;

    if (type == "clean")
    {
	writeln("here1");

        switchAccessories(SwitchType.Detach, "win10_clean_gaming");
        switchMonitors("Linux");
    }
    else if (type == "sketchy")
    {
        switchAccessories(SwitchType.Detach, "win10_sketchy_gaming");
        switchMonitors("Linux");
    }
}

static void switchToWindows(HTTPServerRequest req, HTTPServerResponse res)
{
    auto type = req.query.get("type");
    if (type == req.query.ValueType.init)
        return;

    if (type == "clean")
    {
        switchAccessories(SwitchType.Attach, "win10_clean_gaming");
        switchMonitors("Windows");
    }
    else if (type == "sketchy")
    {
        switchAccessories(SwitchType.Attach, "win10_sketchy_gaming");
        switchMonitors("Windows");
    }
}

private MonitorModel[] readMonitorsConfigs()
{
    auto filePath = buildPath(ConfigurationDirectory, "monitors.json");

    auto json = readText(filePath);
    auto monitors = json.deserialize!(MonitorModel[]);
    return monitors;
}

private void switchMonitors(string configuration)
{   
    auto monitorsConfigs = readMonitorsConfigs(); 
    auto monitors = listMonitors();

    foreach (monitor; monitors)
    {
        populateMonitorInfo(&monitor);

        auto monitorConfig = find!(MonitorModel)(monitorsConfigs, x => x.pnpid == monitor.pnpid);
        auto config = find!(ConfigurationModel)(monitorConfig.configurations, x => x.name == configuration);
        
        changeMonitorInputSource(&monitor, 0x60, config.value.to!int);
    }
}

private void switchAccessories(SwitchType type, string hostName)
{
    if (type == SwitchType.Attach)
    {        
        attachDeviceLive(hostName, buildPath(ConfigurationDirectory, "virsh_keyboard.xml"));
        attachDeviceLive(hostName, buildPath(ConfigurationDirectory, "virsh_mouse.xml"));
        attachDeviceLive(hostName, buildPath(ConfigurationDirectory, "virsh_audio.xml"));
        attachDeviceLive(hostName, buildPath(ConfigurationDirectory, "virsh_bluetooth.xml"));
    }
    else if (type == SwitchType.Detach)
    {
        detachDevice(hostName, buildPath(ConfigurationDirectory, "virsh_keyboard.xml"));
        detachDevice(hostName, buildPath(ConfigurationDirectory, "virsh_mouse.xml"));
        detachDevice(hostName, buildPath(ConfigurationDirectory, "virsh_audio.xml"));
        detachDevice(hostName, buildPath(ConfigurationDirectory, "virsh_bluetooth.xml"));
    }
    else
    {
        throw new Exception("Unknown switch type.");
    }
}

module clients.virshclient;

import std.process : spawnProcess;

void attachDeviceLive(string hostName, string file)
{
    spawnProcess(["virsh", "-c", "qemu:///system", "attach-device", hostName, "--file", file, "--live"]);
}

void detachDevice(string hostName, string file)
{
    spawnProcess(["virsh", "-c", "qemu:///system", "detach-device", hostName, "--file", file]);
}
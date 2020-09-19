module clients.virshclient;

import std.stdio;
import std.string;
import std.process : spawnProcess, execute;

enum State
{
    Active,
    Inactive
}

class DomainModel
{
    string name;
    State state;

    this(string name, State state)
    {
        this.name = name;
        this.state = state;
    }
}

DomainModel[] listDomains()
{    
    auto domainsResponse = execute(["virsh", "-c", "qemu:///system", "list", "--name", "--all"]);
    if(domainsResponse.status != 0)
    {
        return null;
    }    

    DomainModel[] list;
    auto lines = splitLines(domainsResponse.output);    
    foreach (line; lines)
    {        
        if(line is null || line.strip == "")
        {            
            continue;
        }

        auto stateResponse = execute(["virsh", "-c", "qemu:///system", "domstate", line]);
        if(stateResponse.status != 0)
        {
            continue;
        }

        State state;
        auto stateStr = stateResponse.output.strip;
        if(stateStr == "running")
        {
            state = State.Active;
        }
        else if(stateStr == "shut off")
        {
            state = State.Inactive;
        }

        list ~= new DomainModel(line, state);
    }

    return list;
}

void attachDeviceLive(string hostName, string file)
{
    spawnProcess(["virsh", "-c", "qemu:///system", "attach-device", hostName, "--file", file, "--live"]);
}

void detachDevice(string hostName, string file)
{
    spawnProcess(["virsh", "-c", "qemu:///system", "detach-device", hostName, "--file", file]);
}

@("listDomains should succeed")
unittest
{
    auto domains = listDomains();
    assert(domains !is null);
}
module helpers.configdirectory;

import std.process : environment;
import std.path;

private string configurationDirectory;
string ConfigurationDirectory()
{
    return configurationDirectory;
}

static this()
{
    version (CONFIG_CWD_PATH)
    {
        pragma(msg, "Config directory is ./");
        configurationDirectory = "./";
    }
    version (CONFIG_HOME_PATH)
    {
        pragma(msg, "Config directory is $HOME/.local/share/jubast/system-manager");
        configurationDirectory = buildPath(environment.get("HOME"), ".local",
                "share", "jubast", "system-manager");
    }
}

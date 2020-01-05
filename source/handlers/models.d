module handlers.models;

class ConfigurationModel
{
	string name;
	string value;
}

class MonitorModel
{
	string pnpid;
	string inputAddress;
	ConfigurationModel[] configurations;
}

enum SwitchType
{
	Attach,
	Detach
}

import vibe.d;
import handlers.requesthandlers;

void main()
{
	auto settings = new HTTPServerSettings;
	settings.port = 45323;

	auto router = new URLRouter;
	with (router)
	{
		get("/switch/linux", &switchToLinux);
		get("/switch/windows", &switchToWindows);
	}

	listenHTTP(settings, router);

	runApplication;
}

import vibe.d;
import handlers.requesthandlers;

	void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
	if (req.path == "/switch/linux")
		switchToLinux(req, res);

	if(req.path == "/switch/windows")
		switchToWindows(req, res);
	
	res.writeBody("Yay", "text/plain");
}

	void main()
	{
		auto settings = new HTTPServerSettings;
		settings.port = 45323;

/*		auto router = new URLRouter;
		router.get("/test", &switchToLinux);
		with (router)
		{
			get("/device/monitors");
			get("/device/peripherals");
			post("/device/input");

			get("/kvm/domains");
			post("/kvm/input");
			get("/switch/linux", &switchToLinux);
			get("/switch/windows", &switchToWindows);
		}*/

auto l =		listenHTTP(settings, &handleRequest);
scope(exit) l.stopListening();

		runApplication;
	}


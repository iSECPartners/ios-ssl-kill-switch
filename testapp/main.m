int main(int argc, char **argv) {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	int ret = UIApplicationMain(argc, argv, @"SSLKillSwitchTestApplication", @"SSLKillSwitchTestApplication");
	[p drain];
	return ret;
}


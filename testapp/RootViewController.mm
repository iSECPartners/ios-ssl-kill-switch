#import "RootViewController.h"
#import "TestSSLKillSwitch.h"



@implementation RootViewController
- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor redColor];

    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"iOS SSL Kill Switch"
                             message: @"iOS SSL Kill Switch Test App Started"
                             delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
    [alert show];
    [alert release];

    [TestSSLKillSwitch runAllTests];

}
@end


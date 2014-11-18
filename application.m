#import <UIKit/UIKit.h>
#import <AppList.h>

@interface AppListSampleViewController : UITableViewController {
@private
	ALApplicationTableDataSource *dataSource;
}

@end

@implementation AppListSampleViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.dataSource = dataSource;
	dataSource.tableView = self.tableView;
}

- (void)viewDidUnload
{
	dataSource.tableView = nil;
	[super viewDidUnload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		dataSource = [[ALApplicationTableDataSource alloc] init];
		dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];
	}
	return self;
}

- (void)dealloc
{
	dataSource.tableView = nil;
	[dataSource release];
	[super dealloc];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
	ALApplicationList *al = [ALApplicationList sharedApplicationList];
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:[al.applications objectForKey:displayIdentifier] message:[displayIdentifier stringByAppendingString:@"\n\n\n\n\n\n"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[av show];
	CGSize avSize = av.bounds.size;
	UIImage *largeIcon = [al iconOfSize:ALApplicationIconSizeLarge forDisplayIdentifier:displayIdentifier];
	if (largeIcon) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:largeIcon];
		CGSize imageSize = largeIcon.size;
		imageView.frame = (CGRect){ { roundf((avSize.width - imageSize.width) * (1.0f / 3.0f)), roundf((avSize.height - imageSize.height) * 0.5f) }, imageSize };
		[av addSubview:imageView];
		[imageView release];
	}
	UIImage *smallIcon = [al iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:displayIdentifier];
	if (smallIcon) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:smallIcon];
		CGSize imageSize = smallIcon.size;
		imageView.frame = (CGRect){ { roundf((avSize.width - imageSize.width) * (2.0f / 3.0f)), roundf((avSize.height - imageSize.height) * 0.5f) }, imageSize };
		[av addSubview:imageView];
		[imageView release];
	}
	[av release];
}

@end

@interface AppListSampleAppDelegate : NSObject<UIApplicationDelegate> {
@private
	UIWindow *window;
	UINavigationController *navigationController;
	AppListSampleViewController *viewController;
}

@end

@implementation AppListSampleAppDelegate

- (id)init
{
	if ((self = [super init])) {
		window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		navigationController = [[UINavigationController alloc] init];
		viewController = [[AppListSampleViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	if ([window respondsToSelector:@selector(setRootViewController:)])
		[window setRootViewController:navigationController];
	else
		[window addSubview:[navigationController view]];
	[navigationController pushViewController:viewController animated:NO];
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[viewController release];
	[navigationController release];
	[window release];
	[super dealloc];
}

@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = UIApplicationMain(argc, argv, nil, @"AppListSampleAppDelegate");
    [pool drain];
    return result;
}

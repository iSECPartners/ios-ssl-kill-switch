
@interface HookedNSURLConnectionDelegate : NSObject <NSURLConnectionDelegate> {

    id originalDelegate;        // The NSURLConnectionDelegate we're going to proxy
    BOOL customCertValidationMethod1;  // Does the App perform custom cert validation - Method 1 ?
    BOOL customCertValidationMethod2;  // Does the App perform custom cert validation - Method 2 ?
} 

@property (retain) id originalDelegate; // Need retain or the delegate gets freed before we're done using it.



// Contructor
-(HookedNSURLConnectionDelegate*) initWithOriginalDelegate: (id) origDeleg;


// Mirror the original delegate's list of implemented methods
- (BOOL)respondsToSelector:(SEL)aSelector ;

// Forward messages to the original delegate if the proxy doesn't implement the method
- (id)forwardingTargetForSelector:(SEL)sel;


// Methods implemented by the proxy

// NSURLConnectionDelegate - Custom cert validation - Strategy #1
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;


// NSURLConnectionDelegate - Custom cert validation - Strategy #2
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;


// NSURLConnectionDelegate - TODO: Investigate
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;


@end
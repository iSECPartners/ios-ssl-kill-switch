


@interface HookedNSURLConnectionDelegate : NSObject <NSURLConnectionDelegate> {

    id originalDelegate;        // The NSURLConnectionDelegate we're going to proxy
    BOOL customCertValidationMethod1;  // Does the App perform custom cert validation - Method 1 ?
    BOOL customCertValidationMethod2;  // Does the App perform custom cert validation - Method 2 ?
} 

@property (retain) id originalDelegate; // Need retain or the delegate gets freed before we're done using it.


// Utility function
+(BOOL)shouldHookNSURLConnectionFromPreference:(NSString*) preferenceFilePath;


// Contructor
-(HookedNSURLConnectionDelegate*) initWithOriginalDelegate: (id) origDeleg;


// Mirror the original delegate's list of implemented methods
- (BOOL)respondsToSelector:(SEL)aSelector ;


// NSURLConnectionDelegate - Required methods
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data ;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response ;
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite ;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse ;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse ;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection ;


// NSURLConnectionDelegate - Optional methods
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error ;
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request NS_AVAILABLE(10_6, 3_0); ;


// NSURLConnectionDelegate - Custom cert validation - Strategy #1
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;


// NSURLConnectionDelegate - Custom cert validation - Strategy #2
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;


// NSURLConnectionDelegate - TODO: Investigate
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection;


// NSURLAuthenticationChallengeSender - so we can intercept the App's response to challenge.sender
- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
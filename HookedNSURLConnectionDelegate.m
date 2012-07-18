#import "HookedNSURLConnectionDelegate.h"


@implementation HookedNSURLConnectionDelegate : NSObject 

@synthesize originalDelegate;


+(BOOL)shouldHookNSURLConnectionFromPreference:(NSString*) preferenceFilePath {
    // Returns whether certificate validation methods in NSURLConnection 
    // should be hooked, depending on the given preference file 
    
    NSMutableDictionary* plist = [[NSMutableDictionary alloc] initWithContentsOfFile:preferenceFilePath];
    
    if (!plist) { // Preference file not found, don't hook
        NSLog(@"SSL Kill Switch - Preference file not found.");
        return FALSE;
    }
    else {
        id shouldHook = [plist objectForKey:@"killSwitchNSURLConnection"];
        if (shouldHook) {
            return [shouldHook boolValue];
        } 
        else { // Property was not set, don't hook
            NSLog(@"SSL Kill Switch - Preference not set.");
            return FALSE;
        }
    }
}


-(HookedNSURLConnectionDelegate*) initWithOriginalDelegate: (id) origDeleg{
    self = [super init];

    if (self) { // Store original delegate
        [self setOriginalDelegate:(origDeleg)];
    }

    if  ([originalDelegate respondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        customCertValidationMethod1 = TRUE; // The App is doing custom certificate validation
        customCertValidationMethod2 = FALSE;
    }
    else if ([originalDelegate respondsToSelector:@selector(didReceiveAuthenticationChallenge:)]) {
        customCertValidationMethod1 = FALSE; // The App is doing custom certificate validation
        customCertValidationMethod2 = TRUE;
    }
    else {
        customCertValidationMethod1 = FALSE;
        customCertValidationMethod2 = FALSE;
    }
    
    return self;
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    // The proxy should mirror the delegate's methods so that it doesn't change the app flow    
    
    // Does the original delegate implement this method
    BOOL isImplemented = [originalDelegate respondsToSelector:aSelector];
    
    // Is it a cert validation method ?
    if ((aSelector == @selector(connection:willSendRequestForAuthenticationChallenge:))
            || (aSelector == @selector(connection:canAuthenticateAgainstProtectionSpace:))
            || (aSelector == @selector(connection:didReceiveAuthenticationChallenge:)) ) {
            
        if (customCertValidationMethod1 || customCertValidationMethod2) { 
            // OK and the delegate proxy's cert validation methods will be called instead
            return isImplemented;
        }
        else { // The App doesn't do cert pinning but force custom cert validation anyway
            return YES;
        }
    }
    else { // No a cert validation method, just mirror the original delegate's methods
        return isImplemented;
    }
}


// NSURLConnectionDelegate - Required methods: Just forward the call to the original delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    return [originalDelegate connection:connection didReceiveData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    return [originalDelegate connection:connection didReceiveResponse:response];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    return [originalDelegate connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite: totalBytesExpectedToWrite];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return [originalDelegate connection:connection willCacheResponse:cachedResponse];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return [originalDelegate connection:connection willSendRequest:request redirectResponse:redirectResponse];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    return [originalDelegate connectionDidFinishLoading:connection];
}


// NSURLConnectionDelegate - Optional methods: Just forward the call to the original delegate
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request NS_AVAILABLE(10_6, 3_0) {
    return [originalDelegate connection:connection needNewBodyStream:request NS_AVAILABLE(10_6, 3_0)];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [originalDelegate connection:connection didFailWithError:error];     
}


// NSURLConnectionDelegate - Custom cert validation strategy #1
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // Call the original delegate method in case it changes the application's state but intercept the response
        // Not sure how to make the App's validation method succeed
        /*if (customCertValidationMethod1) { // The App implements this method
            id senderProxy = self;
            NSURLAuthenticationChallenge* challengeProxy = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:senderProxy];
            [originalDelegate connection:connection willSendRequestForAuthenticationChallenge:challengeProxy];
        }*/
        
        // Now accept the certificate and send the response to the real challenge.sender
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
        }
}


// NSURLConnectionDelegate - Custom cert validation strategy #2
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    
    if([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        return YES;
    }
    return NO;

}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // Call the original delegate method in case it changes the application's state but intercept the response
        // Not sure how to make the App's validation method succeed
        /*if (customCertValidationMethod2) { // The App implements this method
            id senderProxy = self;
            NSURLAuthenticationChallenge* challengeProxy = [[NSURLAuthenticationChallenge alloc] initWithAuthenticationChallenge:challenge sender:senderProxy];
            [originalDelegate connection:connection didReceiveAuthenticationChallenge:challengeProxy];
        }*/
        
        // Now accept the certificate and send the response to the real challenge.sender
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    }
}


// NSURLConnectionDelegate - TODO: Investigate
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    NSLog(@"CALLED connectionShouldUseCredentialStorage");
    return NO;
}


// NSURLAuthenticationChallengeSender - so we can intercept the App's response to challenge.sender
- (void)cancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"SSL Kill Switch - Intercepted cancelAuthenticationChallenge");
}

- (void)continueWithoutCredentialForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"SSL Kill Switch - Intercepted continueWithoutCredentialForAuthenticationChallenge");
}

- (void)useCredential:(NSURLCredential *)credential forAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"SSL Kill Switch - Intercepted useCredential:forAuthenticationChallenge");
}

- (void)performDefaultHandlingForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"SSL Kill Switch - Intercepted performDefaultHandlingForAuthenticationChallenge");
}

- (void)rejectProtectionSpaceAndContinueWithChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"SSL Kill Switch - Intercepted rejectProtectionSpaceAndContinueWithChallenge");
}


@end

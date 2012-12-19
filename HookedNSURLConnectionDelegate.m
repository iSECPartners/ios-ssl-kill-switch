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
            [plist release];
            return [shouldHook boolValue];
        } 
        else { // Property was not set, don't hook
            NSLog(@"SSL Kill Switch - Preference not set.");
            [plist release];
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



// Forward messages to the original delegate if the proxy doesn't implement the method
- (id)forwardingTargetForSelector:(SEL)sel {
    return originalDelegate; 
}


// NSURLConnectionDelegate - Custom cert validation strategy #1
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
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


@end

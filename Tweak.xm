#import <Security/Security.h>
#import "HookedNSURLConnectionDelegate.h"


#define PREFERENCEFILE "/private/var/mobile/Library/Preferences/com.isecpartners.nabla.SSLKillSwitchSettings.plist"


%group NSURLConnectionHook

%hook NSURLConnection

+ (NSURLConnection *)connectionWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate {

    NSURLConnection *hookedResult;
    HookedNSURLConnectionDelegate* delegateProxy = [[HookedNSURLConnectionDelegate alloc] initWithOriginalDelegate: delegate];
    hookedResult = %orig(request, delegateProxy);   
    [delegateProxy release]; // NSURLConnection retains the delegate
   
    return hookedResult;
}


- (id)initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate {
    
    id hookedResult;
   	HookedNSURLConnectionDelegate* delegateProxy = [[HookedNSURLConnectionDelegate alloc] initWithOriginalDelegate: delegate];
    hookedResult = %orig(request, delegateProxy);	
    [delegateProxy release]; // NSURLConnection retains the delegate
   
    return hookedResult;
}


- (id)initWithRequest:(NSURLRequest *)request delegate:(id < NSURLConnectionDelegate >)delegate startImmediately:(BOOL)startImmediately {
    
    id hookedResult;
    HookedNSURLConnectionDelegate* delegateProxy = [[HookedNSURLConnectionDelegate alloc] initWithOriginalDelegate: delegate];
    hookedResult = %orig(request, delegateProxy, startImmediately);		
    [delegateProxy release]; // NSURLConnection retains the delegate
    
    return hookedResult;    
}

%end
%end



// Hook SecTrustEvaluate
static OSStatus (*original_SecTrustEvaluate)(SecTrustRef trust, SecTrustResultType *result);

static OSStatus replaced_SecTrustEvaluate(SecTrustRef trust, SecTrustResultType *result) {
    OSStatus res = original_SecTrustEvaluate(trust, result);
    // Actually, this certificate chain is trusted
    *result = kSecTrustResultUnspecified;
    return res;
}



// Utility function to read the Tweak's preferences
static BOOL shouldHookFromPreference(NSString *preferenceSetting) {
    NSString *preferenceFilePath = @PREFERENCEFILE;
    NSMutableDictionary* plist = [[NSMutableDictionary alloc] initWithContentsOfFile:preferenceFilePath];
    
    if (!plist) { // Preference file not found, don't hook
        NSLog(@"SSL Kill Switch - Preference file not found.");
        return FALSE;
    }
    else {
        id shouldHook = [plist objectForKey:preferenceSetting];
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


%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Should we hook NSURLConnection ?
	if (shouldHookFromPreference(@"killSwitchNSURLConnection")) {
    	NSLog(@"SSL Kill Switch - NSURLConnection Hook Enabled.");
        %init(NSURLConnectionHook);
    }
    else {
    	NSLog(@"SSL Kill Switch - NSURLConnection Hook Disabled.");
        }

    // Should we hook SecTrustEvaluate ?
    if (shouldHookFromPreference(@"killSwitchSecTrustEvaluate")) {
        NSLog(@"SSL Kill Switch - SecTrustEvaluate Hook Enabled.");
        MSHookFunction((void *) SecTrustEvaluate,(void *)  replaced_SecTrustEvaluate, (void **) &original_SecTrustEvaluate);
    }
    else {
        NSLog(@"SSL Kill Switch - SecTrustEvaluate Hook Disabled.");
    } 

    [pool drain];
}

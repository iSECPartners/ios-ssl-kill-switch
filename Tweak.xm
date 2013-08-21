#import <Security/SecureTransport.h>
#import "substrate.h"

#define PREFERENCEFILE "/private/var/mobile/Library/Preferences/com.isecpartners.nabla.SSLKillSwitchSettings.plist"


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


// Hook SSLSetSessionOption()
static OSStatus (*original_SSLSetSessionOption)(
    SSLContextRef context, 
    SSLSessionOption option, 
    Boolean value);

static OSStatus replaced_SSLSetSessionOption(
    SSLContextRef context, 
    SSLSessionOption option, 
    Boolean value) {

    // Remove the ability to modify the value of the kSSLSessionOptionBreakOnServerAuth option
    if (option == kSSLSessionOptionBreakOnServerAuth)
        return noErr;
    else
        return original_SSLSetSessionOption(context, option, value);
}


// Hook SSLCreateContext()
static SSLContextRef (*original_SSLCreateContext) (
   CFAllocatorRef alloc,
   SSLProtocolSide protocolSide,
   SSLConnectionType connectionType
);

static SSLContextRef replaced_SSLCreateContext (
   CFAllocatorRef alloc,
   SSLProtocolSide protocolSide,
   SSLConnectionType connectionType
) {
    SSLContextRef sslContext = original_SSLCreateContext(alloc, protocolSide, connectionType);
    
    // Immediately set the kSSLSessionOptionBreakOnServerAuth option in order to disable cert validation
    original_SSLSetSessionOption(sslContext, kSSLSessionOptionBreakOnServerAuth, true);
    return sslContext;
}


// Hook SSLHandshake()
static OSStatus (*original_SSLHandshake)(
    SSLContextRef context
);

static OSStatus replaced_SSLHandshake(
    SSLContextRef context
) {
    OSStatus result = original_SSLHandshake(context);

    // Hijack the flow when breaking on server authentication
    if (result == errSSLServerAuthCompleted) {
        // Do not check the cert and call SSLHandshake() again
        return original_SSLHandshake(context);
    }
    else
        return result;
}


%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Should we enable the hook ?
	if (shouldHookFromPreference(@"killSwitchSSLHandshake")) {
        NSLog(@"SSL Kill Switch - Hook Enabled.");
        MSHookFunction((void *) SSLHandshake,(void *)  replaced_SSLHandshake, (void **) &original_SSLHandshake);
        MSHookFunction((void *) SSLSetSessionOption,(void *)  replaced_SSLSetSessionOption, (void **) &original_SSLSetSessionOption);
        MSHookFunction((void *) SSLCreateContext,(void *)  replaced_SSLCreateContext, (void **) &original_SSLCreateContext);
    }
    else {
    	NSLog(@"SSL Kill Switch - Hook Disabled.");
        }

    [pool drain];
}

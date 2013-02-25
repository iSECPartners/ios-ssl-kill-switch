#import "TestSSLKillSwitch.h"

@implementation TestSSLKillSwitch

+ (void)runAllTests {
    [self testNSURLConnectionInstanceMethods];
	[self testNSURLConnectionClassMethods];
}


+ (void)testNSURLConnectionClassMethods {
    SSLPinnedNSURLConnectionDelegate* deleg = [[SSLPinnedNSURLConnectionDelegate alloc] init];
    [NSURLConnection connectionWithRequest: [NSURLRequest requestWithURL:
		  [NSURL URLWithString:@"https://www.isecpartners.com/?method=connectionWithRequest"]]
	   delegate:deleg];
    [deleg release]; // Give ownership to the connection
}


+ (void)testNSURLConnectionInstanceMethods {
	SSLPinnedNSURLConnectionDelegate* deleg = [[SSLPinnedNSURLConnectionDelegate alloc] init];
	NSURLConnection *conn = [[NSURLConnection alloc] 
        initWithRequest:[NSURLRequest requestWithURL:
			[NSURL URLWithString:@"https://www.isecpartners.com/?method=initWithRequest:delegate:"]]
        delegate:deleg];
	[conn start];

	NSURLConnection *conn2 = [[NSURLConnection alloc]
	    initWithRequest:[NSURLRequest requestWithURL:
			[NSURL URLWithString:@"https://www.isecpartners.com/?method=initWithRequest:delegate:startImmediately:"]]
        delegate:deleg
        startImmediately:NO];
    [conn2 start];
    [deleg release]; // Give ownership to the connection
}



@end



@implementation SSLPinnedNSURLConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"SSLPinnedNSURLConnectionDelegate - failed: %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"SSLPinnedNSURLConnectionDelegate - received %d bytes", [data length]);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"SSLPinnedNSURLConnectionDelegate - success: %@", [[response URL] host]);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    // Pin the wrong CA certificate => connection should only work if SSL Kill Switch is enabled
    
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
        SecTrustResultType trustResult;

        // Load the anchor certificate
        NSString *certPath = [[NSString alloc] initWithFormat:@"%@/VeriSignClass3PublicPrimaryCertificationAuthority-G5.der", [[NSBundle mainBundle] bundlePath]];
        NSData *anchorCertData = [[NSData alloc] initWithContentsOfFile:certPath];
        if (anchorCertData == nil) {
            NSLog(@"Failed to load the certificates");
            [[challenge sender] cancelAuthenticationChallenge: challenge];
            return;
        }
        
        // Pin the anchor CA and validate the certificate chain
        SecCertificateRef anchorCertificate = SecCertificateCreateWithData(NULL, (CFDataRef)(anchorCertData));
        NSArray *anchorArray = [NSArray arrayWithObject:(id)(anchorCertificate)];
        SecTrustSetAnchorCertificates(serverTrust, (CFArrayRef)(anchorArray));
        SecTrustEvaluate(serverTrust, &trustResult);
        CFRelease(anchorCertificate);

        if (trustResult == kSecTrustResultUnspecified) {
            // Continue connecting
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
                 forAuthenticationChallenge:challenge];
        }
        else {
            // Certificate chain validation failed; cancel the connection
            [[challenge sender] cancelAuthenticationChallenge: challenge];
        }
    }
}
@end


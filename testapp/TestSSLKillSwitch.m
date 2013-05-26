#import "TestSSLKillSwitch.h"

@implementation TestSSLKillSwitch

+ (void)runAllTests {
    [self testNSURLConnectionSSLPinning];
    [self testSecTrustEvaluateSSLPinning];
}


+ (void)testNSURLConnectionSSLPinning {
    // Test the Kill Switch on NSURLConnection
    // The connections will only work if SSL Kill Switch is enabled
    SSLPinnedNSURLConnectionDelegate* deleg1 = [[SSLPinnedNSURLConnectionDelegate1 alloc] init];
    NSURLConnection *conn = [[NSURLConnection alloc]
                             initWithRequest:[NSURLRequest requestWithURL:
                                              [NSURL URLWithString:@"https://www.isecpartners.com/"]]
                             delegate:deleg1];
    [conn start];
    [deleg1 release]; // Give ownership to the connection
    
    
    SSLPinnedNSURLConnectionDelegate* deleg2 = [[SSLPinnedNSURLConnectionDelegate2 alloc] init];
    NSURLConnection *conn2 = [[NSURLConnection alloc]
                              initWithRequest:[NSURLRequest requestWithURL:
                                               [NSURL URLWithString:@"https://www.isecpartners.com/"]]
                              delegate:deleg2
                              startImmediately:NO];
    [conn2 start];
    [deleg2 release]; // Give ownership to the connection
}


+ (void)testSecTrustEvaluateSSLPinning {
    // Test the Kill Switch on SecTrustEvaluate()
    // The connections will only work if SSL Kill Switch is enabled
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    StreamDelegate *inStreamDelegate = [[StreamDelegate alloc] init];
    StreamDelegate *outStreamDelegate = [[StreamDelegate alloc] init];
    
    NSURL *website = [NSURL URLWithString:@"https://www.isecpartners.com"];
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)[website host], 443, &readStream, &writeStream);
    
    NSInputStream *inStream = (NSInputStream *)readStream;
    NSOutputStream *outStream = (NSOutputStream *) writeStream;
    
    [outStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    [inStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    // Use an invalid hostname for cert validation to make the connection fail
    NSDictionary *sslSettings = [NSDictionary dictionaryWithObjectsAndKeys: @"www.bad.com", (id)kCFStreamSSLPeerName, nil];
    [inStream setProperty: sslSettings forKey: (NSString *)kCFStreamPropertySSLSettings];
    [outStream setProperty: sslSettings forKey: (NSString *)kCFStreamPropertySSLSettings];
    
    CFReadStreamSetProperty(readStream, kCFStreamPropertySSLSettings, sslSettings);
    
    [inStream setDelegate:inStreamDelegate];
    [outStream setDelegate:outStreamDelegate];
    
    [inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inStream open];
    [outStream open];
    [outStream write: "GET / HTTP/1.1\r\n" maxLength:20];
}


@end



@implementation StreamDelegate

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"%@ - Received: %x", NSStringFromClass([self class]), streamEvent);
    switch(streamEvent) {
        case NSStreamEventHasBytesAvailable:
            NSLog(@"%@ - Connection Succeeded");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"%@ - Error: %@", NSStringFromClass([self class]), [[theStream streamError] localizedDescription]);
            [theStream release];
            break;
    }
}

@end



@implementation SSLPinnedNSURLConnectionDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@ - failed: %@", NSStringFromClass([self class]), error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%@ - received %d bytes", NSStringFromClass([self class]), [data length]);
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%@ - success: %@", NSStringFromClass([self class]), [[response URL] host]);
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    NSLog(@"%@ - redirect: %@", NSStringFromClass([self class]), [[request URL] host]);
    return request;
}

- (void)handleAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge  {
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



@implementation SSLPinnedNSURLConnectionDelegate1 {
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self handleAuthenticationChallenge:challenge];
}
@end


@implementation SSLPinnedNSURLConnectionDelegate2 {
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [self handleAuthenticationChallenge:challenge];   
}
@end

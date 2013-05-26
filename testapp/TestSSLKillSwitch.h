@interface TestSSLKillSwitch: NSObject {
}

+ (void)runAllTests;
+ (void)testNSURLConnectionSSLPinning;
+ (void)testSecTrustEvaluateSSLPinning;

@end



@interface StreamDelegate: NSObject <NSStreamDelegate>
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent;
@end


// NSURLConnectionDelegate - Generic class
@interface SSLPinnedNSURLConnectionDelegate: NSObject {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
- (void)handleAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
@end


// NSURLConnectionDelegate - Custom cert validation - Strategy #1
@interface SSLPinnedNSURLConnectionDelegate1: SSLPinnedNSURLConnectionDelegate {
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
@end


// NSURLConnectionDelegate - Custom cert validation - Strategy #2
@interface SSLPinnedNSURLConnectionDelegate2: SSLPinnedNSURLConnectionDelegate {
}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
@end


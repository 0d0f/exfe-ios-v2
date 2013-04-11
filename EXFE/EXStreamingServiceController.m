//
//  EXStreamingServiceController.m
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import "EXStreamingServiceController.h"

#define kDefaultServiceTimeoutInterval  (60.0f)
#define kDefaultHeartBeatInterval       (30.0f)
#define kDefaultInvokeInterval          (5.0f)

@interface EXStreamingServiceController ()
@property (nonatomic, retain) NSTimer   *invokeTimer;
@property (nonatomic, retain) NSTimer   *heartBeatTimer;
@property (nonatomic, copy) NSString *path;
@end

@implementation EXStreamingServiceController

- (id)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.client = [[[AFHTTPClient alloc] initWithBaseURL:self.baseURL] autorelease];
        self.client.parameterEncoding = AFJSONParameterEncoding;
        
        // Default
        self.serviceState = kEXStreamingServiceStateReady;
        self.serviceTimeoutInterval = kDefaultServiceTimeoutInterval;
        self.heartBeatInterval = kDefaultHeartBeatInterval;
        self.invokeInterval = kDefaultInvokeInterval;
    }
    
    return self;
}

- (void)dealloc {
    [self stopStreaming];
    [_path release];
    [_outputStream release];
    [_client release];
    [_baseURL release];
    [super dealloc];
}

#pragma mark - Runloop
- (void)invokeRunloop:(NSTimer *)timer {
    if (_invokeHandler) {
        _invokeHandler();
    }
}

- (void)heartBeatRunloop:(NSTimer *)timer {
    if (_heartBeatHandler) {
        _heartBeatHandler();
    }
}

#pragma mark - Public
- (void)startStreamingWithPath:(NSString *)path
                       success:(StreamingSuccessBlock)successHandler
                       failure:(StreamingFailureBlock)failureHandler {
    if (self.serviceState == kEXStreamingServiceStateGoing) {
        [self stopStreaming];
    }
    
    self.serviceState = kEXStreamingServiceStateGoing;
    
    self.streamingSuccessHanlder = successHandler;
    self.streamingFailureHandler = failureHandler;
    
    self.path = path;
    
    // fire timer
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:self.heartBeatInterval
                                                               target:self
                                                             selector:@selector(heartBeatRunloop:)
                                                             userInfo:nil
                                                              repeats:YES];
        
        self.invokeTimer = [NSTimer scheduledTimerWithTimeInterval:self.invokeInterval
                                                            target:self
                                                          selector:@selector(invokeRunloop:)
                                                          userInfo:nil
                                                           repeats:YES];
    });
    
    // request
    NSMutableURLRequest *request = [self.client requestWithMethod:@"GET"
                                                             path:path
                                                       parameters:nil];
    request.timeoutInterval = self.serviceTimeoutInterval = kDefaultServiceTimeoutInterval;
    AFHTTPRequestOperation *operation = [self.client HTTPRequestOperationWithRequest:request
                                                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                 dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                                                                                     NSLog(@"Streaming Failure!");
#endif
                                                                                     // make sure kvo on main thread
                                                                                     self.serviceState = kEXStreamingServiceStateReady;
                                                                                 });
                                                                                 
                                                                                 if (_streamingFailureHandler) {
                                                                                     _streamingFailureHandler(operation, nil);
                                                                                 }
                                                                             }
                                                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                 dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                                                                                     NSLog(@"Streaming Failure!");
#endif
                                                                                     // make sure kvo on main thread
                                                                                     self.serviceState = kEXStreamingServiceStateReady;
                                                                                 });
                                                                                 
                                                                                 if (_streamingFailureHandler) {
                                                                                     _streamingFailureHandler(operation, error);
                                                                                 }
                                                                             }];
    if (self.outputStream) {
        operation.outputStream = self.outputStream;
    }
    
    // start
    [self.client.operationQueue addOperation:operation];
}

- (void)stopStreaming {
    self.serviceState = kEXStreamingServiceStateReady;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.heartBeatTimer isValid]) {
            [self.heartBeatTimer invalidate];
            self.heartBeatTimer = nil;
        }
        
        if ([self.invokeTimer isValid]) {
            [self.invokeTimer invalidate];
            self.invokeTimer = nil;
        }
    });
    if (self.outputStream) {
        [self.outputStream close];
        self.outputStream = nil;
    }
    [self.client cancelAllHTTPOperationsWithMethod:@"GET" path:self.path];
}

@end

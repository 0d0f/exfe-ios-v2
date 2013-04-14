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
@property (nonatomic, retain) AFHTTPRequestOperation *operation;
@end

@implementation EXStreamingServiceController

- (id)initWithBaseURL:(NSURL *)baseURL {
    self = [super init];
    if (self) {
        self.baseURL = baseURL;
        self.client = [[[AFHTTPClient alloc] initWithBaseURL:self.baseURL] autorelease];
        self.client.parameterEncoding = AFJSONParameterEncoding;
        [self.client setDefaultHeader:@"Accept" value:@"application/json"];
        
        // Default
        self.serviceState = kEXStreamingServiceStateReady;
        self.serviceTimeoutInterval = kDefaultServiceTimeoutInterval;
        self.heartBeatInterval = kDefaultHeartBeatInterval;
        self.invokeInterval = kDefaultInvokeInterval;
    }
    
    return self;
}

- (void)dealloc {
    if (self.serviceState == kEXStreamingServiceStateGoing) {
        [self stopStreaming];
    }
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
    NSMutableURLRequest *request = [self.client requestWithMethod:@"POST"
                                                             path:path
                                                       parameters:nil];
    request.timeoutInterval = self.serviceTimeoutInterval = kDefaultServiceTimeoutInterval;
    self.operation = [self.client HTTPRequestOperationWithRequest:request
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
                                                                                     if (_streamingFailureHandler) {
                                                                                         _streamingFailureHandler(operation, error);
                                                                                     }
                                                                                 });
                                                                             }];
    if (self.outputStream) {
        _operation.outputStream = self.outputStream;
    }
    
    // start
    [self.client.operationQueue addOperation:_operation];
}

- (void)stopStreaming {
    self.serviceState = kEXStreamingServiceStateReady;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_heartBeatTimer isValid]) {
            [self.heartBeatTimer invalidate];
            self.heartBeatTimer = nil;
        }
        
        if ([_invokeTimer isValid]) {
            [self.invokeTimer invalidate];
            self.invokeTimer = nil;
        }
    });
    
    if (_operation.outputStream) {
        [_operation.outputStream close];
        _operation.outputStream = nil;
    }
    [_operation cancel];
    [self.client.operationQueue cancelAllOperations];
}

@end

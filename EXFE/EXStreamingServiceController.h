//
//  EXStreamingServiceController.h
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import <Foundation/Foundation.h>

#import <RestKit/RestKit.h>

typedef void (^StreamingSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^StreamingFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);
typedef void (^InvokeBlock)(void);
typedef void (^HeartBeatBlock)(void);
typedef enum {
    kEXStreamingServiceStateReady = 0,
    kEXStreamingServiceStateGoing
} EXStreamingServiceState;

@interface EXStreamingServiceController : NSObject

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, retain) NSOutputStream *outputStream; // should be set
@property (nonatomic, assign) EXStreamingServiceState serviceState;
@property (nonatomic, retain) AFHTTPClient  *client;

@property (nonatomic, assign) NSTimeInterval serviceTimeoutInterval;    // Default as 60 secs
@property (nonatomic, copy) StreamingSuccessBlock   streamingSuccessHanlder;
@property (nonatomic, copy) StreamingFailureBlock   streamingFailureHandler;

// heart beat
@property (nonatomic, assign) NSTimeInterval heartBeatInterval;    // Default as 30 secs
@property (nonatomic, copy) HeartBeatBlock heartBeatHandler;  // will invoke on main thread

// invoke
@property (nonatomic, assign) NSTimeInterval invokeInterval;    // Default as 5 secs
@property (nonatomic, copy) InvokeBlock invokeHandler;    // will invoke on main thread

- (id)initWithBaseURL:(NSURL *)baseURL;

- (void)startStreamingWithPath:(NSString *)path
                       success:(StreamingSuccessBlock)successHandler
                       failure:(StreamingFailureBlock)failureHandler;
- (void)stopStreaming;

@end

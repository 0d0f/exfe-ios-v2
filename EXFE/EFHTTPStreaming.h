//
//  EFHTTPStreaming.h
//  EXFE
//
//  Created by 0day on 13-7-19.
//
//

#import <Foundation/Foundation.h>

#define StreamBufSize 2048

@class EXStreamer;

@protocol EFHTTPStreamingDelegate<NSObject>

@required
- (void)completedRead:(NSString*) str;

@optional
- (void)streamEvent:(CFStreamEventType)eventType;

@end


@interface EFHTTPStreaming : NSObject{
    CFReadStreamRef _stream;
    NSDictionary    *_httpHeaders;
    NSString        *_strFromStream;
}

@property (nonatomic, weak)     id<EFHTTPStreamingDelegate> delegate;
@property (nonatomic, assign)   NSUInteger                  retryTimes;     // Default as INFINITY

- (id)initWithURL:(NSURL *)aURL;

- (void)open;
- (void)close;

- (void)reconnect;

- (void)handleReadFromStream:(CFReadStreamRef)aStream
                   eventType:(CFStreamEventType)eventType;

void ReadStreamCallBack(CFReadStreamRef aStream, CFStreamEventType eventType, void* inClientInfo);

@end


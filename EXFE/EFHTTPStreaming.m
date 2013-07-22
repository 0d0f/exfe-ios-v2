//
//  EFHTTPStreaming.m
//  EXFE
//
//  Created by 0day on 13-7-19.
//
//

#import "EFHTTPStreaming.h"

#define kDefaultRetryTimes  INFINITY

@interface EFHTTPStreaming ()

@property (nonatomic, strong) NSURL         *url;
@property (nonatomic, strong) NSThread      *streamingThread;
@property (nonatomic, weak)   NSRunLoop     *streamingRunloop;
@property (nonatomic, assign) NSUInteger    *retriedTimes;

@end

@implementation EFHTTPStreaming

void ReadStreamCallBack( CFReadStreamRef aStream, CFStreamEventType eventType, void *inClientInfo )
{
	EFHTTPStreaming* streamer = (__bridge EFHTTPStreaming *)inClientInfo;
	[streamer handleReadFromStream:aStream eventType:eventType];
}

- (id)initWithURL:(NSURL *)aURL {
	self = [super init];
	if (self != nil) {
		self.url = aURL;
        _strFromStream = @"";
        
        self.retriedTimes = 0;
        self.retryTimes = kDefaultRetryTimes;
        
        self.streamingThread = [[NSThread alloc] initWithTarget:self selector:@selector(streamingRunLoopThreadEntry) object:nil];
        self.streamingThread.threadPriority = 0.3f;
        [self.streamingThread start];
	}
	return self;
}

#pragma mark - Streaming Runloop

- (void)streamingRunLoopThreadEntry {
    self.streamingRunloop = [NSRunLoop currentRunLoop];
    
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] run];
        }
    }
}

#pragma mark -

- (void)handleReadFromStream:(CFReadStreamRef)aStream
                   eventType:(CFStreamEventType)eventType {
    
    [self.delegate streamEvent:eventType];
    
    if (eventType == kCFStreamEventHasBytesAvailable) {
        if (!_httpHeaders)
        {
            CFTypeRef message = CFReadStreamCopyProperty(_stream, kCFStreamPropertyHTTPResponseHeader);
            _httpHeaders =  (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields((CFHTTPMessageRef)message);
            CFRelease(message);
        }
        UInt8 buffer[StreamBufSize];
        int length = 0;
        @synchronized(self){
            if (!CFReadStreamHasBytesAvailable(_stream)) {
                [_delegate completedRead:[_strFromStream copy]];
                return;
            }
            
            do {
                memset(buffer,0,StreamBufSize);
                length = 0;
                length = CFReadStreamRead(_stream, buffer,StreamBufSize);
                int newLineIdx = -1;
                for (int i = 0; i < length; i++) {
                    if (buffer[i] == '\n') {
                        newLineIdx = i;
                    }
                }
                
                NSString *to_add = [[NSString alloc] initWithBytes:buffer length:length encoding:NSASCIIStringEncoding];
                if (to_add != nil) {
                    if (newLineIdx > 0) {
                        _strFromStream = [_strFromStream stringByAppendingString:[to_add substringToIndex:newLineIdx]];
                    } else {
                        _strFromStream = [_strFromStream stringByAppendingString:to_add];
                    }
                    
                    if (newLineIdx > 0) {
                        _strFromStream = [_strFromStream stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        [_delegate completedRead:[_strFromStream copy]];
                        _strFromStream = [to_add substringFromIndex:newLineIdx];
                    }
                }
            } while (length > 0);
        }
    } else if (eventType == kCFStreamEventErrorOccurred) {
        [self reconnect];
    }
}

- (void)open {
    NSURL *serverurl = self.url;
    CFHTTPMessageRef message= CFHTTPMessageCreateRequest(NULL, (CFStringRef)@"POST", (__bridge CFURLRef)serverurl, kCFHTTPVersion1_1);
    
    _stream = CFReadStreamCreateForHTTPRequest(NULL, message);
    CFRelease(message);
    
    CFStreamClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFOptionFlags flags = kCFStreamEventNone | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventOpenCompleted;
    
    if (CFReadStreamSetClient(_stream, flags, ReadStreamCallBack, &context)) {
        CFReadStreamScheduleWithRunLoop(_stream, [self.streamingRunloop getCFRunLoop], kCFRunLoopDefaultMode);
//        CFReadStreamScheduleWithRunLoop(_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        if (!CFReadStreamOpen(_stream)) {
            CFRelease(_stream);
            _stream = NULL;
            
            [self reconnect];
            
            return;
        }
    }
}

- (void)close {
    if (_stream) {
        CFReadStreamSetClient(_stream, 0, NULL, NULL);
        CFReadStreamClose(_stream);
        CFRelease(_stream);
        _stream = NULL;
    }
}

- (void)reconnect {
    [self close];
    [self open];
}

@end

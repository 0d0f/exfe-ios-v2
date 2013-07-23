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
	}
	return self;
}

#pragma mark -

- (void)handleReadFromStream:(CFReadStreamRef)aStream
                   eventType:(CFStreamEventType)eventType {
    if (eventType == kCFStreamEventHasBytesAvailable) {
        UInt8 buffer[StreamBufSize];
        int length = 0;
        
        @synchronized(self){
            do {
                if (!CFReadStreamHasBytesAvailable(_stream)) {
                    [_delegate completedRead:[_strFromStream copy]];
                    return;
                }
                
                memset(buffer,0,StreamBufSize);
                length = 0;
                length = CFReadStreamRead(_stream, buffer, StreamBufSize);
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
                         
                        if (newLineIdx >= to_add.length - 1) {
                            _strFromStream = @"";
                        } else {
                            _strFromStream = [to_add substringFromIndex:newLineIdx];
                        }
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
    CFHTTPMessageRef message = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)@"POST", (__bridge CFURLRef)serverurl, kCFHTTPVersion1_1);
    
    _stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, message);
    CFRelease(message);
    
    CFStreamClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFOptionFlags flags = kCFStreamEventNone | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventOpenCompleted;
    
    if (CFReadStreamSetClient(_stream, flags, ReadStreamCallBack, &context)) {
        CFReadStreamScheduleWithRunLoop(_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
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
        CFReadStreamClose(_stream);
        CFReadStreamUnscheduleFromRunLoop(_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamSetClient(_stream, 0, NULL, NULL);
        CFRelease(_stream);
        _stream = NULL;
    }
}

- (void)reconnect {
    [self close];
    [self open];
}

@end

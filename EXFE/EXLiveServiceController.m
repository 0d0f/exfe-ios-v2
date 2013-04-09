//
//  EXLiveServiceController.m
//  EXFE
//
//  Created by 0day on 13-4-9.
//
//

#import "EXLiveServiceController.h"

#import "EXStreamingServiceController.h"
#import "AppDelegate.h"
#import "User+EXFE.h"
#import "Card.h"

#define kMinRegistCardsDuration             (5.0f)
#define kServerStreamingTimeroutInterval    (60.0f)

@interface EXLiveServiceController ()
@property (nonatomic, retain) EXStreamingServiceController *streamingService;
@property (nonatomic, retain) NSDate *latestRegistReqeustDate;
@property (nonatomic, assign) BOOL shouldInvokeLater;
@property (nonatomic, retain) NSRecursiveLock *lock;
@end

@interface EXLiveServiceController (Private)
- (void)_setRunning:(BOOL)isRunning;
- (void)_cleanUp;
@end

@implementation EXLiveServiceController

+ (EXLiveServiceController *)defaultService {
    static EXLiveServiceController *DefaultService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DefaultService = [[self alloc] init];
    });
    
    return DefaultService;
}

- (id)init {
    self = [super init];
    if (self) {
        _streamingService = [[EXStreamingServiceController alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]];
        
        NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
        outputStream.delegate = self;
        _streamingService.outputStream = outputStream;
        
        _streamingService.invokeHandler = ^{
            if (self.shouldInvokeLater) {
                [self sendLiveCardsRequest];
                self.shouldInvokeLater = NO;
            }
        };
        _streamingService.heartBeatHandler = ^{
            [self sendLiveCardsRequest];
        };
        
        [self _setRunning:NO];
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
    [self _cleanUp];
    [_lock release];
    [_token release];
    [_cardID release];
    [_streamingService release];
    [super dealloc];
}

- (void)start {
    [self _setRunning:YES];
    [self invokeUserCardUpdate];
}

- (void)stop {
    [self _setRunning:NO];
    
    if (self.streamingService) {
        [self.streamingService stopStreaming];
    }
    if (self.cleanUpWhenStoped) {
        [self _cleanUp];
    }
}

- (void)invokeUserCardUpdate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self canSendRequestNow]) {
            [self sendLiveCardsRequest];
        } else {
            self.shouldInvokeLater = YES;
        }
    });
}

#pragma mark - request
- (BOOL)canSendRequestNow {
    NSDate *now = [NSDate date];
    BOOL canSendRequest = YES;
    
    if (self.latestRegistReqeustDate) {
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:self.latestRegistReqeustDate];
        if (timeInterval >= kMinRegistCardsDuration) {
            self.latestRegistReqeustDate = now;
            canSendRequest = YES;
        } else {
            canSendRequest = NO;
        }
    } else {
        self.latestRegistReqeustDate = now;
        canSendRequest = YES;
    }
    
    return canSendRequest;
}

- (void)sendLiveCardsRequest {
    [_lock tryLock];
    
    NSDictionary *params = [self.dataSource postBodyParamForliveServiceController:self];
    
    NSString *path = nil;
    if (self.token != nil && self.token.length) {
        path = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT,@"live/cards", self.token];
    } else {
        path = [NSString stringWithFormat:@"%@/%@",SERVICE_ROOT,@"live/cards"];
    }
    
    [self.streamingService.client postPath:path
                                parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (operation.response.statusCode >= 200 &&
                                           operation.response.statusCode < 400) {
                                           NSArray *responseList = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                                           // 只有第一次请求时返回，其余时候应该为空
                                           if ([responseList count] >= 2) {
                                               NSString *token = responseList[0];//[[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] autorelease];
                                               token = [token stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                               token = [token stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                               
                                               NSString *cardID = responseList[1];
                                               
                                               if (self.token != nil &&
                                                   self.token.length != 0) {
                                                   if (kEXStreamingServiceStateReady == self.streamingService.serviceState) {
                                                       NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                                                       [self.streamingService startStreamingWithPath:streamingPath
                                                                                             success:nil
                                                                                             failure:nil];
                                                   }
                                               } else {
                                                   [self stop];
                                                   [self _cleanUp];
                                                   
                                                   _token = [token copy];
                                                   _cardID = [cardID copy];
                                                   
                                                   if ([self.delegate respondsToSelector:@selector(liveServiceController:didGetToken:andCardID:)]) {
                                                       [self.delegate liveServiceController:self
                                                                                didGetToken:self.token
                                                                                  andCardID:self.cardID];
                                                   }
                                                   
                                                   NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                                                   [self.streamingService startStreamingWithPath:streamingPath
                                                                                         success:nil
                                                                                         failure:nil];
                                               }
                                           }
                                       }
                                       
                                       [_lock unlock];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if (operation.response.statusCode >= 400 &&
                                           operation.response.statusCode < 500) {
                                           [self stop];
                                           [self _cleanUp];
                                           
                                           [self performSelector:_cmd];
                                       }
                                       [_lock unlock];
                                   }];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"HasBytesAvailable");
            break;
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
        case NSStreamEventEndEncountered:
            NSLog(@"Stream closed");
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            NSData *data = (NSData *)[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            NSString *string = [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:[NSString defaultCStringEncoding]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
            
            NSArray *array = [string componentsSeparatedByString:@"\n"];
            
            if ([array count] == 0) {
                [self invokeUserCardUpdate];
            } else {
                NSString *lastJSON = [array lastObject];
                data = [lastJSON dataUsingEncoding:NSUTF8StringEncoding];
                
                NSArray *cardsInDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                
                NSMutableSet *othersCards = [NSMutableSet setWithCapacity:[cardsInDict count]];
                Card *meCard = [Card cardWithDictionary:[self.dataSource meCardDictionaryForliveServiceController:self]];
                for (NSDictionary *cardDict in cardsInDict) {
                    Card *newCard = [Card cardWithDictionary:cardDict];
                    if (![meCard isEqualToCard:newCard]) {
                        [othersCards addObject:newCard];
                    }
                }
                
                NSSet *others = [[othersCards copy] autorelease];
                
                dispatch_async(dispatch_get_main_queue(), ^{
#ifdef DEBUG
                    NSLog(@"Card JSON:\n%@", lastJSON);
                    NSLog(@"\nMe:\n%@\nOthers:\n%@", meCard, othersCards);
#endif
                    
                    [self.delegate liveServiceController:self
                                                didGetMe:meCard
                                                  others:others];
                });
            }
            
            NSLog(@"Stream HasSpaceAvailable");
            break;
        }
        default:
            NSLog(@"Unknown event: %@ : %d", stream, eventCode);
    }
}


#pragma mark - Private
- (void)_setRunning:(BOOL)isRunning {
    if (isRunning == _isRunning)
        return;
    [self willChangeValueForKey:@"isRunning"];
    _isRunning = isRunning;
    [self didChangeValueForKey:@"isRunning"];
}

- (void)_cleanUp {
    [_token release];
    [_cardID release];
}

@end

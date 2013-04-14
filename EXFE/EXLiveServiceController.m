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

//static NSString *Token = nil;
//static NSString *CardID = nil;

#define kMinRegistCardsDuration             (5.0f)
#define kServerStreamingTimeroutInterval    (60.0f)

@interface EXLiveServiceController ()
@property (nonatomic, retain) EXStreamingServiceController *streamingService;
@property (nonatomic, retain) NSDate *latestRegistReqeustDate;
@property (nonatomic, assign) BOOL shouldInvokeLater;
@property (nonatomic, retain) NSRecursiveLock *lock;
@property (nonatomic, assign) BOOL isRegisting;
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
        [self _setRunning:NO];
        self.isRegisting = NO;
        self.cleanUpWhenStoped = NO;
    }
    
    return self;
}

- (void)dealloc {
    [self stop];
    [self _cleanUp];
    [_lock release];
    [_token release];
    [_cardID release];
    [_latestMeCard release];
    [_latestOthersCards release];
    [_streamingService release];
    [super dealloc];
}

- (void)initStreamingService {
    _streamingService = [[EXStreamingServiceController alloc] initWithBaseURL:[NSURL URLWithString:SERVICE_ROOT]];
    _streamingService.invokeHandler = ^{
        if (self.shouldInvokeLater) {
            [self sendLiveCardsRequest];
            self.shouldInvokeLater = NO;
        }
    };
    _streamingService.heartBeatHandler = ^{
        [self sendLiveCardsRequest];
    };
}

- (void)start {
    [self initStreamingService];
    [self forceInvokeUserCardUpdate];
    
    [self _setRunning:YES];
}

- (void)restart {
    [self stop];
    [self start];
}

- (void)stop {
    [self _setRunning:NO];
    
    if (self.streamingService) {
        [self.streamingService stopStreaming];
        self.streamingService = nil;
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

- (void)forceInvokeUserCardUpdate {
    [self sendLiveCardsRequest];
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
    
    if (self.isRegisting)
        return;
    
    NSDictionary *params = [self.dataSource postBodyParamForliveServiceController:self];
    
    NSString *path = nil;
    if (self.token != nil && self.token.length) {
        path = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT,@"live/cards", self.token];
        self.isRegisting = NO;
    } else {
        path = [NSString stringWithFormat:@"%@/%@",SERVICE_ROOT,@"live/cards"];
        self.isRegisting = YES;
    }
    
    [self.streamingService.client postPath:path
                                parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       if (operation.response.statusCode >= 200 &&
                                           operation.response.statusCode < 400 &&
                                           responseObject) {
                                           NSArray *responseList = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                                           // 只有第一次请求时返回，其余时候应该为空
                                           if ([responseList count] >= 2 &&
                                               (nil == _token || !_token.length) &&
                                               (nil == _cardID || !_cardID.length)) {
                                               NSString *token = responseList[0];
                                               token = [token stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                               token = [token stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                               
                                               NSString *cardID = responseList[1];
                                               
                                               [self stop];
                                               [self initStreamingService];
                                               
                                               _token = [token copy];
                                               _cardID = [cardID copy];
                                               
                                               if ([self.delegate respondsToSelector:@selector(liveServiceController:didGetToken:andCardID:)]) {
                                                   [self.delegate liveServiceController:self
                                                                            didGetToken:self.token
                                                                              andCardID:self.cardID];
                                               }
                                               
                                               if (kEXStreamingServiceStateReady == self.streamingService.serviceState) {
                                                   NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
                                                   [outputStream setDelegate:self];
                                                   self.streamingService.outputStream = outputStream;
                                                   
                                                   NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                                                   [self.streamingService startStreamingWithPath:streamingPath
                                                                                         success:nil
                                                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                                                             if (error.code != NSURLErrorCancelled) {
                                                                                                 if ([self.delegate respondsToSelector:@selector(liveServiceControllerStreamDidFail:)]) {
                                                                                                     [self.delegate liveServiceControllerStreamDidFail:self];
                                                                                                 }
                                                                                                 [self restart];
                                                                                             }
                                                                                         }];
                                               }
                                               
                                               self.isRegisting = NO;
                                               [self performSelector:_cmd];
                                           } else {
                                               if (kEXStreamingServiceStateReady == self.streamingService.serviceState) {
                                                   NSOutputStream *outputStream = [NSOutputStream outputStreamToMemory];
                                                   [outputStream setDelegate:self];
                                                   self.streamingService.outputStream = outputStream;
                                                   
                                                   NSString *streamingPath = [NSString stringWithFormat:@"%@/%@?token=%@",SERVICE_ROOT, @"live/streaming", self.token];
                                                   [self.streamingService startStreamingWithPath:streamingPath
                                                                                         success:nil
                                                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                                                                             if (error.code != NSURLErrorCancelled) {
                                                                                                 if ([self.delegate respondsToSelector:@selector(liveServiceControllerStreamDidFail:)]) {
                                                                                                     [self.delegate liveServiceControllerStreamDidFail:self];
                                                                                                 }
                                                                                                 [self restart];
                                                                                             }
                                                                                         }];
                                               }
                                           }
                                       }
                                       
                                       [_lock unlock];
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"%@", error);
                                       if (operation.response.statusCode >= 400 &&
                                           operation.response.statusCode < 500) {
                                           if ([self.delegate respondsToSelector:@selector(liveServiceControllerTokenDidInvalid:willRetry:)]) {
                                               [self.delegate liveServiceControllerTokenDidInvalid:self willRetry:YES];
                                           }
                                           [self _cleanUp];
                                           self.isRegisting = NO;
                                           
                                           [self restart];
                                       } else if (NSURLErrorCancelled != error.code) {
                                           [self restart];
                                       }
                                       
                                       [_lock unlock];
                                   }];
}

#pragma mark - NSStreamDelegate
- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode{
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            if ([self.delegate respondsToSelector:@selector(liveServiceControllerStreamDidOpen:)]) {
                [self.delegate liveServiceControllerStreamDidOpen:self];
            }
            [self forceInvokeUserCardUpdate];
            
//            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
//            NSLog(@"Stream HasBytesAvailable");
            break;
        case NSStreamEventErrorOccurred:
//            NSLog(@"Stream Can not connect to the host!");
            break;
        case NSStreamEventEndEncountered:
//            NSLog(@"Stream closed");
            break;
        case NSStreamEventHasSpaceAvailable:
        {
            NSData *data = (NSData *)[stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
            NSString *string = [[[NSString alloc] initWithBytes:[data bytes]
                                                         length:[data length]
                                                       encoding:[NSString defaultCStringEncoding]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSString *lastJSON = nil;
            NSArray *array = [string componentsSeparatedByString:@"\n"];
            if ((char)([data bytes] + [data length] - 1) == '\n') {
                lastJSON = [array lastObject];
            } else if ([array count] >= 2) {
                lastJSON = array[[array count] - 2];
            }
            
            if ([array count] == 0) {
                [self invokeUserCardUpdate];
            } else if (lastJSON) {
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
                    self.latestMeCard = meCard;
                    self.latestOthersCards = others;
                    
                    [self.delegate liveServiceController:self
                                                didGetMe:meCard
                                                  others:others];
                });
            }
            
//            NSLog(@"Stream HasSpaceAvailable");
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
    if (_token) {
        [_token release];
        _token = nil;
    }
    
    if (_cardID) {
        [_cardID release];
        _cardID = nil;
    }
}

@end

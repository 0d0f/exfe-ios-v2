//
//  EXLiveServiceController.h
//  EXFE
//
//  Created by 0day on 13-4-9.
//
//

#import <Foundation/Foundation.h>

@class EXLiveServiceController;

@protocol EXLiveServiceControllerDelegate <NSObject>
@required
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetCardsFromStreaming:(NSSet *)cards;
@optional
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetToken:(NSString *)totken andCardID:(NSString *)cardID;
- (void)liveServiceControllerTokenDidInvalid:(EXLiveServiceController *)serviceController willRetry:(BOOL)retry;
@end

@protocol EXLiveServiceControllerDataSource <NSObject>
@required
- (NSDictionary *)userCardDictionaryForliveServiceController:(EXLiveServiceController *)serviceController;
@end

@interface EXLiveServiceController : NSObject
<
NSStreamDelegate
>

@property (nonatomic, assign) BOOL cleanUpWhenStoped;   // Default as YES
@property (nonatomic, readonly) BOOL isRunning;     // kvo

@property (nonatomic, assign) id<EXLiveServiceControllerDelegate> delegate;
@property (nonatomic, assign) id<EXLiveServiceControllerDataSource> dataSource;

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, copy, readonly) NSString *cardID;

+ (EXLiveServiceController *)defaultService;

- (void)start;
- (void)stop;

- (void)invokeUserCardUpdate;

@end

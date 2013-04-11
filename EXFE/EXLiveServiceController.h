//
//  EXLiveServiceController.h
//  EXFE
//
//  Created by 0day on 13-4-9.
//
//

#import <Foundation/Foundation.h>

@class EXLiveServiceController;
@class Card;

@protocol EXLiveServiceControllerDelegate <NSObject>
@required
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetMe:(Card *)me others:(NSSet *)cards;
@optional
- (void)liveServiceController:(EXLiveServiceController *)serviceController didGetToken:(NSString *)totken andCardID:(NSString *)cardID;
- (void)liveServiceControllerTokenDidInvalid:(EXLiveServiceController *)serviceController willRetry:(BOOL)retry;
@end

@protocol EXLiveServiceControllerDataSource <NSObject>
@required
- (NSDictionary *)meCardDictionaryForliveServiceController:(EXLiveServiceController *)serviceController;
- (NSDictionary *)postBodyParamForliveServiceController:(EXLiveServiceController *)serviceController;
@end

@interface EXLiveServiceController : NSObject
<
NSStreamDelegate
>

@property (nonatomic, assign) BOOL cleanUpWhenStoped;   // Default as NO
@property (nonatomic, readonly) BOOL isRunning;     // kvo

@property (nonatomic, assign) id<EXLiveServiceControllerDelegate> delegate;
@property (nonatomic, assign) id<EXLiveServiceControllerDataSource> dataSource;

@property (nonatomic, copy, readonly) NSString *token;
@property (nonatomic, copy, readonly) NSString *cardID;

@property (nonatomic, copy) Card *latestMeCard;
@property (nonatomic, retain) NSSet *latestOthersCards;

+ (EXLiveServiceController *)defaultService;

- (void)start;
- (void)stop;

- (void)invokeUserCardUpdate;
- (void)forceInvokeUserCardUpdate;

@end

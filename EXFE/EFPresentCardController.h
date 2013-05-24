//
//  EFPresentCardController.h
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import <Foundation/Foundation.h>

@interface EFPresentCardController : NSObject

@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, assign) CGSize contentSize;   // Default as (CGSize){300.0f, 440.0f}

- (id)initWithContentViewController:(UIViewController *)viewController;

- (void)presentFromViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated withCompletionHandler:(void (^)(void))handler;

@end

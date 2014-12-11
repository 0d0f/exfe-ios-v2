//
//  EFRouteXAccessViewController.h
//  EXFE
//
//  Created by 0day on 13-8-30.
//
//

#import <UIKit/UIKit.h>

@class EFRouteXAccessViewController;

@protocol EFRouteXAccessViewControllerDelegate <NSObject>

- (void)routeXAccessViewControllerButtonPressed:(EFRouteXAccessViewController *)accessViewController;

@end

@interface EFRouteXAccessViewController : UIViewController

@property (nonatomic, weak) id<EFRouteXAccessViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *crossTitle;

- (id)initWithViewFrame:(CGRect)frame;

@end

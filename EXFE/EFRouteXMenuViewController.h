//
//  EFRouteXMenuViewController.h
//  EXFE
//
//  Created by 0day on 13-9-16.
//
//

#import <UIKit/UIKit.h>

@class EFRouteXMenuViewController;
@protocol EFRouteXMenuViewControllerDelegate <NSObject>

- (void)menuViewControllerWannaShowRouteX:(EFRouteXMenuViewController *)menuViewController;

@end

@interface EFRouteXMenuViewController : UITableViewController

@property (nonatomic, weak) id<EFRouteXMenuViewControllerDelegate>  delegate;

- (void)presentFromViewController:(UIViewController *)fromViewController animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end

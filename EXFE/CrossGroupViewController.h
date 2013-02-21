//
//  CrossGroupViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import <UIKit/UIKit.h>

@class Cross;
#define kHeaderStyleFull   0
#define kHeaderStyleHalf   1


@interface CrossGroupViewController : UIViewController{
    
    NSInteger headerStyle;
    
    
    // Header
    UIView* headerView;
    UIImageView* dectorView;
    UILabel* titleView;
    // Content
    UIScrollView* container;
    // Navigation
    UIButton* btnBack;
    // Tab
}

@property (nonatomic,retain) UIViewController *currentViewController;
@property (retain,nonatomic) Cross* cross;

-(void)swapViewControllers:(UIViewController*)childViewController;




@end

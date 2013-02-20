//
//  CrossGroupViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-2-20.
//
//

#import <UIKit/UIKit.h>

@class Cross;

@interface CrossGroupViewController : UIViewController

@property (nonatomic,retain) UIViewController *currentViewController;
@property (retain,nonatomic) Cross* cross;

-(void)swapViewControllers:(UIViewController*)childViewController;

@end

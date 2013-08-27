//
//  EFCrossTabBarViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-8-26.
//
//

#import "EFTabBarViewController.h"

@class Cross;
@interface EFCrossTabBarViewController : EFTabBarViewController

@property (nonatomic, strong) Cross * cross;

- (void)refreshUI;

@end

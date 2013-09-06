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

@property (nonatomic, weak)     EXFEModel   *model;
@property (nonatomic, assign)   NSUInteger   crossId;
@property (nonatomic, strong)   Cross       *cross;

- (void)refreshUI;
- (void)fillHead:(Cross *)cross;

@end

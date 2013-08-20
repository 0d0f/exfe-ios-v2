//
//  EFMapPersonViewController.h
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import <UIKit/UIKit.h>

@class EFMapPerson;
@interface EFMapPersonViewController : UIViewController

- (id)initWithMe:(EFMapPerson *)me person:(EFMapPerson *)person;

@property (nonatomic, weak) EFMapPerson *person;
@property (nonatomic, weak) EFMapPerson *me;

@property (nonatomic, weak) UIViewController *fromController;
@property (nonatomic, assign) CGPoint location;

- (void)presentFromViewController:(UIViewController *)controller location:(CGPoint)location animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end

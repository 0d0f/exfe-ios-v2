//
//  EFGeomarkGroupViewController.h
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import <UIKit/UIKit.h>

@interface EFGeomarkGroupViewController : UITableViewController
<
UIGestureRecognizerDelegate
>

@property (nonatomic, readonly) UIViewController    *fromViewController;
@property (nonatomic, readonly) CGPoint             tapLocation;

@property (nonatomic, strong) NSArray   *geomarks;
@property (nonatomic, strong) NSArray   *people;

- (id)initWithGeomarks:(NSArray *)geomarks andPeople:(NSArray *)people;

- (void)presentFromViewController:(UIViewController *)controller tapLocation:(CGPoint)locatoin animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end

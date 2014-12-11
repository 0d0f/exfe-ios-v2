//
//  EFMapPersonViewController.h
//  EXFE
//
//  Created by 0day on 13-8-19.
//
//

#import <UIKit/UIKit.h>

@class EFMapPersonViewController;
@protocol EFMapPersonViewControllerDelegate <NSObject>

@optional

- (void)mapPersonViewControllerRequestButtonPressed:(EFMapPersonViewController *)controller;

@end

@class EFMapPerson, EFMarauderMapDataSource;
@interface EFMapPersonViewController : UIViewController

- (id)initWithDataSource:(EFMarauderMapDataSource *)dataSource person:(EFMapPerson *)person;

@property (nonatomic, weak) id<EFMapPersonViewControllerDelegate> delegate;
@property (nonatomic, weak) EFMapPerson *person;
@property (nonatomic, weak) EFMarauderMapDataSource *mapDataSource;

@property (nonatomic, weak) UIViewController    *fromController;
@property (nonatomic, assign) CGPoint           location;
@property (nonatomic, assign) BOOL              buttonEnabled;

- (void)presentFromViewController:(UIViewController *)controller location:(CGPoint)location animated:(BOOL)animated;
- (void)dismissAnimated:(BOOL)animated;

@end

//
//  EFLandingViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import <UIKit/UIKit.h>

@interface EFLandingViewController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *labelEXFE;
@property (nonatomic, retain) IBOutlet UILabel *labelDescription;
@property (nonatomic, retain) IBOutlet UIImageView *imgEXFELogo;
@property (nonatomic, retain) IBOutlet UILabel *labelStart;
@property (nonatomic, retain) IBOutlet UIImageView *imgHead;

@property (nonatomic, retain) UIViewController *currentViewController;

@end

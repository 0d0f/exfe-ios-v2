//
//  EFLandingViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-4-15.
//
//

#import <UIKit/UIKit.h>

@interface EFLandingViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *labelEXFE;
@property (nonatomic, strong) IBOutlet UILabel *labelDescription;
@property (nonatomic, strong) IBOutlet UIImageView *imgEXFELogo;
@property (nonatomic, strong) IBOutlet UILabel *labelStart;
@property (nonatomic, strong) IBOutlet UIImageView *imgHead;

@property (nonatomic, strong) UIViewController *currentViewController;

@end

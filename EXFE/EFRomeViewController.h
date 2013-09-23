//
//  EFRomeViewController.h
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TTTAttributedLabel.h"

typedef void (^actionBlock)(void);

@interface EFRomeViewController : UIViewController
<
MFMailComposeViewControllerDelegate,
TTTAttributedLabelDelegate
>

@property (nonatomic, copy) actionBlock closeButtonPressedHandler;

@property (strong, nonatomic) IBOutlet UIButton             *closeButton;
@property (nonatomic, strong) IBOutlet UILabel              *rome_title;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel   *rome_description;
@property (nonatomic, strong) IBOutlet UILabel              *much_thanks;

- (IBAction)closeButtonPressed:(id)sender;

@end

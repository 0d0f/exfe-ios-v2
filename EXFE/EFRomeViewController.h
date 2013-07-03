//
//  EFRomeViewController.h
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

typedef void (^actionBlock)(void);

@interface EFRomeViewController : UIViewController
<
MFMailComposeViewControllerDelegate
>

@property (nonatomic, copy) actionBlock closeButtonPressedHandler;

@property (strong, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;

@end

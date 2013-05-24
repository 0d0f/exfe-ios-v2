//
//  EFRomeViewController.h
//  EXFE
//
//  Created by 0day on 13-5-24.
//
//

#import <UIKit/UIKit.h>

typedef void (^actionBlock)(void);

@interface EFRomeViewController : UIViewController

@property (nonatomic, copy) actionBlock closeButtonPressedHandler;

@property (retain, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonPressed:(id)sender;

@end

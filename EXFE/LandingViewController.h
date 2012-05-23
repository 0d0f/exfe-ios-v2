//
//  LandingViewController.h
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingViewController : UIViewController{
    id delegate;
}

@property (nonatomic, assign) id delegate;

- (IBAction) SigninButtonPress:(id) sender;
- (void)SigninDidFinish;
@end

//
//  OAuthLoginViewControllerViewController.h
//  EXFE
//
//  Created by ju huo on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFEntity.h"


typedef void (^OAuthAuthenticateSuccess)(NSDictionary *param);
typedef void (^OAuthAuthenticateCancel)();

@interface OAuthLoginViewController : UIViewController
{
    UIView *toolbar;
    bool firstLoading;
    UIButton *cancelbutton;
    UILabel *titlelabel;
}
@property (nonatomic, strong) IBOutlet UIWebView* webView;

@property (nonatomic, readonly, assign) Provider provider;
@property (nonatomic, copy) NSString *external_username;
@property (nonatomic, copy) OAuthAuthenticateSuccess onSuccess;
@property (nonatomic, copy) OAuthAuthenticateCancel onCancel;

@property (nonatomic, copy) NSString *oAuthURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil provider:(Provider)provider;

@end
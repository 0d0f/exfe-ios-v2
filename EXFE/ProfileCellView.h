//
//  ProfileCellView.h
//  EXFE
//
//  Created by ju huo on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileCellView : UITableViewCell{
    IBOutlet UILabel *cellName;
    IBOutlet UILabel *cellIdentity;
    IBOutlet UILabel *isThisDevice;    
    IBOutlet UIImageView *cellAvatar;
//    IBOutlet UIImageView *cellStatus;    
    IBOutlet UIImageView *cellProvider;
    IBOutlet UIButton *verify;
    IBOutlet UILabel *statustext;
    int identity_id;
}
@property int identity_id;

- (void)setLabelName:(NSString *)_text;
- (void)setLabelIdentity:(NSString *)_text;
- (void)setStatus:(UIImage *)_img;
- (void)setAvartar:(UIImage*)_img;
- (void)setLabelStatus:(int)type;
- (void)IsThisDevice:(NSString*)devicename;
- (void)setProvider:(UIImage*)_img;
- (void)setVerifyAction:(id)target action:(SEL)action;
- (void)setStatusText:(NSString*)_text;
//- (IBAction)verify:(id)sender;
@end

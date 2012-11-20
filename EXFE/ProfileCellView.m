//
//  ProfileCellView.m
//  EXFE
//
//  Created by ju huo on 12/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ProfileCellView.h"

@implementation ProfileCellView
@synthesize identity_id;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAvartar:(UIImage*)_img
{
    cellAvatar.image=_img;
    cellAvatar.layer.cornerRadius=3;
}
- (void)setProvider:(UIImage*)_img{
    cellProvider.image=_img;
}

- (void)setLabelName:(NSString *)_text
{
    cellName.text=_text;
}

- (void)setLabelIdentity:(NSString *)_text
{
    cellIdentity.text=_text;
}

- (void)setStatus:(UIImage *)_img
{
//    cellStatus.image =_img;
    [verify setImage:_img forState:UIControlStateNormal];
    verify.tag=self.identity_id;
}
- (void)setLabelStatus:(int)type
{
    if(type==1)
    {
        cellName.frame=CGRectMake(cellName.frame.origin.x, 11, cellName.frame.size.width, cellName.frame.size.height);
    }
      
}
- (void)IsThisDevice:(NSString*)devicename
{
    if(![devicename isEqualToString:@""])
        isThisDevice.text=devicename;
    [isThisDevice setHidden:NO];
}
- (void)setVerifyAction:(id)target action:(SEL)action{
    [verify addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)setStatusText:(NSString*)_text{
    statustext.text=_text;
}
//- (IBAction)verify:(id)sender{
//    NSLog(@"verify");
//}
@end

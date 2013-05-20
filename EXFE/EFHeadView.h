//
//  EFHeadView.h
//  EFHeadAnimation
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFHeadView : UIView

@property (nonatomic, retain) UIImage *headImage;
@property (nonatomic, retain) UILabel *titleLabel;

- (void)show;
- (void)dismiss;

@end

//
//  EXCircleItemCell.h
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TapBlock)(void);
typedef void (^LongPressBlock)(void);

@class User;
@class EXVerticalAlignLabel;

@interface EXCircleItemCell : UIView

@property (retain, nonatomic) IBOutlet UIView *avatarBaseView;
@property (retain, nonatomic) EXVerticalAlignLabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *selectedMaskView;
@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, assign) CGPoint avatarCenter;

@property (copy, nonatomic) TapBlock tapBlock;
@property (copy, nonatomic) LongPressBlock longPressBlock;

@property (nonatomic, retain) User *user;
@property (nonatomic, assign) NSUInteger index;

- (id)init;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated complete:(void (^)(void))handler;

@end

//
//  EXCircleItemCell.h
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EXVerticalAlignLabel.h"

typedef void (^TapBlock)(void);
typedef void (^LongPressBeginBlock)(void);
typedef void (^LongPressEndBlock)(void);

@class Card;

@interface EXCircleItemCell : UIView
<
UIGestureRecognizerDelegate
>

@property (retain, nonatomic) IBOutlet UIView *avatarBaseView;
@property (retain, nonatomic) EXVerticalAlignLabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *selectedMaskView;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *avatarImageViews;

@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, assign) CGPoint avatarCenter;

@property (copy, nonatomic) TapBlock tapBlock;
@property (copy, nonatomic) LongPressBeginBlock longPressBeginBlock;
@property (copy, nonatomic) LongPressEndBlock longPressEndBlock;

@property (nonatomic, copy) Card *card;
@property (nonatomic, copy) NSIndexPath *indexPath;

- (id)init;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated complete:(void (^)(void))handler;
- (void)setCard:(Card *)card animated:(BOOL)animated complete:(void (^)(void))handler;

@end

//
//  EXCircleItemCell.m
//  EXHereDemo
//
//  Created by 0day on 13-3-29.
//  Copyright (c) 2013年 EXFE. All rights reserved.
//

#import "EXCircleItemCell.h"

#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "Util.h"
#import "ImgCache.h"
#import "Card.h"

@interface EXCircleItemCell ()
@property (nonatomic, assign) BOOL isUsingDefaultAvatar;
@property (nonatomic, assign) UIImageView *currentVisibleAvatarImageView;
- (void)tapHandler:(UITapGestureRecognizer *)recognizer;
- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer;

- (void)_setAvatarImage:(UIImage *)image animated:(BOOL)animated;
@end

@implementation EXCircleItemCell {
    CGFloat _centerDistanceY;
}

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXLiveViewCell"
                                           owner:nil
                                         options:nil] lastObject] retain];
    
    // avatar
    for (UIImageView *imageView in self.avatarImageViews) {
        imageView.layer.cornerRadius = 30;
        imageView.clipsToBounds = YES;
    }
    
    // center
    _centerDistanceY = self.center.y - self.avatarBaseView.center.y;
    
    // label
    EXVerticalAlignLabel *label = [[EXVerticalAlignLabel alloc] initWithFrame:(CGRect){{0, 68}, {75, 35}}];
    label.textColor = [UIColor whiteColor];//[UIColor COLOR_WA(0x33, 0xFF)];
    label.numberOfLines = 2;
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    label.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];//[UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0f, 1.0f);
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.verticalAlignment = kEXLabelVerticalAlignmentTop;
    [self addSubview:label];
    self.titleLabel = label;
    [label release];
    
    // tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    [self.avatarBaseView addGestureRecognizer:tap];
    [tap release];
    
    // long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(longPressHandler:)];
    longPress.minimumPressDuration = 0.233f;
    longPress.delegate = self;
    [self.avatarBaseView addGestureRecognizer:longPress];
    [longPress release];
    
    self.isUsingDefaultAvatar = YES;
    self.currentVisibleAvatarImageView = self.avatarImageViews[0];
    
    return self;
}

- (void)dealloc {
    [_avatarImageViews release];
    [_indexPath release];
    [_card release];
    [_avatarBaseView release];
    [_titleLabel release];
    [_selectedMaskView release];
    [super dealloc];
}

#pragma mark - Getter && Setter
- (CGPoint)avatarCenter {
    return self.avatarBaseView.center;
}

- (void)setAvatarCenter:(CGPoint)avatarCenter {
    self.center = (CGPoint){avatarCenter.x, avatarCenter.y + _centerDistanceY};
}

- (void)setCard:(Card *)card {
    [self setCard:card animated:YES complete:nil];
}

- (void)setCard:(Card *)card animated:(BOOL)animated complete:(void (^)(void))handler {
    if (card == _card)
        return;
    
    if (_card && card && [_card isEqualToCard:card]) {
        NSString *perCardAvatarURL = _card.avatarURLString;
        [_card release];
        _card = [card copy];
        
        self.titleLabel.text = card.userName;
        [self.titleLabel sizeToFit];
        
        if (![card.avatarURLString isEqualToString:perCardAvatarURL]) {
            dispatch_queue_t image_queue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(image_queue, ^{
                UIImage *avatarImage=[[ImgCache sharedManager] getImgFrom:card.avatarURLString];
                if(avatarImage != nil && ![avatarImage isEqual:[NSNull null]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([card isEqualToCard:self.card]) {
                            [self _setAvatarImage:avatarImage animated:animated];
                        }
                    });
                }
            });
            dispatch_release(image_queue);
        }
    } else {
        if (_card) {
            self.titleLabel.text = @"";
            [self _setAvatarImage:nil animated:animated];
            [_card release];
            _card = nil;
        }
        
        if (card) {
            _card = [card copy];
            
            self.titleLabel.text = card.userName;
            [self.titleLabel sizeToFit];
            
            dispatch_queue_t image_queue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(image_queue, ^{
                UIImage *avatarImage=[[ImgCache sharedManager] getImgFrom:card.avatarURLString];
                if(avatarImage != nil && ![avatarImage isEqual:[NSNull null]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([card isEqualToCard:self.card]) {
                            [self _setAvatarImage:avatarImage animated:animated];
                        }
                    });
                }
            });
            dispatch_release(image_queue);
        }
    }
}

- (void)setSelected:(BOOL)selected {
    [self setSelected:selected animated:NO complete:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated complete:(void (^)(void))handler {
    if (selected == _selected)
        return;
    _selected = selected;
    
    [UIView setAnimationsEnabled:animated];
    
    [UIView animateWithDuration:0.25f
                     animations:^{
                         self.selectedMaskView.alpha = selected ? 1.0f : 0.0f;
                     }
                     completion:^(BOOL finished){
                         [UIView setAnimationsEnabled:YES];
                         
                         if (handler)
                             handler();
                     }];
}

#pragma mark - Gesture

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    if (_tapBlock)
        _tapBlock();
}

- (void)longPressHandler:(UILongPressGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = recognizer.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            if (_longPressBeginBlock)
                _longPressBeginBlock();
            break;
        case UIGestureRecognizerStateEnded:
            if (_longPressEndBlock)
                _longPressEndBlock();
            break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)_setAvatarImage:(UIImage *)image animated:(BOOL)animated {
    if (nil == image && self.isUsingDefaultAvatar)
        return;
    if (nil == image) {
        self.isUsingDefaultAvatar = YES;
        image = [UIImage imageNamed:@"portrait_64.png"];
    } else {
        self.isUsingDefaultAvatar = NO;
    }
    
    self.currentVisibleAvatarImageView.image = image;
    
//    UIImageView *otherImageView = nil;
//    if (self.currentVisibleAvatarImageView == self.avatarImageViews[0]) {
//        otherImageView = self.avatarImageViews[1];
//    } else {
//        otherImageView = self.avatarImageViews[0];
//    }
//    
//    otherImageView.alpha = 0.0f;
//    otherImageView.image = image;
//    
//    [UIView setAnimationsEnabled:animated];
//    [UIView animateWithDuration:0.5f
//                     animations:^{
//                         otherImageView.alpha = 1.0f;
//                         self.currentVisibleAvatarImageView.alpha = 0.0f;
//                     }
//                     completion:^(BOOL finished){
//                         [UIView setAnimationsEnabled:YES];
////                         self.currentVisibleAvatarImageView.image = nil;
//                         self.currentVisibleAvatarImageView = otherImageView;
//                     }];
}

@end

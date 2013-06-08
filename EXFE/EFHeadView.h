//
//  EFHeadView.h
//  EFHeadAnimation
//
//  Created by 0day on 13-5-17.
//  Copyright (c) 2013年 0d0f. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^HeadViewHeadPressedBlock)(void);
typedef void (^HeadViewTitlePressedBlock)(void);
typedef void (^HeadViewWillShowBlock)(void);
typedef void (^HeadViewDidShowBlock)(void);

@interface EFHeadView : UIView

@property (nonatomic, retain) UIImage *headImage;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, assign, getter = isShowed) BOOL showed;

// action handler
@property (nonatomic, copy) HeadViewHeadPressedBlock headPressedHandler;
@property (nonatomic, copy) HeadViewTitlePressedBlock titlePressedHandler;

// completion handler
@property (nonatomic, copy) HeadViewWillShowBlock willShowHandler;
@property (nonatomic, copy) HeadViewDidShowBlock didShowHandler;

- (void)showAnimated:(BOOL)animated;

@end

//
//  EFCalloutAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-15.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFCalloutAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFCalloutAnnotation.h"
#import "Util.h"

#define kTitleHeight    (25.0f)
#define kTitleFont      [UIFont fontWithName:@"HelveticaNeue-Light" size:21]
#define kSubtileHeight  (20.0f)
#define kSubtileFont    [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
#define kDefaultWidth   (200.0f)
#define kCornerRadius   (3.0f)

@interface EFCalloutAnnotationView ()

@property (nonatomic, strong) UITextField   *titleTextField;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UITextView    *subtitleTextView;
@property (nonatomic, strong) UILabel       *subtitleLabel;
@property (nonatomic, strong) UIView        *lineView;

@property (nonatomic, strong) UIButton  *closeButton;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, assign) CGRect    originalFrame;
@property (nonatomic, weak)   UIView    *originalSuperView;
@property (nonatomic, strong) UIView    *editingBaseView;
@property (nonatomic, strong) UIView    *editingMaskView;

@end

#pragma mark -

@interface EFCalloutAnnotationView (Private)

- (void)_prepareLabels;
- (void)_prepareFrame;
- (void)_prepareOffset;

- (void)_show;

- (void)_handleTitleTap:(UITapGestureRecognizer *)tap;
- (void)_handleSubtitleTap:(UITapGestureRecognizer *)tap;

@end

@implementation EFCalloutAnnotationView (Private)

- (void)_prepareLabels {
    if (self.titleTextField) {
        [self.titleTextField removeFromSuperview];
        self.titleTextField = nil;
    }
    if (self.subtitleTextView) {
        [self.subtitleTextView removeFromSuperview];
        self.subtitleTextView = nil;
    }
    if (self.titleLabel) {
        [self.titleLabel removeFromSuperview];
        self.titleLabel = nil;
    }
    if (self.subtitleLabel) {
        [self.subtitleLabel removeFromSuperview];
        self.subtitleLabel = nil;
    }
    
    UITextField *titleTextField = [[UITextField alloc] initWithFrame:(CGRect){{5.0f, 2.0f}, {kDefaultWidth - 10.0f, kTitleHeight}}];
    titleTextField.delegate = self;
    titleTextField.returnKeyType = UIReturnKeyNext;
    titleTextField.hidden = YES;
    titleTextField.borderStyle = UITextBorderStyleNone;
    titleTextField.font = kTitleFont;
    titleTextField.backgroundColor = [UIColor clearColor];
    titleTextField.text = self.annotation.title;
    self.titleTextField = titleTextField;
    [self addSubview:self.titleTextField];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:(CGRect){{5.0f, 2.0f}, {kDefaultWidth - 10.0f, kTitleHeight}}];
    titleLabel.font = kTitleFont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = self.annotation.title;
    titleLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    titleLabel.shadowOffset = (CGSize){0.0f, 1.0f};
    titleLabel.userInteractionEnabled = YES;
    self.titleLabel = titleLabel;
    [self addSubview:self.titleLabel];
    
    UITapGestureRecognizer *titleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTitleTap:)];
    titleTap.numberOfTapsRequired = 1;
    [titleLabel addGestureRecognizer:titleTap];
    
    UITextView *subtitleTextView = [[UITextView alloc] initWithFrame:(CGRect){{0.0f, kTitleHeight + 10.0f}, {kDefaultWidth, kSubtileHeight}}];
    subtitleTextView.delegate = self;
    subtitleTextView.returnKeyType = UIReturnKeyDone;
    subtitleTextView.hidden = YES;
    subtitleTextView.font = kSubtileFont;
    subtitleTextView.backgroundColor = [UIColor clearColor];
    subtitleTextView.text = self.annotation.subtitle;
    [self addSubview:subtitleTextView];
    self.subtitleTextView = subtitleTextView;
    
    UILabel *subtileLabel = [[UILabel alloc] initWithFrame:(CGRect){{5.0f, kTitleHeight}, {kDefaultWidth - 10.0f, kSubtileHeight}}];
    subtileLabel.font = kSubtileFont;
    subtileLabel.backgroundColor = [UIColor clearColor];
    subtileLabel.shadowColor = [UIColor colorWithWhite:1.0f alpha:0.75f];
    subtileLabel.shadowOffset = (CGSize){0.0f, 1.0f};
    subtileLabel.text = self.annotation.subtitle;
    subtileLabel.userInteractionEnabled = YES;
    subtileLabel.numberOfLines = 2;
    self.subtitleLabel = subtileLabel;
    [self addSubview:self.subtitleLabel];
    
    UITapGestureRecognizer *subtitleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSubtitleTap:)];
    subtitleTap.numberOfTapsRequired = 1;
    [subtileLabel addGestureRecognizer:subtitleTap];
}

- (void)_prepareFrame {
    CGFloat height = 0.0f;
    
    if (self.annotation.title) {
        height += kTitleHeight + 4.0f;
    }
    if (self.annotation.subtitle) {
        height += kSubtileHeight;
    }
    
    CGRect frame = self.frame;
    frame.size = (CGSize){kDefaultWidth, height};
    self.frame = frame;
}

- (void)_prepareOffset {
    CGFloat offsetY = -(CGRectGetHeight(self.parentAnnotationView.frame) + CGRectGetHeight(self.frame) * 0.25f) + self.parentAnnotationView.centerOffset.y;
    self.centerOffset = (CGPoint){0.0f, offsetY};
}

- (void)_show {
    self.layer.transform = CATransform3DMakeScale(0.0f, 0.0f, 1.0f);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0f, 0.0f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                         [NSValue valueWithCATransform3D:CATransform3DIdentity],];
    animation.keyTimes = @[@(0.0), @(0.5), @(0.9), @(1.0)];
    animation.duration = 0.333f;
    animation.fillMode = kCAFillModeForwards;
    [self.layer addAnimation:animation forKey:nil];
    self.layer.transform = CATransform3DIdentity;
}

- (void)_handleTitleTap:(UITapGestureRecognizer *)tap {
    UIGestureRecognizerState state = tap.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if (self.titlePressedHandler) {
            self.titlePressedHandler();
        }
    }
}

- (void)_handleSubtitleTap:(UITapGestureRecognizer *)tap {
    UIGestureRecognizerState state = tap.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if (self.subtitlePressedHandler) {
            self.subtitlePressedHandler();
        }
    }
}

@end

#pragma mark -

@implementation EFCalloutAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.enabled = NO;
        self.backgroundColor = [UIColor whiteColor];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(id)[UIColor colorWithRed:(250.0f / 255.0f) green:(250.0f / 255.0f) blue:(250.0f / 255.0f) alpha:1.0f].CGColor,
                                 (id)[UIColor colorWithRed:(235.0f / 255.0f) green:(235.0f / 255.0f) blue:(235.0f / 255.0f) alpha:1.0f].CGColor];
        gradientLayer.frame = self.layer.bounds;
        gradientLayer.cornerRadius = 6.0f;
        [self.layer addSublayer:gradientLayer];
        self.gradientLayer = gradientLayer;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = (CGRect){CGPointZero, {44.0f, 44.0f}};
        [closeButton setImage:[UIImage imageNamed:@"map_remove_15"] forState:UIControlStateNormal];
        closeButton.center = (CGPoint){190, 10};
        [closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        closeButton.hidden = YES;
//        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        self.layer.cornerRadius = 6.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = (CGSize){0.0f, 1.0f};
        self.layer.shadowOpacity = 0.66f;
        self.layer.shadowRadius = 2.0f;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5f;
        
        self.lineView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 33.0f}, {kDefaultWidth, 0.5f}}];
        self.lineView.backgroundColor = [UIColor COLOR_RGB(0xCC, 0xCC, 0xCC)];
        self.lineView.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.lineView.layer.shadowOffset = (CGSize){0.0f, 0.5f};
        self.lineView.layer.shadowRadius = 0.5f;
        self.lineView.layer.shadowOpacity = 1.0f;
        self.lineView.hidden = YES;
        [self addSubview:self.lineView];
    }
    
    return self;
}

//- (void)layoutSubviews {
//    self.gradientLayer.frame = self.bounds;
//}

- (void)didMoveToSuperview {
    [self.superview bringSubviewToFront:self];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self _prepareFrame];
    [self _prepareLabels];
    [self _prepareOffset];
    
    self.editing = NO;
}

- (void)reloadAnnotation:(EFCalloutAnnotation *)annotation {
    self.annotation = (id<MKAnnotation>)annotation;
}

- (void)setEditing:(BOOL)editing {
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (_editing == editing)
        return;
    
    [self willChangeValueForKey:@"editing"];
    
    _editing = editing;
    
    [self didChangeValueForKey:@"editing"];
    
    if (!editing) {
        self.titleTextField.hidden = YES;
        self.subtitleTextView.hidden = YES;
        self.titleLabel.hidden = NO;
        self.subtitleLabel.hidden = NO;
        self.closeButton.hidden = YES;
        self.lineView.hidden = YES;
        
        ((EFCalloutAnnotation *)self.annotation).title = self.titleTextField.text;
        ((EFCalloutAnnotation *)self.annotation).subtitle = self.subtitleTextView.text;
        
        CGRect frame = [self.originalSuperView convertRect:self.frame fromView:self.editingBaseView];
        [self removeFromSuperview];
        self.frame = frame;
        [self.originalSuperView addSubview:self];
        
        [UIView setAnimationsEnabled:animated];
        [UIView animateWithDuration:0.233f
                         animations:^{
                             [self _prepareFrame];
                             [self _prepareLabels];
                             [self _prepareOffset];
//                             self.frame = self.originalFrame;
                             self.editingMaskView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             [self.editingBaseView removeFromSuperview];
                             self.editingBaseView = nil;
                             self.editingMaskView = nil;
                             
                             if (_editingDidEndHandler) {
                                 __weak typeof(self) weakSelf = self;
                                 self.editingDidEndHandler(weakSelf);
                             }
                             
                             [UIView setAnimationsEnabled:YES];
                         }];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration = 0.233f;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [self.gradientLayer valueForKey:@"position"];
        positionAnimation.toValue = [NSValue valueWithCGPoint:(CGPoint){self.originalFrame.size.width * 0.5f, self.originalFrame.size.height * 0.5f}];
        positionAnimation.fillMode = kCAFillModeForwards;
        [self.gradientLayer addAnimation:positionAnimation forKey:@"position"];
        self.gradientLayer.position = (CGPoint){self.originalFrame.size.width * 0.5f, self.originalFrame.size.height * 0.5f};
        
        CGRect bounds = (CGRect){{0.0f, 0.0f}, self.originalFrame.size};
        
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.duration = 0.233f;
        boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        boundsAnimation.fromValue = [self.gradientLayer valueForKey:@"bounds"];
        boundsAnimation.toValue = [NSValue valueWithCGRect:bounds];
        boundsAnimation.fillMode = kCAFillModeForwards;
        [self.gradientLayer addAnimation:boundsAnimation forKey:@"bounds"];
        self.gradientLayer.bounds = bounds;
    } else {
        if (_editingWillStartHandler) {
            __weak typeof(self) weakSelf = self;
            self.editingWillStartHandler(weakSelf);
        }
        
        self.titleTextField.hidden = NO;
        self.subtitleTextView.hidden = NO;
        self.titleLabel.hidden = YES;
        self.subtitleLabel.hidden = YES;
        self.closeButton.hidden = NO;
        self.lineView.hidden = NO;
        
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        UIView *editingBaseView = [[UIView alloc] initWithFrame:rootView.bounds];
        editingBaseView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingBaseViewTap:)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        [editingBaseView addGestureRecognizer:tap];
        [rootView addSubview:editingBaseView];
        self.editingBaseView = editingBaseView;
        
        UIView *maskView = [[UIView alloc] initWithFrame:rootView.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        maskView.alpha = 0.0f;
        [editingBaseView addSubview:maskView];
        self.editingMaskView = maskView;
        
        self.originalSuperView = self.superview;
        self.originalFrame = self.frame;
        
        CGRect frame = [self.editingBaseView convertRect:self.frame fromView:self.superview];
        [self removeFromSuperview];
        self.frame = frame;
        [self.editingBaseView addSubview:self];
        
        frame.size = (CGSize){200.0f, 69.0f};
        
        if (!CGRectContainsRect(self.editingBaseView.bounds, frame)) {
            if (frame.origin.x < 0) {
                frame.origin.x = 5.0f;
            }
            if (frame.origin.y < 0) {
                frame.origin.y = 5.0f;
            }
            if (CGRectGetMaxX(frame) > CGRectGetWidth(self.editingBaseView.bounds)) {
                frame.origin.x = CGRectGetWidth(self.editingBaseView.bounds) - (CGRectGetWidth(frame) + 5.0f);
            }
            if (CGRectGetMaxY(frame) > CGRectGetHeight(self.editingBaseView.bounds)) {
                frame.origin.y = CGRectGetHeight(self.editingBaseView.bounds) - (CGRectGetHeight(frame) + 5.0f);
            }
        }
        
        [UIView setAnimationsEnabled:animated];
        [UIView animateWithDuration:0.233f
                         animations:^{
                             self.editingMaskView.alpha = 1.0f;
                             self.frame = frame;
                         }
                         completion:^(BOOL finished){
                             [UIView setAnimationsEnabled:YES];
                         }];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration = 0.233f;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [self.gradientLayer valueForKey:@"position"];
        positionAnimation.toValue = [NSValue valueWithCGPoint:(CGPoint){100, 34.5f}];
        positionAnimation.fillMode = kCAFillModeForwards;
        [self.gradientLayer addAnimation:positionAnimation forKey:@"position"];
        self.gradientLayer.position = (CGPoint){100, 34.5f};
        
        CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.duration = 0.233f;
        boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        boundsAnimation.fromValue = [self.gradientLayer valueForKey:@"bounds"];
        boundsAnimation.toValue = [NSValue valueWithCGRect:self.bounds];
        boundsAnimation.fillMode = kCAFillModeForwards;
        [self.gradientLayer addAnimation:boundsAnimation forKey:@"bounds"];
        self.gradientLayer.bounds = self.bounds;
        
        [self.titleTextField becomeFirstResponder];
    }
}

#pragma mark - Action Hanlder

- (void)closeButtonPressed:(id)sender {
    [self setEditing:NO animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.bounds, location)) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Gesture Handler

- (void)handleEditingBaseViewTap:(UITapGestureRecognizer *)tap {
    [self setEditing:NO animated:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.subtitleLabel.text = self.subtitleTextView.text;
    ((EFCalloutAnnotation *)self.annotation).subtitle = self.subtitleTextView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text hasSuffix:@"\n"]) {
        [self.subtitleTextView resignFirstResponder];
        [self setEditing:NO animated:YES];
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.titleLabel.text = self.titleTextField.text;
    ((EFCalloutAnnotation *)self.annotation).title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [textField resignFirstResponder];
        [self.subtitleTextView becomeFirstResponder];
    }
    
    return YES;
}

@end

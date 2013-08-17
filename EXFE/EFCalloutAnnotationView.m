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
#import "UITextView+NumberOfLines.h"

#define kTopInset       (2.0f)
#define kBottomInset    (0.0f)
#define kBlank          (2.0f)
#define kTitleHeight    (25.0f)
#define kTitleFont      [UIFont fontWithName:@"HelveticaNeue-Light" size:21]
#define kSubtileHeight  (20.0f)
#define kSubtileFont    [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
#define kDefaultWidth   (200.0f)
#define kCornerRadius   (3.0f)

@interface EFCalloutAnnotationGradientView : UIView

@end

@implementation EFCalloutAnnotationGradientView

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = NULL;
    NSArray *colors = @[(id)[UIColor colorWithRed:(250.0f / 255.0f) green:(250.0f / 255.0f) blue:(250.0f / 255.0f) alpha:1.0f].CGColor,
                        (id)[UIColor colorWithRed:(235.0f / 255.0f) green:(235.0f / 255.0f) blue:(235.0f / 255.0f) alpha:1.0f].CGColor];
    CGFloat gradientLocations[] = {0, 1};
    gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, gradientLocations);
    
    CGContextDrawLinearGradient(context, gradient, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, 0.0f}, (CGPoint){CGRectGetWidth(self.frame) * 0.5f, CGRectGetHeight(self.frame)}, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end

@interface EFCalloutAnnotationView ()

@property (nonatomic, strong) UITextField   *titleTextField;
@property (nonatomic, strong) UITextView    *subtitleTextView;
@property (nonatomic, strong) UIView        *lineView;

//@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) EFCalloutAnnotationGradientView *gradientView;

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
    
    UITextField *titleTextField = [[UITextField alloc] initWithFrame:(CGRect){{5.0f, kTopInset}, {kDefaultWidth - 10.0f, kTitleHeight}}];
    titleTextField.delegate = self;
    titleTextField.returnKeyType = UIReturnKeyNext;
    titleTextField.borderStyle = UITextBorderStyleNone;
    titleTextField.font = kTitleFont;
    titleTextField.backgroundColor = [UIColor clearColor];
    titleTextField.text = self.annotation.title;
    titleTextField.enabled = NO;
    self.titleTextField = titleTextField;
    [self addSubview:self.titleTextField];
    
    UITextView *subtitleTextView = [[UITextView alloc] initWithFrame:(CGRect){{5.0f, CGRectGetMaxY(titleTextField.frame) + kBlank}, {kDefaultWidth + 5.0f, kSubtileHeight}}];
    subtitleTextView.contentInset = (UIEdgeInsets){-7.0f, -8.0f, 0.0f, 0.0f};
    subtitleTextView.delegate = self;
    subtitleTextView.returnKeyType = UIReturnKeyDone;
    subtitleTextView.font = kSubtileFont;
    subtitleTextView.backgroundColor = [UIColor clearColor];
    subtitleTextView.text = self.annotation.subtitle;
    subtitleTextView.editable = NO;
    
    UITapGestureRecognizer *subtitleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSubtitleTap:)];
    [subtitleTextView addGestureRecognizer:subtitleTap];
    
    [self addSubview:subtitleTextView];
    self.subtitleTextView = subtitleTextView;
    
    // resize subtitle textview
    [subtitleTextView sizeToFit];
    
    CGRect subtitleTextViewFrame = subtitleTextView.frame;
    CGFloat subtitleTextViewHeight = CGRectGetHeight(subtitleTextViewFrame);
    
    if (subtitleTextViewHeight >= 2 * kSubtileHeight) {
        subtitleTextViewFrame.size.height = 2 * kSubtileHeight;
    } else if (subtitleTextViewHeight < kSubtileHeight) {
        subtitleTextViewFrame.size.height = kSubtileHeight;
    }
    
    subtitleTextView.frame = subtitleTextViewFrame;
}

- (void)_prepareFrame {
    CGFloat height = kTopInset + kBottomInset;
    
    if (self.annotation.title) {
        height += CGRectGetHeight(self.titleTextField.frame);
    }
    if (self.annotation.subtitle) {
        height += CGRectGetHeight(self.subtitleTextView.frame) + kBlank;
    }
    
    CGRect frame = self.frame;
    frame.size = (CGSize){kDefaultWidth, height};
    self.frame = frame;
}

- (void)_prepareOffset {
    CGFloat offsetY = -(CGRectGetHeight(self.parentAnnotationView.frame) + CGRectGetHeight(self.frame) * 0.25f) + self.parentAnnotationView.centerOffset.y;
    self.centerOffset = (CGPoint){0.0f, offsetY};
}

- (void)reset {
    [self _prepareLabels];
    [self _prepareFrame];
    [self _prepareOffset];
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
        
        EFCalloutAnnotationGradientView *gradientView = [[EFCalloutAnnotationGradientView alloc] initWithFrame:self.bounds];
        gradientView.layer.cornerRadius = 6.0f;
        gradientView.layer.masksToBounds = YES;
        gradientView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        [self insertSubview:gradientView atIndex:0];
        self.gradientView = gradientView;
        
        self.layer.cornerRadius = 6.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = (CGSize){0.0f, 1.0f};
        self.layer.shadowOpacity = 0.66f;
        self.layer.shadowRadius = 2.0f;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5f;
        
        self.lineView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, 28.0f}, {kDefaultWidth, 0.5f}}];
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

- (void)didMoveToSuperview {
    [self.superview bringSubviewToFront:self];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self reset];
    
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
        self.titleTextField.enabled = NO;
        self.subtitleTextView.editable = NO;
        self.lineView.hidden = YES;
        
        [self.subtitleTextView scrollsToTop];
        self.subtitleTextView.scrollEnabled = NO;
        
        ((EFCalloutAnnotation *)self.annotation).title = self.titleTextField.text;
        ((EFCalloutAnnotation *)self.annotation).subtitle = self.subtitleTextView.text;
        
        CGRect frame = [self.originalSuperView convertRect:self.frame fromView:self.editingBaseView];
        [self removeFromSuperview];
        self.frame = frame;
        [self.originalSuperView addSubview:self];
        
        [UIView setAnimationsEnabled:animated];
        [UIView animateWithDuration:0.233f
                         animations:^{
                             self.frame = self.originalFrame;
                             self.gradientView.frame = self.bounds;
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
    } else {
        if (_editingWillStartHandler) {
            __weak typeof(self) weakSelf = self;
            self.editingWillStartHandler(weakSelf);
        }
        
        self.titleTextField.enabled = YES;
        self.subtitleTextView.editable = YES;
        self.lineView.hidden = NO;
        
        self.subtitleTextView.scrollEnabled = YES;
        
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
        
        CGRect textViewFrame = self.subtitleTextView.frame;
        textViewFrame.size.height = 2 * kSubtileHeight;
        self.subtitleTextView.frame = textViewFrame;
        
        [self _prepareFrame];
        [self _prepareOffset];
        
        CGRect frame = [self.editingBaseView convertRect:self.frame fromView:self.superview];
        [self removeFromSuperview];
        self.frame = frame;
        [self.editingBaseView addSubview:self];
        
//        frame.size = (CGSize){200.0f, 69.0f};
        
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
                             self.gradientView.frame = self.bounds;
                         }
                         completion:^(BOOL finished){
                             [UIView setAnimationsEnabled:YES];
                         }];
        
        [self.titleTextField becomeFirstResponder];
    }
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

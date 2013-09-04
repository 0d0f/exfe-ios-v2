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
#import "EFAnnotation.h"
#import "EFAnnotationView.h"
#import "EFMarauderMapDataSource.h"


#define kTopInset       (2.0f)
#define kBottomInset    (0.0f)
#define kBlank          (2.0f)
#define kTitleHeight    (25.0f)
#define kTitleFont      [UIFont fontWithName:@"HelveticaNeue-Light" size:21]
#define kSubtileHeight  (20.0f)
#define kSubtileFont    [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
#define kDefaultWidth   (200.0f)
#define kCornerRadius   (3.0f)

#define kEdgeBlank      (5.0f)
#define kMapLeftEdget   (50.0f)

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

@property (nonatomic, strong) UIView        *tapView;

@property (nonatomic, strong) EFCalloutAnnotationGradientView *gradientView;

@property (nonatomic, assign) CGRect    originalFrame;
@property (nonatomic, weak)   UIView    *originalSuperView;
@property (nonatomic, strong) UIView    *editingBaseView;
@property (nonatomic, strong) UIView    *editingMaskView;

@property (nonatomic, strong) NSString  *cachedTitle;
@property (nonatomic, strong) NSString  *cachedSubtitle;

@end

#pragma mark -

@interface EFCalloutAnnotationView (Private)

- (CGRect)_calculateFrameEditing:(BOOL)editing;

- (void)_prepareLabels;
- (void)_prepareFrameEditing:(BOOL)editing;
- (void)_prepareOffset;

- (void)_show;

@end

@implementation EFCalloutAnnotationView (Private)

- (CGRect)_calculateFrameEditing:(BOOL)editing {
    CGFloat height = kTopInset + kBottomInset;
    
    if (self.annotation.title) {
        height += CGRectGetHeight(self.titleTextField.frame);
    }
    if ((self.annotation.subtitle && self.annotation.subtitle.length) || editing) {
        height += CGRectGetHeight(self.subtitleTextView.frame) + kBlank;
    } else {
        height += 2 * kBlank;
    }
    
    CGRect frame = self.frame;
    frame.size = (CGSize){kDefaultWidth, height};
    
    return frame;
}

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
    subtitleTextView.returnKeyType = UIReturnKeyDefault;
    subtitleTextView.font = kSubtileFont;
    subtitleTextView.backgroundColor = [UIColor clearColor];
    subtitleTextView.text = self.annotation.subtitle;
    subtitleTextView.showsHorizontalScrollIndicator = NO;
    subtitleTextView.showsVerticalScrollIndicator = NO;
    subtitleTextView.bounces = NO;
    subtitleTextView.editable = NO;
    
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

- (void)_prepareFrameEditing:(BOOL)editing {
    self.frame = [self _calculateFrameEditing:editing];
}

- (void)_prepareOffset {
    CLLocationCoordinate2D parentCoordinate = self.parentAnnotationView.annotation.coordinate;
    CGPoint parentLocation = [self.mapView convertCoordinate:parentCoordinate toPointToView:self.mapView];
    CGPoint center = parentLocation;
    
    CGFloat offsetX = 0.0f;
    CGFloat offsetY = -(CGRectGetHeight(self.parentAnnotationView.frame) + CGRectGetHeight(self.frame) * 0.5f) + 10.0f + self.parentAnnotationView.centerOffset.y;
    
    center.y += offsetY;
    CGRect viewFrame = self.frame;
    viewFrame.origin = (CGPoint){center.x - CGRectGetWidth(viewFrame) * 0.5f, center.y - CGRectGetHeight(viewFrame)};
    
    CGRect mapViewBounds = self.mapView.bounds;
    mapViewBounds.origin.x = kMapLeftEdget;
    mapViewBounds.size.width -= kMapLeftEdget;
    
    if (CGRectGetMinX(viewFrame) < kEdgeBlank + CGRectGetMinX(mapViewBounds)) {
        offsetX += kEdgeBlank + CGRectGetMinX(mapViewBounds) - CGRectGetMinX(viewFrame);
    }
    if (CGRectGetMinY(viewFrame) < kEdgeBlank) {
        offsetY += kEdgeBlank - CGRectGetMinY(viewFrame);
    }
    if (CGRectGetMaxX(viewFrame) > kEdgeBlank + CGRectGetMaxX(mapViewBounds)) {
        offsetX += CGRectGetMaxX(mapViewBounds) - (kEdgeBlank + CGRectGetMaxX(viewFrame));
    }
    if (CGRectGetMaxY(viewFrame) > kEdgeBlank + CGRectGetHeight(mapViewBounds)) {
        offsetY += CGRectGetHeight(mapViewBounds) - (kEdgeBlank + CGRectGetMaxY(viewFrame));
    }
    
    self.centerOffset = (CGPoint){offsetX, offsetY};
}

- (void)reset {
    [self _prepareLabels];
    [self _prepareFrameEditing:NO];
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
        
        UIView *tapView = [[UIView alloc] initWithFrame:self.bounds];
        tapView.backgroundColor = [UIColor clearColor];
        tapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:tapView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [tapView addGestureRecognizer:tap];
        
        self.tapView = tapView;
    }
    
    return self;
}

#pragma mark - Override

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.tapView];
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self.superview bringSubviewToFront:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleKeyboardWillShowNotification:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self reset];
    
    self.cachedTitle = annotation.title;
    self.cachedSubtitle = annotation.subtitle;
    
    self.editing = NO;
}

#pragma mark - Tap Handler

- (void)handleTap:(UITapGestureRecognizer *)tap {
    UIGestureRecognizerState state = tap.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if (_tapHandler) {
            self.tapHandler();
        }
    }
}

#pragma mark - Notification Handler

- (void)handleKeyboardWillShowNotification:(NSNotification *)notif {
    NSDictionary *userinfo = notif.userInfo;
    CGSize keyboradSize = [[userinfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.frame;
    CGRect visibleRect = self.editingBaseView.bounds;
    visibleRect.size.height -= keyboradSize.height;
    
    if (!CGRectContainsRect(visibleRect, frame)) {
        if (frame.origin.x < 0) {
            frame.origin.x = 5.0f;
        }
        if (frame.origin.y < 0) {
            frame.origin.y = 5.0f;
        }
        if (CGRectGetMaxX(frame) > CGRectGetWidth(visibleRect)) {
            frame.origin.x = CGRectGetWidth(visibleRect) - (CGRectGetWidth(frame) + 5.0f);
        }
        if (CGRectGetMaxY(frame) > CGRectGetHeight(visibleRect)) {
            frame.origin.y = CGRectGetHeight(visibleRect) - (CGRectGetHeight(frame) + 5.0f);
        }
    }
    
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.frame = frame;
                     }
                     completion:nil];
    
}

#pragma mark - Public

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
        self.tapView.userInteractionEnabled = YES;
        
        [self.subtitleTextView scrollsToTop];
        self.subtitleTextView.scrollEnabled = NO;
        
        // set text
        ((EFCalloutAnnotation *)self.annotation).title = self.titleTextField.text;
        ((EFCalloutAnnotation *)self.annotation).subtitle = self.subtitleTextView.text;
        
        // resize subtitle textview
        [self.subtitleTextView sizeToFit];
        
        CGRect subtitleTextViewFrame = self.subtitleTextView.frame;
        CGFloat subtitleTextViewHeight = CGRectGetHeight(subtitleTextViewFrame);
        
        if (subtitleTextViewHeight >= 2 * kSubtileHeight) {
            subtitleTextViewFrame.size.height = 2 * kSubtileHeight;
        } else if (subtitleTextViewHeight < kSubtileHeight) {
            subtitleTextViewFrame.size.height = kSubtileHeight;
        }
        self.subtitleTextView.frame = subtitleTextViewFrame;
        
        CGRect newFrame = [self _calculateFrameEditing:editing];
        
        if (CGRectGetHeight(newFrame) != CGRectGetHeight(self.originalFrame)) {
            CGFloat offsetY = CGRectGetHeight(self.originalFrame) - CGRectGetHeight(newFrame);
            newFrame.origin = (CGPoint){CGRectGetMinX(self.originalFrame), CGRectGetMinY(self.originalFrame) + offsetY};
        } else {
            newFrame = self.originalFrame;
        }
        
        CGRect frame = [self.originalSuperView convertRect:self.frame fromView:self.editingBaseView];
        [self removeFromSuperview];
        self.frame = frame;
        [self.originalSuperView addSubview:self];
        
        // animation
        [UIView setAnimationsEnabled:animated];
        [UIView animateWithDuration:0.233f
                         animations:^{
                             self.frame = newFrame;
                             self.gradientView.frame = self.bounds;
                             self.editingMaskView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished){
                             [self.editingBaseView removeFromSuperview];
                             self.editingBaseView = nil;
                             self.editingMaskView = nil;
                             
                             EFAnnotation *annotation = (EFAnnotation *)self.parentAnnotationView.annotation;
                             EFRouteLocation *routeLocation = [((EFAnnotationView *)self.parentAnnotationView).mapDataSource routeLocationForAnnotation:annotation];
                             
                             if ([self.annotation.title isEqualToString:self.cachedTitle] &&
                                 [self.annotation.subtitle isEqualToString:self.cachedSubtitle]) {
                                 routeLocation.isChanged = NO;
                             } else {
                                 routeLocation.isChanged = YES;
                             }
                             
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
        self.tapView.userInteractionEnabled = NO;
        
        self.subtitleTextView.scrollEnabled = YES;
        
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        
        // editing base view
        UIView *editingBaseView = [[UIView alloc] initWithFrame:rootView.bounds];
        editingBaseView.backgroundColor = [UIColor clearColor];
        
        // tap gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleEditingBaseViewTap:)];
        tap.delegate = self;
        tap.numberOfTapsRequired = 1;
        [editingBaseView addGestureRecognizer:tap];
        
        [rootView addSubview:editingBaseView];
        
        self.editingBaseView = editingBaseView;
        
        // mask view
        UIView *maskView = [[UIView alloc] initWithFrame:rootView.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.33f];
        maskView.alpha = 0.0f;
        
        [editingBaseView addSubview:maskView];
        self.editingMaskView = maskView;
        
        // cache original frame
        self.originalSuperView = self.superview;
        self.originalFrame = self.frame;
        
        // set 2 line height to text view
        CGRect textViewFrame = self.subtitleTextView.frame;
        textViewFrame.size.height = 2 * kSubtileHeight;
        self.subtitleTextView.frame = textViewFrame;
        
        // resize frame
        [self _prepareFrameEditing:editing];
        [self _prepareOffset];
        
        CGRect frame = [self.editingBaseView convertRect:self.frame fromView:self.superview];
        [self removeFromSuperview];
        self.frame = frame;
        [self.editingBaseView addSubview:self];
        
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
        
        // animation
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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    ((EFCalloutAnnotation *)self.annotation).title = self.titleTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [textField resignFirstResponder];
        [self.subtitleTextView becomeFirstResponder];
    }
    
    return NO;
}

@end

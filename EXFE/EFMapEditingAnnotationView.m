//
//  EFMapEditingAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapEditingAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFMapColorButton.h"
#import "EFRouteLocation.h"

#define kDefaultCharactor   @"P"

@interface EFLetterPickerView : UIView

@property (nonatomic, strong) UILabel *label;

@end

@implementation EFLetterPickerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 2.0f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:(51.0f / 255.0f) green:(51.0f / 255.0f) blue:(51.0f / 255.0f) alpha:0.8f];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {50.0f, CGRectGetHeight(frame)}}];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.center = (CGPoint){CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)};
        label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        self.label = label;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGRect viewBounds = self.bounds;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    [@"A" drawAtPoint:(CGPoint){10.0f, 5.0f} withFont:font];
    [@"Z" drawAtPoint:(CGPoint){CGRectGetWidth(viewBounds) - 20.0f, 5.0f} withFont:font];
    
    CGFloat lineWidth = 4.0f;
    
    // left dashed line
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGFloat lengths[] = {0.0f, lineWidth * 3};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:(204.0f / 255.0f) green:(204.0f / 255.0f) blue:(204.0f / 255.0f) alpha:1.0f].CGColor);
    CGContextMoveToPoint(context, 30.0f, CGRectGetMidY(viewBounds));
    CGContextAddLineToPoint(context, CGRectGetMidX(viewBounds) - 20.0f, CGRectGetMidY(viewBounds));
    CGContextStrokePath(context);
    
    // right dashed line
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:(204.0f / 255.0f) green:(204.0f / 255.0f) blue:(204.0f / 255.0f) alpha:1.0f].CGColor);
    CGContextMoveToPoint(context, CGRectGetWidth(viewBounds) - 30.0f, CGRectGetMidY(viewBounds));
    CGContextAddLineToPoint(context, CGRectGetMidX(viewBounds) + 20.0f, CGRectGetMidY(viewBounds));
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

@end

@interface EFMapEditingAnnotationView ()

@property (nonatomic, strong) EFLetterPickerView *letterPickerView;
@property (nonatomic, strong) EFMapColorButton  *blueButton;
@property (nonatomic, strong) EFMapColorButton  *redButton;
@property (nonatomic, strong) UIView            *panView;
@property (nonatomic, strong) UILabel           *label;

@property (nonatomic, strong) NSMutableArray    *charactorArray;
@property (nonatomic, assign) NSInteger         selectedIndex;

@end

@implementation EFMapEditingAnnotationView

- (void)_init {
    self.charactorArray = [[NSMutableArray alloc] init];
    [self.charactorArray addObject:@" "];
    for (int i = 0; i < 26; i++) {
        NSString *string = [NSString stringWithFormat:@"%c", 'A' + i];
        [self.charactorArray addObject:string];
    }
    
    NSString *otherCharactors = @"$@#%&?";
    
    for (NSUInteger i = 0; i < otherCharactors.length; i++) {
        unichar ch = [otherCharactors characterAtIndex:i];
        NSString *string = [NSString stringWithFormat:@"%c", ch];
        [self.charactorArray addObject:string];
    }
    
    self.selectedIndex = [self.charactorArray indexOfObject:kDefaultCharactor];
    
    CGRect viewBounds = self.bounds;
    CGRect panViewFrame = (CGRect){CGPointZero, {30.0f, 30.0f}};
    
    UIView *panView = [[UIView alloc] initWithFrame:panViewFrame];
    panView.center = (CGPoint){CGRectGetMidX(viewBounds), CGRectGetMidY(viewBounds)};
    panView.backgroundColor = [UIColor colorWithRed:(51.0f / 255.0f) green:(51.0f / 255.0f) blue:(51.0f / 255.0f) alpha:0.8f];
    panView.layer.cornerRadius = 2.0f;
    [self addSubview:panView];
    self.panView = panView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:panView.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = kDefaultCharactor;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    label.textColor = [UIColor whiteColor];
    label.userInteractionEnabled = YES;
    [panView addSubview:label];
    self.label = label;
    
    // gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.label addGestureRecognizer:singleTap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handlePan:)];
    [self.label addGestureRecognizer:pan];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPressed:)];
    [self.label addGestureRecognizer:longPress];
    
    self.markLetter = kDefaultCharactor;
    
    CGRect buttonFrame = (CGRect){CGPointZero, {CGRectGetMidX(viewBounds) - 20.0f, CGRectGetHeight(viewBounds)}};
    EFMapColorButton *blueButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:0.0f green:(123.0f / 255.0f) blue:1.0f alpha:1.0f]];
    [blueButton addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    blueButton.frame = buttonFrame;
    [self addSubview:blueButton];
    self.blueButton = blueButton;
    
    buttonFrame.origin = (CGPoint){CGRectGetWidth(viewBounds) - CGRectGetWidth(buttonFrame), 0.0f};
    EFMapColorButton *redButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:(51.0f / 255.0f) alpha:1.0f]];
    [redButton addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    redButton.frame = buttonFrame;
    [self addSubview:redButton];
    self.redButton = redButton;
}

- (void)_selectButton:(EFMapColorButton *)button {
    if (button == self.redButton) {
        self.redButton.selected = YES;
        self.blueButton.selected = NO;
    } else if (button == self.blueButton) {
        self.redButton.selected = NO;
        self.blueButton.selected = YES;
    }
}

- (void)_showLetterPickerView {
    if (!self.letterPickerView) {
        CGRect viewBounds = self.bounds;
        viewBounds.origin.y -= (CGRectGetHeight(viewBounds) + 12.0f);
        self.letterPickerView = [[EFLetterPickerView alloc] initWithFrame:viewBounds];
        self.letterPickerView.hidden = YES;
        [self addSubview:self.letterPickerView];
    }
    self.letterPickerView.hidden = NO;
}

- (void)_hideLetterPickerView {
    if ([self.delegate respondsToSelector:@selector(mapEditingAnnotationView:didChangeToTitle:)]) {
        [self.delegate mapEditingAnnotationView:self didChangeToTitle:self.markLetter];
    }
    self.letterPickerView.hidden = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

#pragma mark - Public

- (void)customWithRouteLocation:(EFRouteLocation *)routeLocation {
    if (routeLocation.locatinMask & kEFRouteLocationMaskXPlace || routeLocation.locatinMask & kEFRouteLocationMaskDestination) {
        self.redButton.selected = NO;
        self.blueButton.selected = NO;
        self.markLetter = @" ";
    } else {
        self.markLetter = routeLocation.markTitle;
        if (kEFRouteLocationColorRed == routeLocation.markColor) {
            [self _selectButton:self.redButton];
        } else {
            [self _selectButton:self.blueButton];
        }
    }
}

#pragma mark - Gesture

- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    self.selectedIndex = (self.selectedIndex + 1) % self.charactorArray.count;
    self.markLetter = [self.charactorArray objectAtIndex:self.selectedIndex];
    
    if ([self.delegate respondsToSelector:@selector(mapEditingAnnotationView:didChangeToTitle:)]) {
        [self.delegate mapEditingAnnotationView:self didChangeToTitle:self.markLetter];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    static NSInteger s_count = 0;
    static CGPoint preTranslation = (CGPoint){0.0f, 0.0f};
    CGPoint translation = [pan translationInView:self.label];
    NSInteger count = (NSInteger)(translation.x - preTranslation.x) / 5.0f;
    
    if (s_count != count && count) {
        s_count = count;
        preTranslation = translation;
        self.selectedIndex += (count > 0) ? 1 : -1;
        if (self.selectedIndex < 0) {
            self.selectedIndex = 0;
        } else if (self.selectedIndex >= self.charactorArray.count) {
            self.selectedIndex = self.charactorArray.count - 1;
        }
        
        self.markLetter = [self.charactorArray objectAtIndex:self.selectedIndex];
    }
    
    UIGestureRecognizerState state = pan.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            [self _showLetterPickerView];
            break;
        case UIGestureRecognizerStateChanged:
            if ([self.delegate respondsToSelector:@selector(mapEditingAnnotationView:isChangingToTitle:)]) {
                [self.delegate mapEditingAnnotationView:self isChangingToTitle:self.markLetter];
            }
            break;
        case UIGestureRecognizerStateEnded:
            [self _hideLetterPickerView];
            break;
        default:
            break;
    }
}

- (void)handleLongPressed:(UILongPressGestureRecognizer *)gesture {
}

#pragma mark - Property Accessor

- (void)setMarkLetter:(NSString *)markLetter {
    _markLetter = markLetter;
    
    self.label.text = markLetter;
    if (self.letterPickerView) {
        self.letterPickerView.label.text = markLetter;
    }
}

#pragma mark - Action Handler

- (void)colorButtonPressed:(EFMapColorButton *)button {
    [self _selectButton:button];
    
    if ([self.delegate respondsToSelector:@selector(mapEditingAnnotationView:didChangeToStyle:)]) {
        if (button == self.blueButton) {
            [self.delegate mapEditingAnnotationView:self didChangeToStyle:kEFAnnotationStyleMarkBlue];
        } else if (button == self.redButton) {
            [self.delegate mapEditingAnnotationView:self didChangeToStyle:kEFAnnotationStyleMarkRed];
        }
    }
}

@end

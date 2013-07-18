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

@end

@implementation EFMapEditingAnnotationView

- (void)_init {
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
    label.text = @"P";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    label.textColor = [UIColor whiteColor];
    [panView addSubview:label];
    self.label = label;
    
    self.markLetter = @"P";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = panView.frame;
    [button addTarget:self action:@selector(touchDown:withEvent:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchDrag:withEvent:) forControlEvents:UIControlEventTouchDragInside | UIControlEventTouchDragOutside];
    [button addTarget:self action:@selector(touchUp:withEvent:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self addSubview:button];
    
    CGRect buttonFrame = (CGRect){CGPointZero, {CGRectGetMidX(viewBounds) - 20.0f, CGRectGetHeight(viewBounds)}};
    EFMapColorButton *blueButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:0.0f green:(123.0f / 255.0f) blue:1.0f alpha:1.0f]];
    blueButton.frame = buttonFrame;
    [self addSubview:blueButton];
    self.blueButton = blueButton;
    
    buttonFrame.origin = (CGPoint){CGRectGetWidth(viewBounds) - CGRectGetWidth(buttonFrame), 0.0f};
    EFMapColorButton *redButton = [EFMapColorButton buttonWithColor:[UIColor colorWithRed:1.0f green:0.0f blue:(51.0f / 255.0f) alpha:1.0f]];
    redButton.frame = buttonFrame;
    [self addSubview:redButton];
    self.redButton = redButton;
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

#pragma mark - Property Accessor

- (void)setMarkLetter:(NSString *)markLetter {
    _markLetter = markLetter;
    
    self.label.text = markLetter;
    if (self.letterPickerView) {
        self.letterPickerView.label.text = markLetter;
    }
}

#pragma mark - Event Handler

static CGPoint startPoint;
static char startChar;

- (void)touchDown:(id)sender withEvent:(UIEvent *)event {
    if (!self.letterPickerView) {
        CGRect viewBounds = self.bounds;
        viewBounds.origin.y -= (CGRectGetHeight(viewBounds) + 12.0f);
        self.letterPickerView = [[EFLetterPickerView alloc] initWithFrame:viewBounds];
        self.letterPickerView.hidden = YES;
        [self addSubview:self.letterPickerView];
    }
    
    startPoint = [[[event allTouches] anyObject] locationInView:self];
    startChar = [self.markLetter cStringUsingEncoding:NSUTF8StringEncoding][0];
    
    self.letterPickerView.label.text = self.markLetter;
    self.letterPickerView.hidden = NO;
}

- (void)touchDrag:(id)sender withEvent:(UIEvent *)event {
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    CGFloat offsetX = location.x - startPoint.x;
    CGRect viewBounds = self.bounds;
    CGFloat width = CGRectGetWidth(viewBounds);
    
    CGFloat factor = (offsetX / width) * 26;
    char c = (int)factor + startChar;
    
    if (c < 'A') {
        self.markLetter = @"A";
    } else if (c > 'Z') {
        self.markLetter = @"Z";
    } else {
        self.markLetter = [NSString stringWithFormat:@"%c", c];
    }
}

- (void)touchUp:(id)sender withEvent:(UIEvent *)event {
    self.letterPickerView.hidden = YES;
}

@end

//
//  EFAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFAnnotationView.h"
#import "EFAnnotation.h"

@interface EFAnnotationView ()

@property (nonatomic, strong) UILabel *markTitleLabel;

@end

@implementation EFAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *markTitleLabel = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, {CGRectGetWidth(self.frame), CGRectGetWidth(self.frame)}}];
        markTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        markTitleLabel.backgroundColor = [UIColor clearColor];
        markTitleLabel.textColor = [UIColor whiteColor];
        markTitleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        markTitleLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        self.markTitleLabel = markTitleLabel;
        [self addSubview:markTitleLabel];
        
        [self reloadWithAnnotation:annotation];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

#pragma mark - Gesture Handler

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    UIGestureRecognizerState state = gesture.state;
    
    if (UIGestureRecognizerStateEnded == state) {
        if (self.selected) {
            [self.mapView deselectAnnotation:self.annotation animated:YES];
        } else {
            [self.mapView selectAnnotation:self.annotation animated:YES];
        }
    }
}

#pragma mark - Public

- (void)reloadWithAnnotation:(EFAnnotation *)annotatoin
{
    NSParameterAssert(annotatoin);
    NSParameterAssert([annotatoin isKindOfClass:[EFAnnotation class]]);
    
    self.image = annotatoin.markImage;
    
    if (kEFAnnotationStyleDestination == annotatoin.style) {
        self.markTitleLabel.hidden = YES;
    } else {
        self.markTitleLabel.hidden = NO;
        self.markTitleLabel.text = annotatoin.markTitle;
    }
}

@end

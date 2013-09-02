//
//  EFAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFAnnotation.h"
#import "EFMarauderMapDataSource.h"

#define kUnpinOffset    (50.0f)

@interface EFAnnotationView ()

@property (nonatomic, strong) UILabel *markTitleLabel;

@end

@implementation EFAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.userInteractionEnabled = NO;
        self.draggable = YES;
        
        UILabel *markTitleLabel = [[UILabel alloc] initWithFrame:(CGRect){{3.0f, 0.0f}, {18, 26}}];
        markTitleLabel.textAlignment = NSTextAlignmentCenter;
        markTitleLabel.font = [UIFont fontWithName:@"Raleway" size:20];
        markTitleLabel.backgroundColor = [UIColor clearColor];
        markTitleLabel.textColor = [UIColor whiteColor];
        markTitleLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        markTitleLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        markTitleLabel.adjustsFontSizeToFitWidth = YES;
        self.markTitleLabel = markTitleLabel;
        [self addSubview:markTitleLabel];
        
        [self reloadWithAnnotation:annotation];
        
        self.centerOffset = (CGPoint){0.0f, -17.0f};
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)setDragState:(MKAnnotationViewDragState)dragState animated:(BOOL)animated {
    switch (dragState) {
        case MKAnnotationViewDragStateStarting:
        {
            CGPoint center = (CGPoint){self.center.x, self.center.y - kUnpinOffset - 10.0f};
            [UIView animateWithDuration:0.133f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.center = center;
                             }
                             completion:^(BOOL finished){
                                 CGPoint nextCenter = (CGPoint){self.center.x, self.center.y + 10.0f};
                                 [UIView animateWithDuration:0.1f
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      self.center = nextCenter;
                                                  }
                                                  completion:^(BOOL finished){
                                                      [super setDragState:dragState animated:animated];
                                                  }];
                             }];
        }
            break;
        case MKAnnotationViewDragStateEnding:
        case MKAnnotationViewDragStateCanceling:
        {
            CGPoint center = (CGPoint){self.center.x, self.center.y - kUnpinOffset};
            [UIView animateWithDuration:0.133f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.center = center;
                             }
                             completion:^(BOOL finished){
                                 CGPoint nextCenter = (CGPoint){self.center.x, self.center.y + kUnpinOffset};
                                 [UIView animateWithDuration:0.1f
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      self.center = nextCenter;
                                                  }
                                                  completion:^(BOOL finished){
                                                      [super setDragState:dragState animated:animated];
                                                  }];
                             }];
        }
            break;
        case MKAnnotationViewDragStateDragging:
            [super setDragState:dragState animated:animated];
            break;
        default:
            break;
    }
}

#pragma mark - Gesture Handler

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(annotationView:didTapAtCoordinate:)]) {
        [self.delegate annotationView:self didTapAtCoordinate:self.annotation.coordinate];
    }
    
    return;
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
    
    if (kEFAnnotationStyleDestination == annotatoin.style ||
        kEFAnnotationStyleXPlace == annotatoin.style) {
        self.markTitleLabel.hidden = YES;
    } else {
        self.markTitleLabel.hidden = NO;
        self.markTitleLabel.text = annotatoin.markTitle;
    }
}

@end

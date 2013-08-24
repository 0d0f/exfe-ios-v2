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

#define kUnpinOffset    (CGPoint){0.0f, -20.0f}

@interface EFAnnotationView ()

@property (nonatomic, strong) UILabel *markTitleLabel;

@end

@implementation EFAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = NO;
        
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    static CGPoint startPoint;
    static CGPoint lastPoint;
    
    CGPoint location = [gesture locationInView:self.mapView];
    location = (CGPoint){location.x + kUnpinOffset.x, location.y + kUnpinOffset.y};
    
    UIGestureRecognizerState state = gesture.state;
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.mapView deselectAnnotation:self.annotation animated:YES];
            startPoint = location;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CATransform3D transform = CATransform3DMakeTranslation(location.x - startPoint.x, location.y - startPoint.y, 0.0f);
            self.layer.transform = transform;
            lastPoint = location;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.layer.transform = CATransform3DIdentity;
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:lastPoint toCoordinateFromView:self.mapView];
            EFAnnotation *annotation = (EFAnnotation *)self.annotation;
            EFRouteLocation *routeLocation = [self.mapDataSource routeLocationForAnnotation:annotation];
            routeLocation.coordinate = coordinate;
            [self.mapDataSource updateRouteLocation:routeLocation inMapView:self.mapView];
        }
            break;
        default:
            break;
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

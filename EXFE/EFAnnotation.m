//
//  EFAnnotation.m
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFAnnotation.h"

@interface EFAnnotation ()

@property (nonatomic, strong) UIImage     *markImage;

@end

@implementation EFAnnotation

- (id)initWithStyle:(EFAnnotationStyle)style
         coordinate:(CLLocationCoordinate2D)location
              title:(NSString *)title
        description:(NSString *)description
{
    self = [super init];
    if (self) {
        self.style = style;
        self.coordinate = location;
        self.title = title;
        self.subtitle = description;
    }
    
    return self;
}

#pragma mark - Property Accessor

- (void)setStyle:(EFAnnotationStyle)style
{
    [self willChangeValueForKey:@"style"];
    
    _style = style;
    
    switch (style) {
        case kEFAnnotationStyleDestination:
            self.markImage = [UIImage imageNamed:@"map_pin_blue.png"];
            break;
        case kEFAnnotationStyleParkRed:
            self.markImage = [UIImage imageNamed:@"map_mark_red.png"];
            break;
        case kEFAnnotationStyleParkBlue:
        default:
            self.markImage = [UIImage imageNamed:@"map_mark_blue.png"];
            break;
    }
    
    [self didChangeValueForKey:@"style"];
}

@end

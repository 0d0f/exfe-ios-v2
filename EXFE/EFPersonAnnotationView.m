//
//  EFPersonAnnotationView.m
//  EXFE
//
//  Created by 0day on 13-7-19.
//
//

#import "EFPersonAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFPersonAnnotation.h"

@implementation EFPersonAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = (CGRect){CGPointZero, {18.0f, 18.0f}};
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    
    if (annotation) {
        NSAssert([annotation isKindOfClass:[EFPersonAnnotation class]], nil);
        EFPersonAnnotation *personAnnotation = annotation;
        if (personAnnotation.isOnline) {
            self.image = [UIImage imageNamed:@"map_dot_red.png"];
        } else {
            self.image = [UIImage imageNamed:@"map_dot_grey.png"];
        }
    }
}

@end

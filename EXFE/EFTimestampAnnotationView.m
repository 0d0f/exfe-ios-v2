//
//  EFTimestampAnnotationView.m
//  EXFE
//
//  Created by 0day on 13-8-12.
//
//

#import "EFTimestampAnnotationView.h"

#import "EFTimestampAnnotation.h"

@interface EFTimestampAnnotationView ()

@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UILabel *meterLabel;

@end

@interface EFTimestampAnnotationView (Private)

- (void)_layoutSubviews;

@end

@implementation EFTimestampAnnotationView (Private)

- (void)_layoutSubviews {

}

@end

@implementation EFTimestampAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.timestampLabel = [[UILabel alloc] initWithFrame:(CGRect){}]
    }
    
    return self;
}

#pragma mark - Property Accessor

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    
}

@end

//
//  EFTimestampAnnotationView.m
//  EXFE
//
//  Created by 0day on 13-8-12.
//
//

#import "EFTimestampAnnotationView.h"

#import <QuartzCore/QuartzCore.h>
#import "EFTimestampAnnotation.h"
#import "Util.h"

@interface EFTimestampAnnotationView ()

@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UILabel *meterLabel;

@end

@interface EFTimestampAnnotationView (Private)

- (void)_reloadData;

@end

@implementation EFTimestampAnnotationView (Private)

- (void)_reloadData {
    EFTimestampAnnotation *annotation = (EFTimestampAnnotation *)self.annotation;
    long timeInterval = (long)([[NSDate date] timeIntervalSinceDate:annotation.timestamp] / 60.0f);
    NSString *time = NSLocalizedString(@"分钟前", nil);
    
    if (timeInterval / 60) {
        time = NSLocalizedString(@"小时前", nil);
        timeInterval /= 60;
    }
    
    self.timestampLabel.text = [NSString stringWithFormat:@"%ld", timeInterval];
    [self.timestampLabel sizeToFit];
    
    self.meterLabel.text = time;
    [self.meterLabel sizeToFit];
    self.meterLabel.frame = (CGRect){{CGRectGetWidth(self.timestampLabel.frame) + 2, 1.0f}, self.meterLabel.frame.size};
    
    self.frame = (CGRect){{0.0f, 0.0f}, {CGRectGetWidth(self.timestampLabel.frame) + CGRectGetWidth(self.meterLabel.frame) + 5.0f, 12.0f}};
}

@end

@implementation EFTimestampAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timestampLabel = [[UILabel alloc] initWithFrame:(CGRect){{2.0f, 0.0f}, {8.0f, 12.0f}}];
        self.timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        self.timestampLabel.textAlignment = NSTextAlignmentRight;
        self.timestampLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.timestampLabel];
        
        self.meterLabel = [[UILabel alloc] initWithFrame:(CGRect){{9.0f, 0.0f}, {24.0f, 12.0f}}];
        self.meterLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:8];
        self.meterLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.meterLabel];
        
        self.layer.cornerRadius = 2.0f;
        self.backgroundColor = [UIColor COLOR_RGBA(0xCC, 0xCC, 0xCC, 255.0f * 0.66)];
        
        self.centerOffset = (CGPoint){0.0f, -15.0f};
    }
    
    return self;
}

#pragma mark - Property Accessor

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    [self _reloadData];
}

@end

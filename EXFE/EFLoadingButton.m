//
//  EFLoadingButton.m
//  EXFE
//
//  Created by 0day on 13-9-27.
//
//

#import "EFLoadingButton.h"

@interface EFLoadingButton ()

@property (nonatomic, strong) UIActivityIndicatorView   *activityView;  // rewrite property

@end

@implementation EFLoadingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.hidden = YES;
        [self addSubview:activityIndicatorView];
        self.activityView = activityIndicatorView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect buttonBounds = self.bounds;
    CGRect labelFrame = self.titleLabel.frame;
    self.activityView.center = (CGPoint){CGRectGetMinX(labelFrame) - CGRectGetMidX(self.activityView.bounds) - 5.0f, CGRectGetMidY(buttonBounds)};
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        [self.activityView stopAnimating];
        self.activityView.hidden = YES;
    } else {
        [self.activityView startAnimating];
        self.activityView.hidden = NO;
    }
}

@end

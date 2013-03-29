//
//  EXHereHeaderView.m
//  EXFE
//
//  Created by 0day on 13-3-30.
//
//

#import "EXHereHeaderView.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@implementation EXHereHeaderView

- (id)init {
    self = [[[[NSBundle mainBundle] loadNibNamed:@"EXHereHeaderView"
                                           owner:nil
                                         options:nil] lastObject] retain];
    
    if (self) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColor COLOR_RGB(0x33, 0x33, 0x33)].CGColor, (id)[UIColor COLOR_RGB(0x22, 0x22, 0x22)].CGColor];
        [self.layer insertSublayer:gradient atIndex:0];
    }
    
    return self;
}

- (void)dealloc {
    [_backButton release];
    [_gatherButton release];
    [super dealloc];
}
@end

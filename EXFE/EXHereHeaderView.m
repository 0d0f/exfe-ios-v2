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
        // background layer
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.bounds;
        gradient.colors = @[(id)[UIColor COLOR_RGB(0x33, 0x33, 0x33)].CGColor, (id)[UIColor COLOR_RGB(0x22, 0x22, 0x22)].CGColor];
        [self.layer insertSublayer:gradient atIndex:0];
        
        // tip view
        self.tipView.layer.cornerRadius = 3;
        
        // button background
        UIImage *buttonBackgroundImage = [UIImage imageNamed:@"btn_blue_30inset.png"];
        if ([buttonBackgroundImage respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            buttonBackgroundImage = [buttonBackgroundImage resizableImageWithCapInsets:(UIEdgeInsets){0, 10, 0, 10}];
        } else {
            buttonBackgroundImage = [buttonBackgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:0];
        }
        
        [self.gatherButton setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
    }
    
    return self;
}

- (IBAction)titleControlPressed:(id)sender {
}

- (void)dealloc {
    [_backButton release];
    [_gatherButton release];
    [_tipView release];
    [super dealloc];
}
@end

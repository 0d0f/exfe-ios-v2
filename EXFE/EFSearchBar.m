//
//  EFSearchBar.m
//  EXFE
//
//  Created by 0day on 13-4-17.
//
//

#import "EFSearchBar.h"

@implementation EFSearchBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // remove tint
    if ([[[self subviews] objectAtIndex:0] isKindOfClass:[UIImageView class]]){
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setShowsCancelButton:NO animated:NO];
}

@end

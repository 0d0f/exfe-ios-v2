//
//  EFMapEditingReadyView.m
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapEditingReadyView.h"
#import <QuartzCore/QuartzCore.h>

@implementation EFMapEditingReadyView

- (void)_init {
    CGRect viewBounds = self.bounds;
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:viewBounds];
    noteLabel.textColor = [UIColor whiteColor];
    noteLabel.backgroundColor = [UIColor clearColor];
    noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    noteLabel.textAlignment = NSTextAlignmentCenter;
    noteLabel.text = NSLocalizedString(@"Please draw route on map", nil);
    [self addSubview:noteLabel];
    self.noteLabel = noteLabel;
    
    self.layer.cornerRadius = 2.0f;
    self.backgroundColor = [UIColor colorWithRed:(51.0f / 255.0f) green:(51.0f / 255.0f) blue:(51.0f / 255.0f) alpha:0.8f];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    
    return self;
}

@end

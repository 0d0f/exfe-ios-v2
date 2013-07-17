//
//  EFMapEditingAnnotationView.m
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import "EFMapEditingAnnotationView.h"

#import "EFMapColorButton.h"

@interface EFMapEditingAnnotationView ()

@property (nonatomic, strong) EFMapColorButton  *blueButton;
@property (nonatomic, strong) EFMapColorButton  *redButton;
@property (nonatomic, strong) UIView            *panView;

@end

@implementation EFMapEditingAnnotationView

- (void)_init {

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

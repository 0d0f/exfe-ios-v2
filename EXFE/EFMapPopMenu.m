//
//  EFMapPopMenu.m
//  EXFE
//
//  Created by 0day on 13-7-23.
//
//

#import "EFMapPopMenu.h"

#import <QuartzCore/QuartzCore.h>

@interface EFMapPopMenu ()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *stateLabel;
@property (nonatomic, weak) UILabel *destinationDistanceLabel;
@property (nonatomic, weak) UILabel *yourDistanceLabel;
@property (nonatomic, weak) UIButton *requestButton;

@property (nonatomic, weak) UIView  *baseView;

@end

@implementation EFMapPopMenu

- (id)initWithName:(NSString *)name
        updateTime:(NSDate *)time
     pressedHanler:(ButtonPressedHandler)handler {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (void)show {
    if (!self.baseView) {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        UIView *baseView = [[UIView alloc] initWithFrame:rootView.bounds];
        baseView.backgroundColor = [UIColor clearColor];
        [rootView addSubview:baseView];
        self.baseView = baseView;
    }
}

- (void)dismiss {

}

@end

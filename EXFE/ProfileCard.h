//
//  ProfileCard.h
//  EXFE
//
//  Created by Stony on 12/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"
#import <CoreText/CoreText.h>

@interface ProfileCard : ABTableViewCell{
    UIImage *avatar;
    id profileTarget;
    id gatherTarget;
    SEL profileAction;
    SEL gatherAction;
}
@property (nonatomic, strong) UIImage* avatar;


- (void)addProfileTarget:(id)target action:(SEL)action;
- (void)removeProfileTarget:(id)target action:(SEL)action;
- (void)performProfileClick;

- (void)addGatherTarget:(id)target action:(SEL)action;
- (void)removeGatherTarget:(id)target action:(SEL)action;
- (void)performGatherClick;

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer;

@end

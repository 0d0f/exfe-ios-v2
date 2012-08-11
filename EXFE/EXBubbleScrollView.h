//
//  EXBubbleScrollView.h
//  BubbleTextField
//
//  Created by huoju on 8/11/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EXBubbleButton.h"

#define INPUT_MIN_WIDTH 100

@class EXBubbleScrollView;
@protocol EXBubbleScrollViewDelegate <UIScrollViewDelegate>
@required
- (void)OnInputConfirm:(EXBubbleScrollView *)bubbleScrollView textField:(UITextField*)textfield;
- (id)customObject:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input;
- (BOOL)isInputValid:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input;

@end

@interface EXBubbleScrollView : UIScrollView <UITextFieldDelegate> {
    NSMutableArray *bubbles;
    UITextField *input;
    id <EXBubbleScrollViewDelegate> _exdelegate;
}
-(BOOL) addBubble:(NSString*)title;
-(void) setDelegate:(id<EXBubbleScrollViewDelegate>)delegate;
-(NSArray*) bubbleCustomObjects;
@end

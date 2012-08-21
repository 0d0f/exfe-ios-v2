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
@protocol EXBubbleScrollViewDelegate <NSObject>
@required
- (void)OnInputConfirm:(EXBubbleScrollView *)bubbleScrollView textField:(UITextField*)textfield;
- (id)customObject:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input;
- (BOOL)isInputValid:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input;
- (BOOL) inputTextChange:(EXBubbleScrollView *)bubbleScrollView input:(NSString*)input;
- (void) deleteLastBubble:(EXBubbleScrollView *)bubbleScrollView deletedbubble:(EXBubbleButton*)bubble;
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
@end


@interface EXBubbleScrollView : UIScrollView <UITextFieldDelegate,UIScrollViewDelegate> {
    NSMutableArray *bubbles;
    UITextField *input;
    UIImageView *inputbackgroundImage;
//    UIImageView *icon;
    UIView *backgroundview;
    id <EXBubbleScrollViewDelegate> _exdelegate;
}
-(BOOL) addBubble:(NSString*)title customObject:(id)customobject;
-(void) deleteLastBubble;
-(void) setEXBubbleDelegate:(id<EXBubbleScrollViewDelegate>)delegate;
-(NSArray*) bubbleCustomObjects;
- (void)inputTextChange:(NSNotification *)notification;
- (NSString*)getInput;
- (int) bubblecount;
@end

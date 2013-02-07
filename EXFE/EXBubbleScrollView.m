//
//  EXBubbleScrollView.m
//  BubbleTextField
//
//  Created by huoju on 8/11/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import "EXBubbleScrollView.h"

@implementation EXBubbleScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        leftview = [[UIView alloc] initWithFrame:CGRectMake(-320, 0, 320, 30)];
        leftview.backgroundColor=FONT_COLOR_HL;
        [self addSubview:leftview];
        
        input=[[UITextField alloc] initWithFrame:CGRectMake(6+18+4, 0, self.frame.size.width, 30)];
        [input setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
        [input setReturnKeyType:UIReturnKeyDefault];
        
        input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        CGRect inputframe=input.frame;
        inputframe.origin.x=0;
        inputframe.origin.y=0;
//        inputbackgroundImage = [[UIImageView alloc] initWithFrame:inputframe];
//        inputbackgroundImage.image = [UIImage imageNamed:@"textfield_navbar_frame.png"];
//        inputbackgroundImage.contentMode    = UIViewContentModeScaleToFill;
//        inputbackgroundImage.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
        
        backgroundview=[[UIView alloc] initWithFrame:inputframe];
        backgroundview.backgroundColor=[UIColor clearColor];
        [self addSubview:backgroundview];
        bubbles=[[NSMutableArray alloc] initWithCapacity:12];
        
        input.delegate=self; 
        [input setAutocorrectionType:UITextAutocorrectionTypeNo];
        [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [input setText:@" "];
        [input setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:input];

        self.showsHorizontalScrollIndicator=NO;
        self.delegate=self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextChange:) name:UITextFieldTextDidChangeNotification object:input];
        
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [inputbackgroundImage release];
    [bubbles release];
    [input release];
    [backgroundview release];
    [leftview release];
	[super dealloc];
}
- (void) deleteLastBubble:(EXBubbleScrollView *)bubbleScrollView deletedbubble:(EXBubbleButton*)bubble{
    [_exdelegate deleteLastBubble:bubbleScrollView deletedbubble:bubble];
}
-(void) deleteLastBubble{
    [[bubbles lastObject] removeFromSuperview];
    [bubbles removeObjectAtIndex:[bubbles count]-1];
    UIButton *lastbubble=[bubbles lastObject];
    CGRect lastbubbleframe=lastbubble.frame;
    CGRect inputframe=input.frame;
    inputframe.origin.x=lastbubbleframe.origin.x+lastbubbleframe.size.width+4;
    if(inputframe.origin.x<6+18+4)
        inputframe.origin.x=6+18+4;

    if(inputframe.origin.x+inputframe.size.width<self.frame.size.width)
        inputframe.size.width=self.frame.size.width-inputframe.origin.x;
    
    [input setFrame:inputframe];
    CGRect backframe=backgroundview.frame;
    backframe.size.width=inputframe.origin.x+inputframe.size.width;
    [backgroundview setFrame:backframe];
    [self deleteLastBubble:self deletedbubble:(EXBubbleButton*)lastbubble];
//    if(inputframe.origin.x>self.contentSize.width/3*2) {
        [self setContentSize:CGSizeMake(inputframe.origin.x+input.frame.size.width, self.contentSize.height)];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        float offset=self.contentSize.width-self.frame.size.width;
        [self setContentOffset:CGPointMake(offset, 0)];
        [UIView commitAnimations];
//    }
    if([bubbles count]==0){
        leftview.backgroundColor=[UIColor clearColor];
    }
}

-(BOOL) addBubble:(NSString*)title customObject:(id)customobject{

    if([title isEqualToString:@""])
       return NO;
    for (EXBubbleButton *_bubble in bubbles){
        if([_bubble.customObject isEqual:customobject])
            return NO;
    }
    if(customobject==nil){
        BOOL isinputvalid=[_exdelegate isInputValid:self input:title];
        if(isinputvalid==NO)
            return NO;
        customobject=[_exdelegate customObject:self input:input.text];
    }
    EXBubbleButton *button=[EXBubbleButton buttonWithType:UIButtonTypeCustom];
    button.customObject=customobject;
    [button setAdjustsImageWhenHighlighted:NO];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[[button titleLabel] setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [[button titleLabel] setShadowColor:[UIColor blackColor]];
    [[button titleLabel] setShadowOffset:CGSizeMake(1.0, 1.0)];
	[[button titleLabel] setLineBreakMode:UILineBreakModeTailTruncation];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
	[button setTitle:title forState:UIControlStateNormal];
    
	[button sizeToFit];
    CGRect rect=[button frame];
    rect.size.width+=25;
    rect.size.height=30;
    
    UIButton *lastbubble=[bubbles lastObject];
    if(lastbubble!=nil){
        int newx=lastbubble.frame.origin.x+lastbubble.frame.size.width;
        rect.origin.x=newx;
    }else{
        rect.origin.x=6+18+4;
    }
    [button setFrame:rect];
    [bubbles addObject:button];
    [backgroundview addSubview:button];
    CGRect inputframe=input.frame;
    inputframe.origin.x=rect.origin.x+rect.size.width;
    if(inputframe.size.width>INPUT_MIN_WIDTH)
        inputframe.size.width-=rect.size.width;
    if(inputframe.size.width<INPUT_MIN_WIDTH)
        inputframe.size.width=INPUT_MIN_WIDTH;
    [input setFrame:inputframe];

    CGRect backframe=backgroundview.frame;
    backframe.size.width=inputframe.origin.x+inputframe.size.width;
    [backgroundview setFrame:backframe];

    if(inputframe.origin.x>self.contentSize.width/3*2){
        [self setContentSize:CGSizeMake(inputframe.origin.x+input.frame.size.width, self.contentSize.height)];
        float offset=self.contentSize.width-self.frame.size.width;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [self setContentOffset:CGPointMake(offset, 0)];
        [UIView commitAnimations];
        CGRect leftframe=CGRectMake(-320, 0, 320+18+6+6, 30);
        [leftview setFrame:leftframe];
    }
    input.text=@" ";
    return YES;
}
-(NSArray*) bubbleCustomObjects{
    NSMutableArray *mutablearray=[[[NSMutableArray alloc] initWithCapacity:12] autorelease];
    for(EXBubbleButton* bubble in bubbles){
        [mutablearray addObject:bubble.customObject];
    }
    return mutablearray;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_exdelegate OnInputConfirm:self textField:input];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([input.text isKindOfClass:[NSString class]] && NSEqualRanges(NSMakeRange(0, 1), range) && [string isEqualToString:@""]){
        [input setText:@"  "];
        if([bubbles count]>0)
            [self deleteLastBubble];
    }
    return YES;
}
- (void)inputTextChange:(NSNotification *)notification{
    NSString *inputtext=[input.text stringByTrimmingCharactersInSet:
                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [_exdelegate inputTextChange:self input:inputtext];
}

-(void) setEXBubbleDelegate:(id<EXBubbleScrollViewDelegate>)delegate{
    _exdelegate=delegate;
}
- (NSString*)getInput{
//    NSLog(@"%@",input.text);
    NSString *inputtext=[input.text stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return inputtext;
}
- (int) bubblecount{
    return [bubbles count];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_exdelegate scrollViewDidScroll:scrollView];
}
- (void) hiddenkeyboard{
    [input resignFirstResponder];
}
@end

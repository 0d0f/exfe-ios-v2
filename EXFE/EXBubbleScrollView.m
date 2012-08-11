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
        bubbles=[[NSMutableArray alloc] initWithCapacity:12];
        input=[[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        input.delegate=self;
        [input setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:input];
        self.showsHorizontalScrollIndicator=NO;
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [bubbles release];
    [input release];
	[super dealloc];
}

-(BOOL) addBubble:(NSString*)title{
    
    BOOL isinputvalid=[_exdelegate isInputValid:self input:title];
    if(isinputvalid==NO)
        return NO;
    id customobject=[_exdelegate customObject:self input:input.text];
    EXBubbleButton *button=[EXBubbleButton buttonWithType:UIButtonTypeCustom];
    button.customObject=customobject;
    button.backgroundColor=[UIColor greenColor];
    [button setAdjustsImageWhenHighlighted:NO];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[[button titleLabel] setFont:[UIFont fontWithName:@"Helvetica Neue" size:9]];
	[[button titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
	[button setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
	[button setTitle:title forState:UIControlStateNormal];
    
	[button sizeToFit];
    CGRect rect=[button frame];
    rect.size.width+=25;
    rect.size.height+=10;
    UIButton *lastbubble=[bubbles lastObject];
    if(lastbubble!=nil){
        int newx=lastbubble.frame.origin.x+lastbubble.frame.size.width;
        rect.origin.x=newx+4;
    }
    [button setFrame:rect];
    [bubbles addObject:button];
    [self addSubview:button];
    CGRect inputframe=input.frame;
    inputframe.origin.x=rect.origin.x+rect.size.width+4;
    if(inputframe.size.width>INPUT_MIN_WIDTH)
        inputframe.size.width-=rect.size.width+4;
    if(inputframe.size.width<INPUT_MIN_WIDTH)
        inputframe.size.width=INPUT_MIN_WIDTH;
    [input setFrame:inputframe];

    if(inputframe.origin.x+inputframe.size.width>self.contentSize.width){
        [self setContentSize:CGSizeMake(inputframe.origin.x+input.frame.size.width, self.contentSize.height)];
        float offset=self.contentSize.width-self.frame.size.width;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [self setContentOffset:CGPointMake(offset, 0)];
        [UIView commitAnimations];
        
    }
    input.text=@"";
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
-(void) setDelegate:(id<EXBubbleScrollViewDelegate>)delegate{
    _exdelegate=delegate;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

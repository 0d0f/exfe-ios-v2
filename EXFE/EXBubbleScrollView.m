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
//        self.backgroundColor=
        //        self.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bg.png"]];
        
        self.backgroundColor=[UIColor clearColor];
        input=[[UITextField alloc] initWithFrame:CGRectMake(18, 3, self.frame.size.width-18, 30)];

        
        CGRect inputframe=input.frame;
        //        inputframe.size.height=27;
        inputframe.origin.x=0;
        inputbackgroundImage = [[UIImageView alloc] initWithFrame:inputframe];
        inputbackgroundImage.image = [UIImage imageNamed:@"textfield_navbar.png"];
        inputbackgroundImage.contentMode    = UIViewContentModeScaleToFill;
        inputbackgroundImage.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
        
        [self addSubview:inputbackgroundImage];

        bubbles=[[NSMutableArray alloc] initWithCapacity:12];
        
        input.delegate=self;
        [input setAutocorrectionType:UITextAutocorrectionTypeNo];
        [input setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [input setText:@" "];
        [input setBackgroundColor:[UIColor clearColor]];
        [self addSubview:input];

        icon=[[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 18, 18)];
        icon.image=[UIImage imageNamed:@"exfee_18.png"];
        [self addSubview:icon];
        
        self.showsHorizontalScrollIndicator=NO;
        
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
    [icon release];
	[super dealloc];
}
-(void) deleteLastBubble{
    [[bubbles lastObject] removeFromSuperview];
    [bubbles removeObjectAtIndex:[bubbles count]-1];
    UIButton *lastbubble=[bubbles lastObject];
    CGRect lastbubbleframe=lastbubble.frame;
    CGRect inputframe=input.frame;
    inputframe.origin.x=lastbubbleframe.origin.x+lastbubbleframe.size.width+4;
    if(inputframe.origin.x+inputframe.size.width<self.frame.size.width)
        inputframe.size.width=self.frame.size.width-inputframe.origin.x;

    [input setFrame:inputframe];
    if(inputframe.origin.x+inputframe.size.width<self.contentSize.width){
        [self setContentSize:CGSizeMake(inputframe.origin.x+input.frame.size.width, self.contentSize.height)];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        float offset=self.contentSize.width-self.frame.size.width;
        [self setContentOffset:CGPointMake(offset, 0)];
        [UIView commitAnimations];
    }

}

-(BOOL) addBubble:(NSString*)title customObject:(id)customobject{

    if(customobject==nil){
        BOOL isinputvalid=[_exdelegate isInputValid:self input:title];
        if(isinputvalid==NO)
            return NO;
        customobject=[_exdelegate customObject:self input:input.text];
    }
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
//        NSString *inputtext=[input.text substringToIndex:1];
//        NSLog(@"back delete:%@ ",inputtext);
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

-(void) setDelegate:(id<EXBubbleScrollViewDelegate>)delegate{
    _exdelegate=delegate;
}
- (NSString*)getInput{
    return input.text;
}

//- (void)drawRect:(CGRect)rect
//{
//    UIImage *backgroundImage = [UIImage imageNamed:@"toolbarbg.png"];
//    backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:floorf(backgroundImage.size.width/2) topCapHeight:floorf(backgroundImage.size.height/2)];
//    [backgroundImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//}


@end

//
//  EXIconToolBar.m
//  EXFE
//
//  Created by huoju on 7/11/12.
//
//

#import "EXIconToolBar.h"

@implementation EXIconToolBar

- (id)initWithPoint:(CGPoint)point buttonsize:(CGSize)buttonsize delegate:(id)delegate
{
    CGRect toolbarframe=CGRectMake(point.x, point.y, 320, 50);
    if(buttonsize.width==0 && buttonsize.height==0)
    {
        button_width=DEFAULT_BUTTON_WIDTH;
        button_height=DEFAULT_BUTTON_HEIGHT;
    }
    else{
        button_width=buttonsize.width;
        button_height=buttonsize.height;
    }
    self = [self initWithFrame:toolbarframe];
    ;
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_bg.png"]]];
    _delegate=delegate;
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) setItemIndex:(int)index{
    itemIndex=index;
    for(UIControl* view in self.subviews)
    {
        view.tag=itemIndex;
    }
}
- (void)setDelegate:(id)delegate{
    _delegate=delegate;
}
- (void) drawButton:(NSArray*)buttons{
    for(int i=0;i<[buttons count];i++)
    {
        EXButton *button=[buttons objectAtIndex:i];
        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
        [button.titleLabel setTextColor:FONT_COLOR_250];
        [self addSubview:button];
    }
}
- (void) replaceButtonImage:(UIImage*)img title:(NSString*)title target:(id)target action:(SEL)action forname:(NSString*)name{
    
    for(UIControl* view in self.subviews)
    {
        if([view isKindOfClass:[EXButton class]])
        {
            EXButton* button=(EXButton*)view;
            if([button.buttonName isEqualToString:name])
            {
                [button setImage:img forState:UIControlStateNormal];
                [button setTitle:title forState:UIControlStateNormal];
                [button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
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

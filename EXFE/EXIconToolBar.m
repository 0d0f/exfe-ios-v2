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
    CGRect toolbarframe=CGRectMake(point.x, point.y, 320, 44);
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
    [self setBackgroundColor:[UIColor blackColor]];
    self.alpha=0.5;
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
    int width=self.frame.size.width/[buttons count];
    for(int i=0;i<[buttons count];i++)
    {
        float x=width*i+(width-button_width)/2;
        EXButton *button=[buttons objectAtIndex:i];
        [button setFrame:CGRectMake(x, 0, button_width, button_height)];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10.0]];
        [self addSubview:button];
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

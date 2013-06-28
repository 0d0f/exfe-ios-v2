//
//  ConversationInputAccessoryView.m
//  EXFE
//
//  Created by huoju on 8/7/12.
//
//

#import "ConversationInputAccessoryView.h"

@implementation ConversationInputAccessoryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIButton *btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
        [btnPrev setFrame: CGRectMake(0.0, 0.0, 80.0, 40.0)];
        [btnPrev setTitle: NSLocalizedString(@"Previous", nil) forState: UIControlStateNormal];
        [btnPrev setBackgroundColor: [UIColor blueColor]];
        [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
        
        UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnNext setFrame:CGRectMake(85.0f, 0.0f, 80.0f, 40.0f)];
        [btnNext setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
        [btnNext setBackgroundColor:[UIColor blueColor]];
        [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDone setFrame:CGRectMake(240.0, 0.0f, 80.0f, 40.0f)];
        [btnDone setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        [btnDone setBackgroundColor:[UIColor greenColor]];
        [btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
        
        // Now that our buttons are ready we just have to add them to our view.
        [self addSubview:btnPrev];
        [self addSubview:btnNext];
        [self addSubview:btnDone];
        // Initialization code
    }
    return self;
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

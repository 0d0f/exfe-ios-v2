//
//  CustomAttributedTextView.m
//  EXFE
//
//  Created by huoju on 12/18/12.
//
//

#import "CustomAttributedTextView.h"

@implementation CustomAttributedTextView
@synthesize text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initializatio8n code
    }
    return self;
}

- (void)setText:(NSString *)s {
	[text release];
	text = [s copy];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [text drawInRect:rect];
}

@end

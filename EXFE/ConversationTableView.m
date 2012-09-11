//
//  ConversationTableView.m
//  EXFE
//
//  Created by ju huo on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConversationTableView.h"

@implementation ConversationTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"tableview touch began");

    //resignFirstResponder for the UITextView
    
    //call didSelectRow of tableView again, by passing the touch to the super class
    [super touchesBegan:touches withEvent:event];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIImage *v_line=[UIImage imageNamed:@"conv_line_v.png"];
    CGImageRef v_line_ref = CGImageRetain(v_line.CGImage);
    CGContextClipToRect(context, CGRectMake(30, -200, 11, rect.size.height+500));
    CGContextTranslateCTM(context, 30, v_line.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawTiledImage(context, CGRectMake(0, 0, v_line.size.width, v_line.size.height), v_line_ref);
    CGImageRelease(v_line_ref);
    CGContextRestoreGState(context);
}

@end

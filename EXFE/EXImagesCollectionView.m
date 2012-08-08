//
//  EXIconCollectionView.m
//  IconListView
//
//  Created by huoju on 6/20/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import "EXImagesCollectionView.h"

@implementation EXImagesCollectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    
    [self initData];
    taghost=[UIImage imageNamed:@"tag-host.png"];
    avatareffect=[UIImage imageNamed:@"avatar_effect.png"];
    addexfee=[UIImage imageNamed:@"gather_add_exfee.png"];
    tagmates=[UIImage imageNamed:@"tag-mates.png"];
    tagrsvpaccepted=[UIImage imageNamed:@"rsvpbg-accepted.png"];
    hiddenAddButton=NO;
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initData];
}

- (void) initData{
    self.userInteractionEnabled=YES;
    imageWidth=40;
    imageHeight=40;
    nameHeight=15;
    imageXmargin=5;
    imageYmargin=5;
    [self calculateColumn];
    int x_count=0;
    int y_count=0;
    int count=maxColumn*maxRow;
    grid=[[NSMutableArray alloc]initWithCapacity:count];
    for(int i=0;i<count;i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        int x=x_count*(imageWidth+imageXmargin*2);
        int y=y_count*(imageHeight+nameHeight+imageYmargin*2);
        CGRect rect=CGRectMake(x,y,imageWidth,imageHeight);
        [grid addObject:[NSValue valueWithCGRect:rect]];
        x_count++;
    }
}

- (void) setImageWidth:(float)width height:(float)height{
    imageWidth=width;
    imageHeight=height;
    [self calculateColumn];
}
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin{
    imageXmargin=xmargin;
    imageYmargin=ymargin;
    [self calculateColumn];
}
- (void) setDataSource:(id) dataSource{
    _dataSource=dataSource;
}
- (void) setDelegate:(id) delegate{
    _delegate=delegate;
}
- (void) calculateColumn{
    maxColumn=(self.frame.size.width-imageWidth)/(imageWidth+imageXmargin*2)+1;
    maxRow=(self.frame.size.height-(imageHeight+nameHeight))/(imageHeight+nameHeight+imageYmargin*2)+1;
}

- (void)drawRect:(CGRect)rect
{
    int x_count=0;
    int y_count=0;
    int count=[_dataSource numberOfimageCollectionView:self];
    NSArray *selected=[_dataSource selectedOfimageCollectionView:self];
    
    for(int i=0;i<count;i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        int x=x_count*(imageWidth+imageXmargin*2)+imageXmargin;
        int y=y_count*(imageHeight+15+imageYmargin)+imageYmargin;

        BOOL isSelected=[[selected objectAtIndex:i] boolValue];
        if(isSelected==YES)
        {
            [Util drawRoundRect:CGRectMake(x-imageXmargin, y-imageYmargin, imageWidth+imageXmargin*2, imageHeight+imageYmargin+15) color:[UIColor blueColor] radius:5];
        }
        
        Invitation *invitation=[_dataSource imageCollectionView:self imageAtIndex:i];
        Identity *identity=invitation.identity;
        
        UIImage *avatar = [[ImgCache sharedManager] getImgFrom:identity.avatar_filename];

        if(avatar==nil || [avatar isEqual:[NSNull null]]){
            avatar=[ImgCache getDefaultImage];
        }

        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x,y,imageWidth,imageHeight) cornerRadius:3];
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextSaveGState(currentContext);
        CGContextBeginPath(currentContext);
        CGContextAddPath(currentContext, maskPath.CGPath);
        CGContextClosePath(currentContext);
        CGContextClip(currentContext);
        [avatar drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];
        [avatareffect drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];

        CGContextRestoreGState(currentContext);
        
        if([invitation.host boolValue]==YES)
            [taghost drawInRect:CGRectMake(x+imageWidth-12, y, 12, 12)];
        int mates=[invitation.mates intValue];
        if(mates>0)
        {
            [[UIColor whiteColor] set];
            [tagmates drawInRect:CGRectMake(x, y, 12, 12)];
            NSString *mates=[invitation.mates stringValue];
            [mates drawInRect:CGRectMake(x+6, y, 12, 12) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:10]];
            [@"+" drawInRect:CGRectMake(x, y, 12, 12) withFont:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:10]];
        }
        if([invitation.rsvp_status isEqualToString:@"ACCEPTED"])
            [tagrsvpaccepted drawInRect:CGRectMake(x+imageWidth-12, y+imageHeight-12, 12, 12)];

        NSString *name=identity.name;
        if(name==nil)
            name=identity.external_username;
        if(name==nil)
            name=identity.external_id;
        if(name!=nil){
            [[UIColor blackColor] set];
            [name drawInRect:CGRectMake(x, y+imageHeight, imageWidth, 15) withFont:[UIFont fontWithName:@"HelveticaNeue" size:11] lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
        }
        x_count++;
    }

    if( x_count==maxColumn){
        x_count=0;
        y_count++;
    }

    if(hiddenAddButton==NO)
        if(count<maxColumn*maxRow) {
            int x=x_count*(imageWidth+imageXmargin*2)+imageXmargin;
            int y=y_count*(imageHeight+imageYmargin+15)+imageYmargin;
            
            [addexfee drawInRect:CGRectMake(x,y,140,40)];
        }
}
- (void) HiddenAddButton{
    hiddenAddButton=YES;
}
- (void) reloadData{

    int count=[_dataSource numberOfimageCollectionView:self];
    if(count >maxColumn*maxRow-1)
    {
        float new_height=imageYmargin+imageHeight+15+(imageYmargin+imageHeight+15)*maxRow;
        if(new_height!=self.frame.size.height)
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
    }
    else{
        int row=1;
        for(int row_idx=0;row_idx<=maxRow;row_idx++)
        {
            if(maxColumn*row_idx-(count)>0)
            {
                row=row_idx;
                break;
            }
        }
        float new_height=imageYmargin+imageHeight+15+(imageYmargin+imageHeight+15)*(row-1);
        if(new_height!=self.frame.size.height)
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
    }
    [self setNeedsDisplay];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        [self onImageTouch:touchPoint];
    }
}

- (void) onImageTouch:(CGPoint) point{
    int x_count=0;
    int y_count=0;

    for (int i=0;i<[grid count];i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }

        CGRect rect=[(NSValue*)[grid objectAtIndex:i] CGRectValue];
        BOOL inrect=CGRectContainsPoint(rect,point);
        if(inrect==YES){
            [_delegate imageCollectionView:self didSelectRowAtIndex:i row:y_count col:x_count];
        }
        x_count++;
    }
}

- (void)dealloc {
	[grid release];
    [super dealloc];
}
@end

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
//        if(x==0)
//            x=imageXmargin;
        int y=y_count*(imageHeight+imageYmargin*2)+imageYmargin;
//        if(y==0)
//            y=imageYmargin;
        if(y_count>0)
            y+=15;

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
        UIImage *avatar_effect=[UIImage imageNamed:@"avatar_effect.png"];
        [avatar drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];
        [avatar_effect drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];

        CGContextRestoreGState(currentContext);
        
        if([invitation.host boolValue]==YES)
            [[UIImage imageNamed:@"closebutton"] drawInRect:CGRectMake(x+imageWidth-10, y, 10, 10)];
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

    if(count<maxColumn*maxRow) {
        int x=x_count*(imageWidth+imageXmargin*2)+imageXmargin;
//        if(x==0)
//            x=imageXmargin;

        int y=y_count*(imageHeight+imageYmargin*2)+imageXmargin;
//        if(y==0)
//            y=imageXmargin;
        if(y_count>0)
            y+=15;
        UIImage *image=[UIImage imageNamed:@"gather_add_exfee.png"];
        if(image==nil || [image isEqual:[NSNull null]])
            image=[ImgCache getDefaultImage];
        [image drawInRect:CGRectMake(x,y,140,40)];
    }
}

- (void) reloadData{

    int count=[_dataSource numberOfimageCollectionView:self];
    if(count >maxColumn*maxRow-1)
    {
        float new_height=imageHeight+15+(10+imageHeight+15)*maxRow;
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

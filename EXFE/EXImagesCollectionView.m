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

    imageWidth=40;
    imageHeight=40;
    imageXmargin=2;
    imageYmargin=2;
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
        int y=y_count*(imageHeight+imageYmargin*2);
        CGRect rect=CGRectMake(x,y,imageWidth,imageHeight);
        [grid addObject:[NSValue valueWithCGRect:rect]];
        x_count++;
    }
    NSLog(@"%@",grid);
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
    maxColumn=self.frame.size.width/(imageWidth+imageXmargin*2);
    maxRow=self.frame.size.height/(imageHeight+imageYmargin*2);
}

- (void)drawRect:(CGRect)rect
{
    int x_count=0;
    int y_count=0;
    int count=[_dataSource numberOfimageCollectionView:self];
    for(int i=0;i<count;i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        int x=x_count*(imageWidth+imageXmargin*2);
        int y=y_count*(imageHeight+imageYmargin*2);
        UIImage *image=[_dataSource imageCollectionView:self imageAtIndex:i];
        [image drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];
        x_count++;
    }
}

- (void) reloadData{
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

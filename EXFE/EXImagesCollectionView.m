//
//  EXIconCollectionView.m
//  IconListView
//
//  Created by huoju on 6/20/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import "EXImagesCollectionView.h"

@implementation EXImagesCollectionView
@synthesize maxColumn;
@synthesize maxRow;
@synthesize imageWidth;
@synthesize imageHeight;
@synthesize nameHeight;
@synthesize imageXmargin;
@synthesize imageYmargin;
@synthesize itemsCache;
@synthesize editmode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    [self initData];
    itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
    maskview=[[EXCollectionMask alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [maskview setBackgroundColor:[UIColor clearColor]];
    maskview.imageWidth=imageWidth;
    maskview.imageHeight=imageHeight;
    maskview.nameHeight=nameHeight;
    maskview.imageXmargin=imageXmargin;
    maskview.imageYmargin=imageYmargin;
    maskview.maxColumn=maxColumn;
    maskview.maxRow=maxRow;
    maskview.hiddenAddButton=NO;
    
    
    [self addSubview:maskview];
    [self bringSubviewToFront:maskview];
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
- (void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    [maskview setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}
- (void)drawRect:(CGRect)rect
{

}
- (void) HiddenAddButton{
    maskview.hiddenAddButton=YES;
    [maskview setNeedsDisplay];
}
- (void) ShowAddButton{
    maskview.hiddenAddButton=NO;
    [maskview setNeedsDisplay];
    
}
- (void) reloadData{
    for(UIView *view in self.subviews){
        if([view isKindOfClass:[EXImagesItem class]])
            [view removeFromSuperview];
    }
    [itemsCache removeAllObjects];
    [itemsCache release];
    itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
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
            if(editmode==YES){
                if(maxColumn*row_idx-(count)>0)
                {
                    row=row_idx;
                    break;
                }
            }else{
                if(maxColumn*row_idx-(count)>=0)
                {
                    row=row_idx;
                    break;
                }
            }
        }
        float new_height=imageYmargin+imageHeight+15+(imageYmargin+imageHeight+15)*(row-1);
        if(new_height!=self.frame.size.height)
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
    }

    int x_count=0;
    int y_count=0;
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
        EXImagesItem *item=[itemsCache objectForKey:[NSNumber numberWithInt:i]];
        if(item==nil)
        {
            EXImagesItem *item=[_dataSource imageCollectionView:self imageAtIndex:i];
            item.isSelected=isSelected;
            [item setFrame:CGRectMake(x, y, imageWidth, imageHeight+15)];
            [item setBackgroundColor:[UIColor clearColor]];
            [itemsCache setObject:item forKey:[NSNumber numberWithInt:i]];
            [self addSubview:item];
            [self sendSubviewToBack:item];

        }
        else{
            [item setNeedsDisplay];
        }
  
        x_count++;
    }
    //
    if( x_count==maxColumn){
        x_count=0;
        y_count++;
    }
    //
    [self setNeedsDisplay];
    maskview.itemsCache=itemsCache;
    [maskview setNeedsDisplay];
    
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
            [_delegate imageCollectionView:self didSelectRowAtIndex:i row:y_count col:x_count frame:rect];
        }
        x_count++;
    }
}

- (void)dealloc {
	[grid release];
    [super dealloc];
}
@end

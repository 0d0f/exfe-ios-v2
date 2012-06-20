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
- (void) calculateColumn{
    maxColumn=self.frame.size.width/(imageWidth+imageXmargin*2);
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
        //UIImage *image=(UIImage*)[imageList objectAtIndex:i];
        UIImage *image=[_dataSource imageCollectionView:self imageAtIndex:i];
        [image drawInRect:CGRectMake(x,y,imageWidth,imageHeight)];
        x_count++;
    }
//    UIImage *image=[UIImage imageNamed:@"twitter.png"];
//    [image drawInRect:CGRectMake(0,0,40,40)];
//    [image drawInRect:CGRectMake(40,0,40,40)];
    NSLog(@"drawrect:%u",[imageList count]);
}
- (void) reloadData{
    UIImage *image=[UIImage imageNamed:@"twitter.png"];
    imageList=[[NSArray alloc] initWithObjects:image,image,image,nil];

    [self setNeedsDisplay];
}
@end

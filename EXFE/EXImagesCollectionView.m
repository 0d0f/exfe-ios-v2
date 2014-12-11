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
//@synthesize itemsCache;
@synthesize editmode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initData];
}

- (void) initData{
    self.userInteractionEnabled=YES;
    imageWidth=50;
    imageHeight=50;
    nameHeight=0;
    imageXmargin=5;
    imageYmargin=5;
    [self calculateColumn];
}

- (CGRect)rectAtPostion:(NSUInteger)pos
{
    NSUInteger row = pos / maxColumn;
    NSUInteger idx = pos % maxColumn;
    
    return CGRectMake(idx * (imageWidth + imageXmargin * 2),
               row * (imageHeight + imageYmargin * 2) + y_start_offset,
               imageWidth,imageHeight);
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
    maxRow=(self.frame.size.height-y_start_offset)/(imageHeight+imageYmargin*2)+1;
}
- (void) setFrame:(CGRect)frame{
    [super setFrame:frame];
//    [maskview setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}
- (void)drawRect:(CGRect)rect
{

}
- (void) HiddenAddButton{
//    maskview.hiddenAddButton=YES;
//    [maskview setNeedsDisplay];
}
- (void) ShowAddButton{
//    maskview.hiddenAddButton=NO;
//    [maskview setNeedsDisplay];
    
}
- (void) reloadData{

    for(UIView *view in self.subviews){
        if([view isKindOfClass:[EXInvitationItem class]])
            [view removeFromSuperview];
//        [view release];
    }
    if(acceptlabel!=nil){
        [acceptlabel setHidden:YES];
    }
    
    if(itemsCache!=nil){
        [itemsCache removeAllObjects];
    }
    itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
    int count=[_dataSource numberOfimageCollectionView:self];
    if(count >maxColumn*maxRow-1)
    {
        int new_column=ceil((float)(count+1)/maxColumn);
        
        int new_height=new_column*(imageHeight+imageYmargin*2)+y_start_offset;
        if(new_height!=self.frame.size.height){
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
        }
    }
    else{
        int row=1;
        for(int row_idx=0;row_idx<=maxRow;row_idx++) {
                if(maxColumn*row_idx-(count+1)>=0) {
                    row=row_idx;
                    break;
                }
        }
        float new_height=imageYmargin+imageHeight+5+(imageYmargin+imageHeight+5)*(row-1);
        if(new_height!=self.frame.size.height){
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
        }
    }

    int x_count=0;
    int y_count=0;
    
    int acceptednum=0;
    int allnum=0;
    for (UIView *subview in [self subviews]){
      if ([subview isKindOfClass:[ExfeeNumberView class]]){
        [subview removeFromSuperview];
      }
    }
  
    for(int i=0;i<=count;i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        int x=x_count*(imageWidth+imageXmargin*2);
        int y=y_count*(imageHeight+imageYmargin*2)+y_start_offset;

        if(i<count){
            EXInvitationItem *item=[itemsCache objectForKey:[NSNumber numberWithInt:i]];
            if(item==nil)
            {
                EXInvitationItem *item=[_dataSource imageCollectionView:self itemAtIndex:i];
                if(item!=nil){
                    [item setFrame:CGRectMake(x, y, imageWidth+10, imageHeight+10)];
                    [itemsCache setObject:item forKey:[NSNumber numberWithInt:i]];
                    [self addSubview:item];
                    if([item.invitation.rsvp_status isEqualToString:@"ACCEPTED"]){
                        acceptednum += 1;
                        if( acceptednum==1){
                            if(acceptlabel==nil){
                                acceptlabel=[[UIBorderLabel alloc] initWithFrame:CGRectMake(x, y-12, 60, 17)];
                                [acceptlabel setBackgroundColor:[UIColor colorWithRed:0xd2/255.0f green:0xe2/255.0f blue:0xf4/255.0f alpha:1]];
                                UIBezierPath *maskPath;
                                maskPath = [UIBezierPath bezierPathWithRoundedRect:acceptlabel.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(1.5, 1.5)];
                                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                                maskLayer.frame = self.bounds;
                                maskLayer.path = maskPath.CGPath;
                                acceptlabel.layer.mask = maskLayer;
                                
                                [acceptlabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:10]];
                                [acceptlabel setTextColor:[UIColor colorWithRed:103/255.0 green:127/255.0 blue:153/255.0 alpha:1]];
                                [acceptlabel setTextAlignment:NSTextAlignmentLeft];
                                [self addSubview:acceptlabel];
                            }
                            [acceptlabel setFrame:CGRectMake(x, y-12, 60, 17)];
                            acceptlabel.text=NSLocalizedString(@"Accepted", nil);
                            acceptlabel.leftInset = 5;
                            acceptlabel.topInset = 0;
                            acceptlabel.bottomInset = 1;
                            [acceptlabel setHidden:NO];
                            [self bringSubviewToFront:acceptlabel];
                            [self performSelector:@selector(hiddenAcceptLabel) withObject:self afterDelay:4];
                        }
                    }
                    allnum+=1+[item.invitation.mates intValue];
                }
            }
            else{
                [item setNeedsDisplay];
            }
            
        }
        else{
            ExfeeNumberView *exfeecount=[[ExfeeNumberView alloc] initWithFrame:CGRectMake(x+5, y+5, 52, 52)];
            exfeecount.acceptednumber=acceptednum;
            exfeecount.allnumber=allnum;
            exfeecount.backgroundColor=[UIColor whiteColor];
            [self addSubview:exfeecount];
        }

        x_count++;
    }
    if( x_count==maxColumn){
//        x_count=0;
        y_count++;
    }
    [self setNeedsDisplay];
}

- (void)hiddenAcceptLabel{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    acceptlabel.alpha=0;
    [UIView commitAnimations];

}

- (void) onImageTouch:(CGPoint) point{
    int allcount=[_dataSource numberOfimageCollectionView:self];
    for (NSUInteger i = 0;i < allcount + 1; i ++) {
        CGRect rect= [self rectAtPostion:i];
        BOOL hit = CGRectContainsPoint(rect,point);
        if (hit == YES) {
            if (i < allcount) {
                [_delegate imageCollectionView:self didSelectRowAtIndex:i row:(i / maxColumn) col:(i % maxColumn) frame:rect];
            } else if (i == allcount){
                //                RKLogDebug(@"click the sum grid: x=%i y=%i count=%i",x_count,y_count,allcount);
            }
        }

    }
}

@end

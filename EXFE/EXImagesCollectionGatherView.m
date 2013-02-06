//
//  EXImagesCollectionGatherView.m
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import "EXImagesCollectionGatherView.h"

@implementation EXImagesCollectionGatherView

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
    self.userInteractionEnabled = YES;
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
        int y=y_count*(imageHeight+imageYmargin*2)+y_start_offset;
        
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
//    if(acceptlabel!=nil){
//        [acceptlabel setHidden:YES];
//    }
    
    [itemsCache removeAllObjects];
    [itemsCache release];
    itemsCache=[[NSMutableDictionary alloc] initWithCapacity:12];
    int count=[_dataSource numberOfimageCollectionView:self];
    if(count >maxColumn*maxRow-1)
    {
        int new_column=ceil((float)(count+1)/maxColumn);
        
        int new_height=new_column*(imageHeight+imageYmargin*2)+y_start_offset;
        if(new_height!=self.frame.size.height)
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
    }
    else{
        int row=1;
        for(int row_idx=0;row_idx<=maxRow;row_idx++)
        {
//            if(editmode==YES){
                if(maxColumn*row_idx-(count)>0)
                {
                    row=row_idx;
                    break;
                }
//            }else{
//                if(maxColumn*row_idx-(count)>=0)
//                {
//                    row=row_idx;
//                    break;
//                }
//            }
        }
        float new_height=imageYmargin+imageHeight+5+(imageYmargin+imageHeight+5)*(row-1);
        if(new_height!=self.frame.size.height)
            [_delegate imageCollectionView:self shouldResizeHeightTo:new_height];
    }
    
    int x_count=0;
    int y_count=0;
    
    //    NSArray *selected=[_dataSource selectedOfimageCollectionView:self];
    int acceptednum=0;
    int allnum=0;
    //    BOOL acceptflag=NO;
    for(int i=0;i<=count;i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        int x=x_count*(imageWidth+imageXmargin*2);
        int y=y_count*(imageHeight+imageYmargin*2)+y_start_offset;
        
        if(i<count){
            //        BOOL isSelected=[[selected objectAtIndex:i] boolValue];
            EXInvitationItem *item=[itemsCache objectForKey:[NSNumber numberWithInt:i]];
            if(item==nil)
            {
                EXInvitationItem *item=[_dataSource imageCollectionView:self itemAtIndex:i];
                if(item!=nil){
                    //            item.isSelected=isSelected;
                    [item setFrame:CGRectMake(x, y, imageWidth+10, imageHeight+10)];
                    //            [item setBackgroundColor:[UIColor clearColor]];
                    [itemsCache setObject:item forKey:[NSNumber numberWithInt:i]];
                    [self addSubview:item];
                    if([item.invitation.rsvp_status isEqualToString:@"ACCEPTED"]){
                        acceptednum += 1;
                    }
                    allnum+=1+[item.invitation.mates intValue];
                }
            }
            else{
                [item setNeedsDisplay];
            }
            
        }
        else{
            if(addview==nil){
                addview=[[UIView alloc] initWithFrame:CGRectMake(x+5, y+5, 52, 52)];
                UIImageView *addimg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
                addimg.image=[UIImage imageNamed:@"gather_add.png"];
                [addview addSubview:addimg];
                invited_num=[[UILabel alloc] initWithFrame:CGRectMake(-1, 2, 18, 13)];
                invited_num.font=[UIFont fontWithName:@"HelveticaNeue" size:13];
                invited_num.textColor=FONT_COLOR_51;
                invited_num.text=[NSString stringWithFormat:@"%i",allnum];
                invited_num.backgroundColor=[UIColor clearColor];
                invited_num.textAlignment=NSTextAlignmentRight;
                [addview addSubview:invited_num];
                
                UILabel *invitedstr=[[UILabel alloc] initWithFrame:CGRectMake(19, 4, 52-18, 10)];
                invitedstr.font=[UIFont fontWithName:@"HelveticaNeue" size:10];
                invitedstr.textColor=FONT_COLOR_51;
                invitedstr.text=@"invited";
                invitedstr.backgroundColor=[UIColor clearColor];
                invitedstr.textAlignment=NSTextAlignmentLeft;
                [addview addSubview:invitedstr];
                [invitedstr release];
                
                [self addSubview:addview];
                [addimg release];
                [addview release];
            }
            else{
                [addview setFrame:CGRectMake(x+5, y+5, 52, 52)];
            }
        }
        
        if(invited_num!=nil)
            invited_num.text=[NSString stringWithFormat:@"%i",allnum];

        x_count++;
    }
    if( x_count==maxColumn){
        x_count=0;
        y_count++;
    }
    [self setNeedsDisplay];
}

- (void) onImageTouch:(CGPoint) point{
    int x_count=0;
    int y_count=0;
    int countidx=0;
    int allcount=[_dataSource numberOfimageCollectionView:self];
    for (int i=0;i<[grid count];i++)
    {
        if( x_count==maxColumn){
            x_count=0;
            y_count++;
        }
        countidx+=1;
        CGRect rect=[(NSValue*)[grid objectAtIndex:i] CGRectValue];
        BOOL inrect=CGRectContainsPoint(rect,point);
        if(inrect==YES){
            if(countidx<=allcount+1){
                [_delegate imageCollectionView:self didSelectRowAtIndex:i row:y_count col:x_count frame:rect];
            }
//            else if (countidx==allcount+1){
//                NSLog(@"click the sum grid: x=%i y=%i count=%i",x_count,y_count,allcount);
//            }
        }
        x_count++;
    }
}

- (void)dealloc {
	[grid release];
    if(invited_num!=nil)
       [invited_num release];
//    [acceptlabel release];
    [super dealloc];
}

@end

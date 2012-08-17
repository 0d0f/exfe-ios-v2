//
//  EXIconCollectionView.h
//  IconListView
//
//  Created by huoju on 6/20/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgCache.h"
#import "Identity.h"
#import "Invitation.h"
#import "Util.h"

@class EXImagesCollectionView;
@protocol EXImagesCollectionDataSource;

@protocol EXImagesCollectionDataSource<NSObject>

@required
- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;
- (Invitation *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index;
- (NSArray *) selectedOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;
@end

@protocol EXImagesCollectionDelegate<NSObject>
@required
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect;
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView shouldResizeHeightTo:(float)height;
@end


@interface EXImagesCollectionView : UIView{
    NSMutableArray *grid;
    float imageWidth;
    float imageHeight;
    float nameHeight;
    float imageXmargin;
    float imageYmargin;
    int maxColumn;
    int maxRow;
    id <EXImagesCollectionDataSource>  _dataSource;
    id <EXImagesCollectionDelegate> _delegate;
    UIImage *taghost;
    UIImage *avatareffect;
    UIImage *addexfee;
    UIImage *tagmates;
    UIImage *tagrsvpaccepted;
    
    UIImage *exfee_frame_host;
    UIImage *exfee_frame_mates;
    UIImage *exfee_frame;
    
    UIImage *rsvp_accept_badge;
    UIImage *rsvp_interested_badge;
    UIImage *rsvp_pending_badge;
    UIImage *rsvp_unavailable_badge;
    
    BOOL hiddenAddButton;
    
}
- (void) setImageWidth:(float)width height:(float)height;
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin;
- (void) setDataSource:(id) dataSource;
- (void) setDelegate:(id) delegate;
- (void) HiddenAddButton;
- (void) reloadData;
- (void) initData;
- (void) calculateColumn;
- (void) onImageTouch:(CGPoint) point;
//- (void) drawRoundRect:(CGRect) rect color:(UIColor*)color radius:(float)radius;

@end

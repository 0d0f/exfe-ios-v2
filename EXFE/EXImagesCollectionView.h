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
#import "EXInvitationItem.h"
#import "EXCollectionMask.h"
#import "ExfeeNumberView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIBorderLabel.h"


#define y_start_offset 12

@class EXImagesCollectionView;
@protocol EXImagesCollectionDataSource;

@protocol EXImagesCollectionDataSource<NSObject>

@required
- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;
- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView itemAtIndex:(int)index;
//- (NSArray *) selectedOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;
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
    
    BOOL hiddenAddButton;
    BOOL editmode;
    NSMutableDictionary *itemsCache;
    EXCollectionMask *maskview;
    //UILabel *acceptlabel;
    UIBorderLabel *acceptlabel;
}
@property int maxColumn;
@property int maxRow;
@property BOOL editmode;
@property float imageWidth;
@property float imageHeight;
@property float nameHeight;
@property float imageXmargin;
@property float imageYmargin;
@property (nonatomic,retain) NSMutableDictionary *itemsCache;

- (void) setImageWidth:(float)width height:(float)height;
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin;
- (void) setDataSource:(id) dataSource;
- (void) setDelegate:(id) delegate;
- (void) HiddenAddButton;
- (void) ShowAddButton;
- (void) reloadData;
- (void) initData;
- (void) calculateColumn;
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) onImageTouch:(CGPoint) point;
- (void) hiddenAcceptLabel;

//- (void) drawRoundRect:(CGRect) rect color:(UIColor*)color radius:(float)radius;

@end

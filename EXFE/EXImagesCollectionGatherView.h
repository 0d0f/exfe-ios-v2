//
//  EXImagesCollectionGatherView.h
//  EXFE
//
//  Created by huoju on 1/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Identity.h"
#import "Invitation.h"
#import "Util.h"
#import "EXInvitationItem.h"
#import "EXCollectionMask.h"
#import "ExfeeNumberView.h"

#define y_start_offset 12

@class EXImagesCollectionGatherView;
@class TTTAttributedLabel;
@protocol EXImagesCollectionDataSource;

@protocol EXImagesCollectionGatherDataSource<NSObject>

@required
- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView;
- (EXInvitationItem *)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView itemAtIndex:(int)index;
@end

@protocol EXImagesCollectionGatherDelegate<NSObject>
@required
- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col frame:(CGRect)rect;
- (void)imageCollectionView:(EXImagesCollectionGatherView *)imageCollectionView shouldResizeHeightTo:(float)height;
@end

@interface EXImagesCollectionGatherView : UIView{
    NSMutableArray *grid;
    float imageWidth;
    float imageHeight;
    float nameHeight;
    float imageXmargin;
    float imageYmargin;
    int maxColumn;
    int maxRow;
    id <EXImagesCollectionGatherDataSource>  _dataSource;
    id <EXImagesCollectionGatherDelegate> _delegate;
    
    BOOL hiddenAddButton;
    BOOL editmode;
    NSMutableDictionary *itemsCache;
    EXCollectionMask *maskview;
    TTTAttributedLabel *invitedString;

    UIView *addview;
}

@property int maxColumn;
@property int maxRow;
@property BOOL editmode;
@property float imageWidth;
@property float imageHeight;
@property float nameHeight;
@property float imageXmargin;
@property float imageYmargin;
@property (nonatomic,strong) NSMutableDictionary *itemsCache;

- (void) setImageWidth:(float)width height:(float)height;
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin;
- (void) setDataSource:(id) dataSource;
- (void) setDelegate:(id) delegate;
- (void) HiddenAddButton;
- (void) ShowAddButton;
- (void) reloadData;
- (void) initData;
- (void) calculateColumn;
- (void) calculateGridRect;
- (void) onImageTouch:(CGPoint) point;
@end

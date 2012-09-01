//
//  EXCollectionMask.h
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import <UIKit/UIKit.h>
#import "EXImagesItem.h"

@interface EXCollectionMask : UIView{
    NSMutableDictionary *itemsCache;
    float imageWidth;
    float imageHeight;
    float nameHeight;
    float imageXmargin;
    float imageYmargin;
    BOOL hiddenAddButton;
    int maxColumn;
    int maxRow;
}
@property (nonatomic,retain)NSMutableDictionary *itemsCache;
@property int maxColumn;
@property int maxRow;
@property BOOL hiddenAddButton;
@property float imageWidth;
@property float imageHeight;
@property float nameHeight;
@property float imageXmargin;
@property float imageYmargin;

@end

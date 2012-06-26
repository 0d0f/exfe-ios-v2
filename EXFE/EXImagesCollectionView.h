//
//  EXIconCollectionView.h
//  IconListView
//
//  Created by huoju on 6/20/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImgCache.h"

@class EXImagesCollectionView;
@protocol EXImagesCollectionDataSource;

@protocol EXImagesCollectionDataSource<NSObject>

@required
- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;
- (UIImage *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index;
@end

@protocol EXImagesCollectionDelegate<NSObject>
@required
- (void)imageCollectionView:(EXImagesCollectionView *)imageCollectionView didSelectRowAtIndex:(int)index row:(int)row col:(int)col;
@end


@interface EXImagesCollectionView : UIView{
//    NSArray *imageList;
    NSMutableArray *grid;
    float imageWidth;
    float imageHeight;
    float imageXmargin;
    float imageYmargin;
    int maxColumn;
    int maxRow;
    id <EXImagesCollectionDataSource>  _dataSource;
    id <EXImagesCollectionDelegate> _delegate;
}
- (void) setImageWidth:(float)width height:(float)height;
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin;
- (void) setDataSource:(id) dataSource;
- (void) setDelegate:(id) delegate;
- (void) reloadData;
- (void) initData;
- (void) calculateColumn;
- (void) onImageTouch:(CGPoint) point;

@end

//
//  EXIconCollectionView.h
//  IconListView
//
//  Created by huoju on 6/20/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EXImagesCollectionView;
@protocol EXImagesCollectionDataSource;

@protocol EXImagesCollectionDataSource<NSObject>

@required

- (NSInteger) numberOfimageCollectionView:(EXImagesCollectionView *)imageCollectionView;

- (UIImage *)imageCollectionView:(EXImagesCollectionView *)imageCollectionView imageAtIndex:(int)index;
@end

@interface EXImagesCollectionView : UIView{
    NSArray *imageList;
    float imageWidth;
    float imageHeight;
    float imageXmargin;
    float imageYmargin;
    int maxColumn;
    id <EXImagesCollectionDataSource>  _dataSource;
}
- (void) setImageWidth:(float)width height:(float)height;
- (void) setImageXMargin:(float)xmargin YMargin:(float)ymargin;
- (void) setDataSource:(id) dataSource;
- (void) reloadData;
- (void) initData;
- (void) calculateColumn;

@end

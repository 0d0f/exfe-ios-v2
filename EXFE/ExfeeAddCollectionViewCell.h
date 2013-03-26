//
//  ExfeeAddCollectionViewCell.h
//  EXFE
//
//  Created by Stony Wang on 13-3-26.
//
//

#import <UIKit/UIKit.h>

@interface ExfeeAddCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) NSUInteger total;
@property (nonatomic, assign) NSUInteger accept;

@property (nonatomic, readonly) UILabel *description;
@property (nonatomic, readonly) UIImageView *avatar;

@end

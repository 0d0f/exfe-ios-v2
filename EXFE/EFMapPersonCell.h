//
//  EFMapPersonCell.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EFMapPerson;
@interface EFMapPersonCell : UITableViewCell

@property (strong)  UIImageView      *avatarBaseImageView;
@property (strong)  UIImageView      *avatarImageView;
@property (strong)  UIImageView      *stateImageView;
@property (strong)  UILabel          *stateLabel;
@property (strong)  UILabel          *meterLabel;
@property (nonatomic, weak)    EFMapPerson      *person;

+ (CGFloat)defaultCellHeight;

@end

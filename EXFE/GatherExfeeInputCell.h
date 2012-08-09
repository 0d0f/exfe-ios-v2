//
//  GatherExfeeInputCell.h
//  EXFE
//
//  Created by huoju on 8/9/12.
//
//

#import "ABTableViewCell.h"

@interface GatherExfeeInputCell : ABTableViewCell{
    UIImage *avatar;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic,retain) UIImage* avatar;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* subtitle;
@end

//
//  EXVerticalAlignLabel.h
//  EXFE
//
//  Created by 0day on 13-3-29.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kEXLabelVerticalAlignmentTop,
    kEXLabelVerticalAlignmentBottom
} EXLabelVerticalAlignment;

@interface EXVerticalAlignLabel : UILabel

@property (nonatomic, assign) EXLabelVerticalAlignment verticalAlignment;

@end

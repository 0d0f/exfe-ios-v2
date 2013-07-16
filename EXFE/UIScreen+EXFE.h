//
//  UIScreen+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 13-7-16.
//
//

#import <UIKit/UIKit.h>

NS_ENUM(NSUInteger, UIScreenRatio)
{
    UIScreenRatioUnspecific, // Unknown
    UIScreenRatioWide,     // 4:3 XGA or 2x QXGA, [iPad, iPad 2, iPad mini] 2x[new iPad (iPad 3gen), iPad 4]
    UIScreenRatioStandard, // 3:2 HVGA or 2x DVGA, [iPhone, iPhone 3G, iPhone 3GS, iPod touch 1 gen, iPod touch 2gen, iPod touch 3 gen] 2x[iPhone 4, iPhone 4s, iPod Touch 4 gen]
    UIScreenRatioLong      // 16:9 [iPhone 5, iPod Touch 5 gen]
};

@interface UIScreen (EXFE)

@property (nonatomic, readonly) enum UIScreenRatio ratio;

@end

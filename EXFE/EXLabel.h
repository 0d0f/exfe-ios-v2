//
//  EXLabel.h
//  EXFE
//
//  Created by Stony Wang on 12-12-29.
//
//

#import <UIKit/UIKit.h>

@interface EXLabel : UILabel{
    BOOL hasMore;
    BOOL isExpended;
    NSString *placeholder;
    UIColor *color;
    CGFloat minimumHeight;
}

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, retain) UIColor *placehlderColor;
@property CGFloat minimumHeight;

@end

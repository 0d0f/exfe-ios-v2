//
//  UIBorderLabel.h
//  EXFE
//
//  Created by Stony Wang on 13-2-6.
//
//

#import <UIKit/UIKit.h>

@interface UIBorderLabel : UILabel{
    CGFloat topInset;
    CGFloat leftInset;
    CGFloat bottomInset;
    CGFloat rightInset;
}

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat leftInset;
@property (nonatomic, assign) CGFloat bottomInset;
@property (nonatomic, assign) CGFloat rightInset;

@end

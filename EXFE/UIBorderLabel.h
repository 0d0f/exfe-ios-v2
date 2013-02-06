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

@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat leftInset;
@property (nonatomic) CGFloat bottomInset;
@property (nonatomic) CGFloat rightInset;

@end

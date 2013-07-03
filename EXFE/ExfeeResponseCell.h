//
//  ExfeeResponseCell.h
//  EXFE
//
//  Created by Stony Wang on 3/12/13.
//
//

#import "ABTableViewCell.h"
#import "EXAttributedLabel.h"
#import "Identity.h"

@class ExfeeResponseCell;

@protocol ExfeeResponseCellDelegate<NSObject>

-(void)responseCell:(ExfeeResponseCell*)sender onDelete:(Identity*)identity;
-(void)responseCell:(ExfeeResponseCell*)sender onVerify:(Identity*)identity;

@end

@interface ExfeeResponseCell : ABTableViewCell<UIGestureRecognizerDelegate>{

    CGRect providerRect;
    CGRect displayNameRect;
    CGRect verifyHint;
    CGRect displayNameRect2;
    
    Identity * _identity;
}

@property (nonatomic, unsafe_unretained) id delegate;
@property (nonatomic, strong) Identity * identity;

@end

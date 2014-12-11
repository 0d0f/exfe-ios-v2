//
//  EXButton.h
//  EXFE
//
//  Created by huoju on 7/11/12.
//
//

#import <UIKit/UIKit.h>

@interface EXButton : UIButton{
    NSString *buttonName;
    UIImageView *backgroundview;
    BOOL setInset;
}
@property (nonatomic,strong) NSString *buttonName;
@property BOOL setInset;

- (id)initWithName:(NSString*)name title:(NSString*)buttontitle image:(UIImage*) img inFrame:(CGRect) frame;
- (void) updateFrame:(CGRect)rect;
@end

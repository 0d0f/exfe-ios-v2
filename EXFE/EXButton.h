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
}
@property (nonatomic,retain) NSString *buttonName;
- (id)initWithName:(NSString*)name title:(NSString*)buttontitle image:(UIImage*) img;
@end

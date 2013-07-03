//
//  EXOverlayView.h
//  EXFE
//
//  Created by huoju on 7/24/12.
//
//

#import <UIKit/UIKit.h>

@interface EXOverlayView : UIView{
    UIBezierPath *transparentPath;
    UIImage *backgroundimage;
    UIColor *color;
    BOOL gradientcolors;
    int cornerRadius;
    int arrowHeight;
}
@property (nonatomic,strong) UIBezierPath *transparentPath;
@property (nonatomic,strong) UIImage *backgroundimage;
@property (nonatomic,strong) UIColor *color;
@property int cornerRadius;
@property int arrowHeight;
@property BOOL gradientcolors;
@end

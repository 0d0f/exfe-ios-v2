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
}
@property (nonatomic,retain) UIBezierPath *transparentPath;
@property (nonatomic,retain) UIImage *backgroundimage;
@end

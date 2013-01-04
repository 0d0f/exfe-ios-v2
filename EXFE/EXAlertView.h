//
//  EXAlertView.h
//  EXFE
//
//  Created by huoju on 1/3/13.
//
//

#import <UIKit/UIKit.h>
#import "NSObject+PerformBlockAfterDelay.h"
#import <QuartzCore/QuartzCore.h>

#if __has_feature(objc_arc)
#define MB_AUTORELEASE(exp) exp
#define MB_RELEASE(exp) exp
#define MB_RETAIN(exp) exp
#else
#define MB_AUTORELEASE(exp) [exp autorelease]
#define MB_RELEASE(exp) [exp release]
#define MB_RETAIN(exp) [exp retain]
#endif

@interface EXAlertView : UIView{
    NSString *alertmsg;
}
@property (retain,nonatomic) NSString* alertmsg;

+ (EXAlertView *)showAlertTo:(UIView *)view frame:(CGRect)frame message:(NSString*)msg animated:(BOOL)animated;
+ (void) hideAlertFrom:(UIView *)view animated:(BOOL)animated delay:(NSTimeInterval)time;
+ (EXAlertView *)AlertFrom:(UIView *)view;

@end

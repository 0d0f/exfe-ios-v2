
#import <Foundation/Foundation.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UIGestureRecognizer {
        TouchesEventBlock touchesBeganCallback;
        TouchesEventBlock touchesEndCallback;
        TouchesEventBlock touchesMoveCallback;
}
@property(copy) TouchesEventBlock touchesBeganCallback;
@property(copy) TouchesEventBlock touchesEndCallback;
@property(copy) TouchesEventBlock touchesMoveCallback;


@end

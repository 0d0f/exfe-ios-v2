//
//  EFMapPopMenu.h
//  EXFE
//
//  Created by 0day on 13-7-23.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^ButtonPressedHandler)(UIButton *);

@interface EFMapPopMenu : UIView

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSDate    *updateTimestamp;
@property (nonatomic, assign) CLLocationCoordinate2D    destinationCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D    userCoordinate;
@property (nonatomic, assign) CLLocationCoordinate2D    meCoordinate;

@property (nonatomic, copy) ButtonPressedHandler requestButtonPressedHandler;

- (id)initWithName:(NSString *)name
        updateTime:(NSDate *)time
     pressedHanler:(ButtonPressedHandler)handler;

- (void)show;
- (void)dismiss;

@end

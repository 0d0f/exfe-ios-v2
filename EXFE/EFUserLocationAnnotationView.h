//
//  EFUserLocationAnnotationView.h
//  EXFE
//
//  Created by 0day on 13-8-9.
//
//

#import <MapKit/MapKit.h>

@interface EFUserLocationAnnotationView : MKAnnotationView

@property (nonatomic, strong) CLHeading     *userHeading;

@property (nonatomic, assign) BOOL          showNavigation;
@property (nonatomic, assign) CGFloat       radianBetweenDestination;

@end

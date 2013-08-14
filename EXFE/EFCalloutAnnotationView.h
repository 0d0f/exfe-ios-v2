//
//  EFCalloutAnnotationView.h
//  MarauderMap
//
//  Created by 0day on 13-7-15.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "EFAnnotationDataDefines.h"

@class EFCalloutAnnotation;
@interface EFCalloutAnnotationView : MKAnnotationView
<
UITextFieldDelegate,
UITextViewDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) MKAnnotationView  *parentAnnotationView;
@property (nonatomic, strong) MKMapView         *mapView;

@property (nonatomic, copy)   TouchEventBlock   titlePressedHandler;
@property (nonatomic, copy)   TouchEventBlock   subtitlePressedHandler;

@property (nonatomic, copy)   CallbackBlock     editingWillStartHandler;
@property (nonatomic, copy)   CallbackBlock     editingDidEndHandler;

@property (nonatomic, assign, getter = isEditing) BOOL  editing;

- (void)reloadAnnotation:(EFCalloutAnnotation *)annotation;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end

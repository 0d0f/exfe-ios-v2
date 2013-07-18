//
//  EFMapEditingAnnotationView.h
//  MarauderMap
//
//  Created by 0day on 13-7-12.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EFAnnotationDataDefines.h"

@class EFMapEditingAnnotationView;
@protocol EFMapEditingAnnotationViewDelegate <NSObject>
@optional
- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view isChangingToTitle:(NSString *)title;
- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view didChangeToTitle:(NSString *)title;
- (void)mapEditingAnnotationView:(EFMapEditingAnnotationView *)view didChangeToStyle:(EFAnnotationStyle)annotationStyle;
@end


@interface EFMapEditingAnnotationView : UIView

@property (nonatomic, weak) id<EFMapEditingAnnotationViewDelegate> delegate;
@property (nonatomic, copy) NSString *markLetter;

@end

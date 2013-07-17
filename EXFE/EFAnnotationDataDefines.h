//
//  EFAnnotationDataDefines.h
//  MarauderMap
//
//  Created by 0day on 13-7-13.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#ifndef MarauderMap_EFAnnotationDataDefines_h
#define MarauderMap_EFAnnotationDataDefines_h

typedef enum {
    kEFAnnotationStyleDestination = 0,
    kEFAnnotationStyleParkBlue,
    kEFAnnotationStyleParkRed
} EFAnnotationStyle;

typedef void (^TouchEventBlock)(void);
typedef void (^CallbackBlock)(id);

#endif

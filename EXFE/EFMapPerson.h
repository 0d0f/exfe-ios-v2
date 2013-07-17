//
//  EFMapPerson.h
//  MarauderMap
//
//  Created by 0day on 13-7-5.
//  Copyright (c) 2013年 exfe. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EFMapDataDefines.h"

@interface EFMapPerson : NSObject

@property (strong)      NSMutableArray              *pathMapPoints;
@property (strong)      UIImage                     *avatarImage;
@property (nonatomic)   CGFloat                     distence;
@property (nonatomic)   EFMapPersonConnectState     connectState;
@property (nonatomic)   EFMapPersonLocationState    locationState;

@end

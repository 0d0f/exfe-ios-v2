//
//  Cross.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Identity.h"
#import "Place.h"

@interface Cross : NSObject{
    NSNumber* _id;
    NSString* _id_base62;
    NSString* _title;
    NSString* _description;
    NSString* _created_at;
    Identity* _by_identity;
    Identity* _host_identity;
    Place* _place;
}

@property (nonatomic,retain) NSNumber *id;
@property (nonatomic,retain) NSString *id_base62;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *description;
@property (nonatomic,retain) NSString *created_at;
@property (nonatomic,retain) Identity *by_identity;
@property (nonatomic,retain) Identity *host_identity;
@property (nonatomic,retain) Place *place;
@end

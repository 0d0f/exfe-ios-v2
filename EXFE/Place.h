//
//  Place.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Place : NSObject{
    NSNumber* _id;
    NSString* _description;
    NSString* _external_id;
    NSNumber* _lat;
    NSNumber* _lng;
    NSString* _title;
    NSString* _provider;
    NSString* _updated_at;
    NSString* _created_at;
}

@property (nonatomic,retain) NSNumber* id;
@property (nonatomic,retain) NSNumber* lat;
@property (nonatomic,retain) NSNumber* lng;
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* provider;
@property (nonatomic,retain) NSString* external_id;
@property (nonatomic,retain) NSString* description;
@property (nonatomic,retain) NSString* updated_at;
@property (nonatomic,retain) NSString* created_at;

@end

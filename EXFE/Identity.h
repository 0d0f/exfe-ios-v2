//
//  Identity.h
//  EXFE
//
//  Created by ju huo on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Identity : NSObject{
    NSNumber* _id;
    NSString* _name;
    NSString* _nickname;
    NSString* _provider;
    NSString* _external_id;
    NSString* _external_username;
    NSNumber* _connected_user_id;
    NSString* _bio;
    NSString* _avatar_filename;
    NSString* _avatar_updated_at;
    NSString* _created_at;
    NSString* _updated_at;    
}

@property (nonatomic,retain) NSNumber *id;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *nickname;
@property (nonatomic,retain) NSString *provider;
@property (nonatomic,retain) NSString *external_id;
@property (nonatomic,retain) NSString *external_username;
@property (nonatomic,retain) NSNumber *connected_user_id;
@property (nonatomic,retain) NSString *bio;
@property (nonatomic,retain) NSString *avatar_filename;
@property (nonatomic,retain) NSString *avatar_updated_at;
@property (nonatomic,retain) NSString *created_at;
@property (nonatomic,retain) NSString *updated_at;

@end

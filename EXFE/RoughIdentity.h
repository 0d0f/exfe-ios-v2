//
//  RoughIdentity.h
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kEFRoughIdentityGetIdentityStatusReady = 0,
    kEFRoughIdentityGetIdentityStatusLoading,
    kEFRoughIdentityGetIdentityStatusSuccess,
    kEFRoughIdentityGetIdentityStatusFailure
} EFRoughIdentityGetIdentityStatus;

@class Identity;
@interface RoughIdentity : NSObject
<
NSCopying
>

@property (nonatomic, copy) NSString *externalUsername;
@property (nonatomic, copy) NSString *provider;
@property (nonatomic, copy) NSString *externalID;

@property (nonatomic, copy, readonly) NSString *key;

@property (nonatomic, assign) EFRoughIdentityGetIdentityStatus status;
@property (nonatomic, retain) Identity *identity;

@property (nonatomic, assign, getter = isSelected) BOOL selected;   // Default as NO.

+ (RoughIdentity *)identity;
+ (RoughIdentity *)identityWithDictionary:(NSDictionary *)dictionary;
- (id)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isEqualToRoughIdentity:(RoughIdentity *)anIdentity;
- (NSDictionary *)dictionaryValue;

- (void)getIdentityWithSuccess:(void (^)(Identity *identity))identity failure:(void (^)(NSError *error))failure;

@end

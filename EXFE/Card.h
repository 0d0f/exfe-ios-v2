//
//  Card.h
//  EXFE
//
//  Created by 0day on 13-4-2.
//
//

#import <Foundation/Foundation.h>

@interface CardIdentitiy : NSObject
<
NSCopying
>

@property (nonatomic, copy) NSString *externalID;
@property (nonatomic, copy) NSString *externalUsername;
@property (nonatomic, copy) NSString *provider;

+ (CardIdentitiy *)cardIdentityWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryValue;

- (NSString *)providerImageName;

@end

@interface Card : NSObject
<
NSCopying
>

@property (nonatomic, copy) NSString *cardID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatarURLString;
@property (nonatomic, copy) NSString *bio;
@property (nonatomic, retain) NSArray *identities;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, assign) NSTimeInterval timeStamp;

+ (Card *)cardWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryValue;

- (BOOL)isEqualToCard:(Card *)aCard;

@end

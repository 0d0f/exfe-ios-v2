//
//  EFConfig.h
//  EXFE
//
//  Created by Stony Wang on 13-9-10.
//
//

#import <Foundation/Foundation.h>

#define EFKeyServerScope          @"key.config.server.scope"

#define EFServerKeyPanda          @"panda"
#define EFServerKeyBlack          @"black"
#define EFServerKeyShuady         @"shuady"
#define EFServerScopeINT          @"ZZ"
#define EFServerScopeCN           @"CN"

@interface EFConfig : NSObject

@property (nonatomic, readonly, copy) NSString * server;
@property (nonatomic, readonly, copy) NSString * scope;

@property (nonatomic, readonly, copy) NSString * API_ROOT;
@property (nonatomic, readonly, copy) NSString * IMG_ROOT;
@property (nonatomic, readonly, copy) NSString * OAUTH_ROOT;

+ (instancetype)sharedInstance;

- (BOOL)avalableForScope:(NSString *)scope;
- (NSString *)suggestScope;
- (NSString *)alias:(NSString *)scope;
- (BOOL)sameServerScope:(NSString *)scope;

- (void)saveScope:(NSString *)scope;
- (NSString *)loadScope;
- (void)clearScope;

@end

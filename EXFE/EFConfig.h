//
//  EFConfig.h
//  EXFE
//
//  Created by Stony Wang on 13-9-10.
//
//

#import <Foundation/Foundation.h>

@interface EFConfig : NSObject

@property (nonatomic, readonly, copy) NSString * server;
@property (nonatomic, readonly, copy) NSString * scope;

@property (nonatomic, readonly, copy) NSString * API_ROOT;
@property (nonatomic, readonly, copy) NSString * IMG_ROOT;
@property (nonatomic, readonly, copy) NSString * OAUTH_ROOT;

+ (instancetype)sharedInstance;

- (NSString *)suggestScope;

- (void)saveScope:(NSString *)scope;
- (NSString *)loadScope;
- (void)clearScope;

@end

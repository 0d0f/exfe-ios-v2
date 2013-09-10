//
//  EFConfig.h
//  EXFE
//
//  Created by Stony Wang on 13-9-10.
//
//

#import <Foundation/Foundation.h>

@interface EFConfig : NSObject

@property (nonatomic, readonly, copy) NSString * key;

@property (nonatomic, readonly, copy) NSString * API_ROOT;
@property (nonatomic, readonly, copy) NSString * IMG_ROOT;
@property (nonatomic, readonly, copy) NSString * OAUTH_ROOT;

+ (instancetype)sharedInstance;

@end

//
//  EFAPIServer.h
//  EXFE
//
//  Created by Stony Wang on 13-4-17.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Identity+EXFE.h"

@interface EFAPIServer : NSObject


@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, copy) NSString *user_token;

- (id)init;
+ (EFAPIServer *)sharedInstance;

- (void)getRegFlagBy:(NSString*)identity
and:(Provider)provider
success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end

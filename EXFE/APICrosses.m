//
//  APICross.m
//  EXFE
//
//  Created by ju huo on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "APICrosses.h"
#import "Meta.h"
#import "Cross.h"
#import "Place.h"
#import "Identity.h"
#import "Rsvp.h"
#import "Util.h"
#import "EFAPIServer.h"
#import "EFKit.h"


@implementation APICrosses
static id sharedManager = nil;
//static RKRequestQueue *queue;
//
//
+ (id)sharedManager {
  @synchronized(self)
  {
    if (sharedManager == nil) {
      sharedManager = [[self alloc] init];
//      queue=[RKRequestQueue newRequestQueueWithName:@"crosses"];
    }
  }
  return sharedManager;
}

+ (void)GatherCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    RKObjectManager* manager =[RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"%@crosses/gather?token=%@",API_ROOT,[EFAPIServer sharedInstance].user_token];
    manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    
    RKObjectRequestOperation *operation = [manager appropriateObjectRequestOperationWithObject:cross method:RKRequestMethodPOST path:endpoint parameters:nil];
    
    // warning handler
    [operation setWillMapDeserializedResponseBlock:^id(id object){
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictObject = (NSDictionary *)object;
            NSDictionary *responseDict = [dictObject valueForKey:@"response"];
            if (responseDict) {
                NSNumber *exfeeQuota = [responseDict valueForKey:@"exfee_over_quota"];
                if (exfeeQuota) {
                    EFErrorMessage *errorMessage = [EFErrorMessage errorMessageWithStyle:kEFErrorMessageStyleAlert
                                                                                   title:@"Quota limit exceeded"
                                                                                 message:[NSString stringWithFormat:@"%d people limit on gathering this ·X·. However, we’re glad to eliminate this limit during pilot period in appreciation of your early adaption. Thank you!", [exfeeQuota intValue]]
                                                                             buttonTitle:@"OK"
                                                                     buttonActionHandler:nil];
                    [[EFErrorHandlerCenter defaultCenter] presentErrorMessage:errorMessage];
                }
            }
        }
        
        return object;
    }];
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [manager enqueueObjectRequestOperation:operation];
}

+(void) EditCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  RKObjectManager* manager =[RKObjectManager sharedManager];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@crosses/%u/edit?token=%@",API_ROOT,[cross.cross_id intValue],[EFAPIServer sharedInstance].user_token];
  manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
  manager.requestSerializationMIMEType = RKMIMETypeJSON;
  [manager postObject:cross path:endpoint parameters:nil success:success failure:failure];
}

+(void) LoadCrossWithCrossId:(int)corss_id updatedtime:(NSString*)updatedtime success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{

  if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
      updatedtime=[Util encodeToPercentEscapeString:updatedtime];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@crosses/%u?updated_at=%@&token=%@",API_ROOT,corss_id,updatedtime,[EFAPIServer sharedInstance].user_token];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
}


@end

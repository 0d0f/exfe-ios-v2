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

+(void) GatherCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    RKObjectManager* manager =[RKObjectManager sharedManager];
    NSString *endpoint = [NSString stringWithFormat:@"%@crosses/gather",API_ROOT];
    manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
    manager.requestSerializationMIMEType = RKMIMETypeJSON;
    [manager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
    [manager postObject:cross path:endpoint parameters:nil success:success failure:failure];
}

+(void) EditCross:(Cross*) cross success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{
  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  RKObjectManager* manager =[RKObjectManager sharedManager];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@crosses/%u/edit?token=%@",API_ROOT,[cross.cross_id intValue],app.accesstoken];
  manager.HTTPClient.parameterEncoding= AFJSONParameterEncoding;
  manager.requestSerializationMIMEType = RKMIMETypeJSON;
  [manager.HTTPClient setDefaultHeader:@"token" value:app.accesstoken];
  [manager postObject:cross path:endpoint parameters:nil success:success failure:failure];
}

+(void) LoadCrossWithCrossId:(int)corss_id updatedtime:(NSString*)updatedtime success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure{

  AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
  if(updatedtime!=nil && ![updatedtime isEqualToString:@""])
      updatedtime=[Util encodeToPercentEscapeString:updatedtime];
  
  NSString *endpoint = [NSString stringWithFormat:@"%@crosses/%u?updated_at=%@&token=%@",API_ROOT,corss_id,updatedtime,app.accesstoken];
  [[RKObjectManager sharedManager] getObjectsAtPath:endpoint parameters:nil success:success failure:failure];
}


@end

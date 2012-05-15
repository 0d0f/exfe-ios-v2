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

#define API_V2_ROOT @"http://api.local.exfe.com/v2"

@implementation APICrosses
- (void)getCrossById
{
    
//    RKObjectMapping *metaMapping = [RKObjectMapping mappingForClass:[Meta class]];
//    [metaMapping mapAttributes:@"code", nil];

    RKObjectMapping *crossMapping = [RKObjectMapping mappingForClass:[Cross class]];
    [crossMapping mapKeyPath:@"id" toAttribute:@"id"];
    [crossMapping mapKeyPath:@"id_base62" toAttribute:@"id_base62"];
    [crossMapping mapKeyPath:@"title" toAttribute:@"title"];
    
    
    RKObjectManager* manager = [RKObjectManager managerWithBaseURLString:API_V2_ROOT];

//    NSString *endpoint = @"/crosses/100183?token=98eddc9c0afc48087f722ca1419c8650";                           
    NSString *endpoint = @"/users/131/crosses?updated_at=2012-05-01%2009:40:26&token=98eddc9c0afc48087f722ca1419c8650";

//    [manager.mappingProvider setMapping:metaMapping forKeyPath:@"meta"];
    [manager.mappingProvider setMapping:crossMapping forKeyPath:@"response.crosses"];
    
    [manager loadObjectsAtResourcePath:endpoint delegate:self];
    
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    Cross *cross=[objects objectAtIndex:0];
    NSLog(@"load:%@",cross);
//    UsersLogin *result = [objects objectAtIndex:0];
    
//    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Error!:%@",error);
}
@end

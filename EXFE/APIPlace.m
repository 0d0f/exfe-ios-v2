//
//  APIPlace.m
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import "APIPlace.h"

@implementation APIPlace
static id sharedManager = nil;
//RESTKIT0.2
//static RKRequestQueue *queue;

+ (id)sharedManager {
    @synchronized(self)
    {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
          //RESTKIT0.2
//            queue=[RKRequestQueue newRequestQueueWithName:@"place"];
        }
    }
    return sharedManager;
}

+(void) GetPlaces:(NSString*)keyword lat:(double)lat lng:(double)lng delegate:(id)delegate{
  //RESTKIT0.2
//    RKClient *client = [RKClient sharedClient];
//    
//    NSString *endpoint = [NSString stringWithFormat:@"/maps/getlocation?key=%@&lat=%g&lng=%g",keyword,lat,lng];
//    [client get:endpoint usingBlock:^(RKRequest *request) {
//        request.method=RKRequestMethodGET;
//        request.onDidLoadResponse=^(RKResponse *response){
//        };
//    }
//    ];
  
}
-(void) GetPlacesFromGoogleByTitle:(NSString*) title lat:(double)lat lng:(double)lng delegate:(id)delegate{
  //RESTKIT0.2
//    [queue cancelRequestsWithDelegate:delegate];
//    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
//    RKClient *client=[RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:@"https://maps.googleapis.com"]];
//    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/textsearch/json?query=%@&location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",title,lat,lng,language,GOOGLE_API_KEY];
//    if(lng==0 && lat==0)
//        endpoint =[NSString stringWithFormat:@"/maps/api/place/textsearch/json?query=%@&language=%@&sensor=true&key=%@",title,language,GOOGLE_API_KEY];
//    RKRequest *request=[client get:endpoint delegate:delegate];
//    [queue addRequest:request];
//    [queue start];
}
-(void) GetTopPlaceFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate{
  //RESTKIT0.2
//    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
//    RKClient *client=[RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:@"https://maps.googleapis.com"]];
//    
//    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/search/json?location=%g,%g&radius=100&language=%@&sensor=true&key=%@",lat,lng,language,GOOGLE_API_KEY];
//    [client get:endpoint usingBlock:^(RKRequest *request) {
//        request.method=RKRequestMethodGET;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    NSString *status=[body objectForKey:@"status"];
//                    if(status!=nil &&[status isEqualToString:@"OK"])
//                    {
//                        NSArray *results=[body objectForKey:@"results"] ;
//                        if([results count]>0){
//                            NSDictionary *place = [results objectAtIndex:0];
//                            if([results count]>1)
//                                place = [results objectAtIndex:1];
//                            NSDictionary *dict=[[[NSDictionary alloc] initWithObjectsAndKeys:[place objectForKey:@"name"],@"title",[place objectForKey:@"vicinity"],@"description",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[place objectForKey:@"id"],@"external_id",@"google",@"provider", nil] autorelease];
//                            [(PlaceViewController*)delegate fillTopPlace:dict];
//                        }
//                    }
//                }
//            }
//            else {
//            }
//        };
//        
//    }
//     ];
}
-(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
//RESTKIT0.2
//    RKClient *client=[RKClient sharedClient];
//    [client setBaseURL:[RKURL URLWithBaseURLString:@"https://maps.googleapis.com"]];
//
//    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/search/json?location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",lat,lng,language,GOOGLE_API_KEY];
//    [client get:endpoint usingBlock:^(RKRequest *request) {
//        request.method=RKRequestMethodGET;
//        request.onDidLoadResponse=^(RKResponse *response){
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    NSString *status=[body objectForKey:@"status"];
//                    if(status!=nil &&[status isEqualToString:@"OK"])
//                    {
//                        NSArray *results=[body objectForKey:@"results"] ;
//                        NSMutableArray *local_results=[[NSMutableArray alloc] initWithCapacity:[results count]]  ;//autorelease
//                        for(NSDictionary *place in results)
//                        {
//
//                            NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[place objectForKey:@"name"],@"title",[place objectForKey:@"vicinity"],@"description",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[place objectForKey:@"id"],@"external_id",@"google",@"provider", nil];
//                            [local_results addObject:dict];
//                            [dict release];
//                        }
//                        [(PlaceViewController*)delegate reloadPlaceData:local_results];
//                    }
//                }
//            }
//            else {
//                //Check Response Body to get Data!
//            }
//        };
//
//    }
//    ];
}

@end

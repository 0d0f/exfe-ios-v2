//
//  APIPlace.m
//  EXFE
//
//  Created by huoju on 6/28/12.
//
//

#import "APIPlace.h"

@implementation APIPlace

+(void) GetPlaces:(NSString*)keyword lat:(double)lat lng:(double)lng delegate:(id)delegate{
    RKClient *client = [RKClient sharedClient];
    
    NSString *endpoint = [NSString stringWithFormat:@"/maps/getlocation?key=%@&lat=%g&lng=%g",keyword,lat,lng];
    [client get:endpoint usingBlock:^(RKRequest *request) {
        request.method=RKRequestMethodGET;
        request.onDidLoadResponse=^(RKResponse *response){
            NSLog(@"%@",[response bodyAsString]);
//            if (response.statusCode == 200) {
//                NSDictionary *body=[response.body objectFromJSONData];
//                if([body isKindOfClass:[NSDictionary class]]) {
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code)
//                        if([code intValue]==200) {
//                            NSArray *places=[[body objectForKey:@"places"] retain];
//                            [(PlaceViewController*)delegate reloadPlaceData:places];
//                        }
//                }
//            }
//            else {
//                //Check Response Body to get Data!
//            }
        };
    }
    ];
    
}
+(void) GetPlacesFromGoogleByTitle:(NSString*) title lat:(double)lat lng:(double)lng delegate:(id)delegate{
    
    RKRequestQueue *queue=[RKRequestQueue requestQueueWithName:@"place"];
    [queue cancelRequestsWithDelegate:delegate];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    RKClient *client=[RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:@"https://maps.googleapis.com"]];
    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/textsearch/json?query=%@&location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",title,lat,lng,language,GOOGLE_API_KEY];
    if(lng==0 && lat==0)
        endpoint =[NSString stringWithFormat:@"/maps/api/place/textsearch/json?query=%@&language=%@&sensor=true&key=%@",title,language,GOOGLE_API_KEY];
    RKRequest *request=[client get:endpoint delegate:delegate];
    [queue addRequest:request];
    [queue start];
}

+(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate{
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    RKClient *client=[RKClient sharedClient];
    [client setBaseURL:[RKURL URLWithBaseURLString:@"https://maps.googleapis.com"]];

//    NSString *key=@"AIzaSyCBJcbHO0x87BvSVT-2Sg14PWko-GUN09c";
    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/search/json?location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",lat,lng,language,GOOGLE_API_KEY];
    [client get:endpoint usingBlock:^(RKRequest *request) {
        request.method=RKRequestMethodGET;
        request.onDidLoadResponse=^(RKResponse *response){
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    NSString *status=[body objectForKey:@"status"];
                    if(status!=nil &&[status isEqualToString:@"OK"])
                    {
                        NSArray *results=[body objectForKey:@"results"] ;
                        NSMutableArray *local_results=[[NSMutableArray alloc] initWithCapacity:[results count]]  ;//autorelease
                        for(NSDictionary *place in results)
                        {

                            NSDictionary *dict=[[NSDictionary alloc] initWithObjectsAndKeys:[place objectForKey:@"name"],@"title",[place objectForKey:@"vicinity"],@"description",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"],@"lng",[[[place objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"],@"lat",[place objectForKey:@"id"],@"external_id",@"google",@"provider", nil];
                            [local_results addObject:dict];
                            [dict release];
                        }
                        [(PlaceViewController*)delegate reloadPlaceData:local_results];
                    }
                }
            }
            else {
                //Check Response Body to get Data!
            }
        };

    }
    ];
//    [client release];
}

@end

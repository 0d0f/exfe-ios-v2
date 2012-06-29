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
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
                    if(code)
                        if([code intValue]==200) {
                            NSArray *places=[[body objectForKey:@"places"] retain];
                            [(PlaceViewController*)delegate reloadPlaceData:places];
                        }
                }
            }
            else {
                //Check Response Body to get Data!
            }
        };
    }
    ];
    
}

+(void) GetPlacesFromGoogleNearby:(double)lat lng:(double)lng delegate:(id)delegate{
    RKClient *client = [RKClient clientWithBaseURLString:@"https://maps.googleapis.com"];
    NSString *key=@"AIzaSyCBJcbHO0x87BvSVT-2Sg14PWko-GUN09c";
    NSString *endpoint = [NSString stringWithFormat:@"/maps/api/place/search/json?location=%g,%g&radius=1000&language=%@&sensor=true&key=%@",lat,lng,@"zh",key];
    [client get:endpoint usingBlock:^(RKRequest *request) {
        request.method=RKRequestMethodGET;
        request.onDidLoadResponse=^(RKResponse *response){
            NSLog(@"%@",response.bodyAsString);
            if (response.statusCode == 200) {
                NSDictionary *body=[response.body objectFromJSONData];
                if([body isKindOfClass:[NSDictionary class]]) {
                    NSString *status=[body objectForKey:@"status"];
                    if(status!=nil &&[status isEqualToString:@"OK"])
                    {
                        NSArray *results=[[body objectForKey:@"results"] retain];
                        [(PlaceViewController*)delegate reloadPlaceData:results];
                    }
//                    if(code)
//                        if([code intValue]==200) {
//
////                            NSArray *places=[[body objectForKey:@"places"] retain];
////
//                        }
                }
            }
            else {
                //Check Response Body to get Data!
            }
        };
    }
    ];
    
}

@end

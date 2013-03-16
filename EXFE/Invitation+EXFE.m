//
//  Invitation+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 3/15/13.
//
//

#import "Invitation+EXFE.h"

@implementation Invitation (EXFE)

+ (RsvpCode)getRsvpCode:(NSString*)str{
    if ([@"ACCEPTED" isEqualToString:str]) {
        return kRsvpAccepted;
    } else if ([@"INTERESTED" isEqualToString:str]) {
        return kRsvpInterested;
    } else if ([@"DECLINED" isEqualToString:str]) {
        return kRsvpDeclined;
    } else if ([@"REMOVED" isEqualToString:str]) {
        return kRsvpRmoved;
    } else if ([@"NOTIFICATION" isEqualToString:str]) {
        return kRsvpNotification;
    } else if ([@"IGNORED" isEqualToString:str]) {
        return kRsvpIgnored;
    } else {
        return kRsvpNoResponse;
    }
}

+ (NSString*)getRsvpString:(RsvpCode)code{
    switch (code) {
        case kRsvpAccepted:
            return @"ACCEPTED";
            //break;
        case kRsvpInterested:
            return @"INTERESTED";
            //break;
        case kRsvpDeclined:
            return @"DECLINED";
            //break;
        case kRsvpRmoved:
            return @"REMOVED";
            //break;
        case kRsvpNotification:
            return @"NOTIFICATION";
            //break;
        case kRsvpIgnored:
            return @"IGNORED";
            //break;
        case kRsvpNoResponse:
            //break; //fall through
        default:
            return @"NORESPONSE";
            break;
    }
    
}



@end

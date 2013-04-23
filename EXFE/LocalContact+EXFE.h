//
//  LocalContact+EXFE.h
//  EXFE
//
//  Created by 0day on 13-4-19.
//
//

#import "LocalContact.h"

@interface LocalContact (EXFE)

// phone > facebook > mail > twitter > others
- (NSArray *)roughIdentities;

- (BOOL)hasAnyNotificationIdentity;

@end

//
//  Mapping.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import "Identity.h"

@interface Mapping : NSObject
//+ (RKManagedObjectMapping*) getIdentityMapping;
//+ (RKManagedObjectMapping*) getMetaMapping;
+ (RKObjectMapping*) getIdentitySerializationMapping;

@end

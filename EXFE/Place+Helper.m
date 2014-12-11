//
//  Place+Helper.m
//  EXFE
//
//  Created by Stony Wang on 12-12-28.
//
//

#import "Place+Helper.h"

@implementation Place (Helper)

- (BOOL) isEmpty{
    return  (![self hasTitle] && ![self hasGeo]);
}

- (BOOL) hasTitle{
    return  self.title != nil && self.title.length > 0;
}

- (BOOL) hasDescription{
    return [self hasTitle] && self.description != nil && self.description.length > 0;
}

- (BOOL) hasGeo{
    return self.lat != nil && self.lng != nil && self.lat.length > 0 && self.lng.length > 0;
}

@end

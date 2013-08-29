//
//  NSManagedObject+EXFE.m
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import "NSManagedObject+EXFE.h"

@implementation NSManagedObject (EXFE)

+ (NSString *)entityName {
    return NSStringFromClass([self class]);
}

+ (id)object:(NSManagedObjectContext *)context{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    return [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:context];
}

+ (id)disconnectedEntity:(NSManagedObjectContext *)context{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    return [[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
}
- (void)addToContext:(NSManagedObjectContext *)context {
    [context insertObject:self];
}

@end

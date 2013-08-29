//
//  NSManagedObject+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 13-8-27.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (EXFE)

+ (NSString *)entityName;
+ (id)object:(NSManagedObjectContext *)context;
+ (id)disconnectedEntity:(NSManagedObjectContext *)context;
- (void)addToContext:(NSManagedObjectContext *)context;

@end

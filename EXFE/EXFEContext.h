//
//  EXFEContext.h
//  EXFE
//
//  Created by Stony Wang on 13-6-13.
//
//

#import <CoreData/CoreData.h>

@interface EXFEContext : NSManagedObjectContext


@property (nonatomic, copy,   readonly ) NSString * userPath;

- (id)initWithUserPath:(NSString *)userPath;

@end

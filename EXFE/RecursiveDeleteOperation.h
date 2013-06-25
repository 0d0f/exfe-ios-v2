//
//  RecursiveDeleteOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-6-14.
//
//

#import <Foundation/Foundation.h>

@interface RecursiveDeleteOperation : NSOperation
{
    NSArray *   _paths;
    NSError *   _error;
}

- (id)initWithPaths:(NSArray *)paths;
// Configures the operation with the array of paths to delete.

// properties specified at init time

@property (copy,   readonly ) NSArray *     paths;

// properties that are valid after the operation is finished

@property (copy,   readonly ) NSError *     error;

@end

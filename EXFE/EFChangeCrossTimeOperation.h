//
//  EFChangeCrossTimeOperation.h
//  EXFE
//
//  Created by Stony Wang on 13-9-2.
//
//

#import "EFNetworkOperation.h"

@class CrossTime;
@class Cross;

@interface EFChangeCrossTimeOperation : EFNetworkOperation

@property (nonatomic, strong) NSManagedObjectContext *moc;
@property (nonatomic, strong) NSDate                 *timestamp;
@property (nonatomic, strong) NSNumber               *entityId;
@property (nonatomic, strong) NSEntityDescription    *entityType;

@property (nonatomic, strong) CrossTime              *crossTime;


@end

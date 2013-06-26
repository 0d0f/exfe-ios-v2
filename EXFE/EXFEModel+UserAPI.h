//
//  EXFEModel+UserAPI.h
//  EXFE
//
//  Created by 0day on 13-6-26.
//
//

#import "EXFEModel.h"

@interface EXFEModel (UserAPI)

- (void)loadMe;
- (void)loadUserByUserId:(NSInteger)userId;

@end

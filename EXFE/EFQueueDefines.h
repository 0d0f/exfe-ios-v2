//
//  EFQueueDefines.h
//  EXFE
//
//  Created by 0day on 13-6-18.
//
//

#ifndef EXFE_EFQueueDefines_h
#define EXFE_EFQueueDefines_h

typedef void (^CompleteBlock)(void);

typedef enum {
    kEFIOOperationTypeRead = 0,
    kEFIOOperationTypeWrite,
} EFIOOperationType;

#endif

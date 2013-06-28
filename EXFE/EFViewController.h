//
//  EFViewController.h
//  EXFE
//
//  Created by Stony Wang on 13-6-28.
//
//

#import <UIKit/UIKit.h>
#import "EFModel.h"

@interface EFViewController : UIViewController

@property (nonatomic, assign) EXFEModel * model;

- (id)initWithModel:(EXFEModel*)exfeModel;

@end

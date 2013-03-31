//
//  EXCardCell.h
//  EXFE
//
//  Created by 0day on 13-4-1.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    kEXCardCellPravicyStatePublic,
    kEXCardCellPravicyStatePrivate
} EXCardCellPravicyState;

@class Identity;

@interface EXCardCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *displayIdentityLabel;
@property (retain, nonatomic) IBOutlet UILabel *providerLabel;
@property (retain, nonatomic) IBOutlet UILabel *pravicyLabel;

@property (nonatomic, assign) Identity *identity;
@property (nonatomic, assign) EXCardCellPravicyState pravicyState;

- (id)init;

@end

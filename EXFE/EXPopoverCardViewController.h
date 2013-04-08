//
//  EXPopoverCardViewController.h
//  EXFE
//
//  Created by 0day on 13-4-4.
//
//

#import <UIKit/UIKit.h>

@class Card;

@interface EXPopoverCardViewController : UITableViewController

@property (nonatomic, copy) Card *card;

- (id)initWithCard:(Card *)card;

+ (CGSize)cardSizeWithCard:(Card *)card;

@end

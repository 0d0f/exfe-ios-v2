//
//  ExfeeRsvpCell.h
//  EXFE
//
//  Created by Stony Wang on 3/13/13.
//
//

#import "ABTableViewCell.h"
#import "EXAttributedLabel.h"

@interface ExfeeRsvpCell : ABTableViewCell{
    EXAttributedLabel *main;
    UILabel *alt;
    UILabel *name;
    UILabel *host;
    UIImageView *host_star;
    UIImageView *rsvp_status;
    
    NSString *_NameText;
    BOOL _isHost;
    NSString *_AltText;
    NSAttributedString *_MainText;
    NSString *_RsvpString;
}

@property (nonatomic, copy) NSString *NameText;
@property (nonatomic, assign) BOOL isHost;
@property (nonatomic, copy) NSAttributedString *MainText;
@property (nonatomic, copy) NSString *AltText;
@property (nonatomic, copy) NSString *RsvpString;

@end

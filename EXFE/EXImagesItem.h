//
//  EXImagesItem.h
//  EXFE
//
//  Created by huoju on 8/31/12.
//
//

#import <Foundation/Foundation.h>

@interface EXImagesItem : UIView{
    UIImage *avatar;
    BOOL isHost;
    BOOL isSelected;
    int mates;
    NSString *rsvp_status;
    NSString *name;
}

@property (nonatomic,retain) UIImage *avatar;
@property BOOL isHost;
@property BOOL isSelected;
@property int mates;
@property (nonatomic,retain) NSString *rsvp_status;
@property (nonatomic,retain) NSString *name;

@end

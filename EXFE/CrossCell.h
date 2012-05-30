//
//  CrossCell.h
//  EXFE
//
//  Created by ju huo on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrossCell : UITableViewCell{
    NSString *title;
    UIImage *avatar;
    NSString *time;
    NSString *place; 
    NSDictionary *updated;
}
@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) NSString* place;
@property (nonatomic,retain) UIImage* avatar;
@property (nonatomic,retain) NSDictionary *updated;
@end

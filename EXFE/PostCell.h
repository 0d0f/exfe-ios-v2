//
//  PostCell.h
//  EXFE
//
//  Created by ju huo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"

@interface PostCell : ABTableViewCell{
    NSString *content;
    UIImage *avatar;
    NSString *time;
}
@property (nonatomic,retain) NSString* content;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) UIImage* avatar;

@end

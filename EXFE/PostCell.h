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
    UIImage *background;
    UIImage *separator;
    UIImage *avatarframe;
    int text_height;
}
@property (nonatomic,retain) NSString* content;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) UIImage* avatar;
@property (nonatomic,retain) UIImage* background;
@property (nonatomic,retain) UIImage* separator;
@property (nonatomic,retain) UIImage* avatarframe;
@property int text_height;

#define FONT_SIZE 14.0f
#define AVATAR_LEFT_MERGIN 15.0f
#define AVATAR_WIDTH 25.0f
#define AVATAR_HEIGHT 25.0f

#define CELL_CONTENT_WIDTH 260.0f
#define CELL_CONTENT_MARGIN_TOP 10.0f
#define CELL_CONTENT_MARGIN_BOTTOM 10.0f
#define CELL_CONTENT_MARGIN_LEFT 5.0f
#define CELL_CONTENT_MARGIN_RIGHT 5.0f

@end

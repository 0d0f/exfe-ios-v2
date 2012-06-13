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
    int text_height;
}
@property (nonatomic,retain) NSString* content;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) UIImage* avatar;
@property int text_height;

#define FONT_SIZE 18.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN_TOP 8.0f
#define CELL_CONTENT_MARGIN_BOTTOM 7.0f
#define CELL_CONTENT_MARGIN_LEFT 10.0f
#define CELL_CONTENT_MARGIN_RIGHT 30.0f

@end

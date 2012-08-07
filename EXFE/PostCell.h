//
//  PostCell.h
//  EXFE
//
//  Created by ju huo on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABTableViewCell.h"
#import <CoreText/CoreText.h>

@interface PostCell : ABTableViewCell{
    NSString *content;
    UIImage *avatar;
    NSString *time;
    NSString *relativetime;
    UIImage *background;
    UIImage *separator;
    UIImage *avatarframe;
    float text_height;
    BOOL showtime;
}
@property (nonatomic,retain) NSString* content;
@property (nonatomic,retain) NSString* time;
@property (nonatomic,retain) NSString* relativetime;
@property (nonatomic,retain) UIImage* avatar;
@property (nonatomic,retain) UIImage* background;
@property (nonatomic,retain) UIImage* separator;
@property (nonatomic,retain) UIImage* avatarframe;
@property float text_height;

#define FONT_SIZE 14.0f
#define AVATAR_LEFT_MERGIN 8.0f
#define AVATAR_WIDTH 32.0f
#define AVATAR_HEIGHT 32.0f

#define CELL_CONTENT_WIDTH 260.0f
#define CELL_CONTENT_MARGIN_TOP 8.0f
#define CELL_CONTENT_MARGIN_BOTTOM 12.0f
#define CELL_CONTENT_MARGIN_LEFT 5.0f
#define CELL_CONTENT_MARGIN_RIGHT 5.0f
- (void) setShowTime:(BOOL)show;
- (void) hiddenTime;
- (void) drawString:(CGContextRef) context rect:(CGRect)r;
@end

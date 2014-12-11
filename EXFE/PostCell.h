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
    NSString *identity_name;
    NSString *relativetime;
    UIImage *background;
    UIImage *separator;
    UIImage *avatarframe;
//    float text_height;
    BOOL showtime;
}
@property (nonatomic,strong) NSString* content;
@property (nonatomic,strong) NSString* time;
@property (nonatomic,strong) NSString* relativetime;
@property (nonatomic,strong) UIImage* avatar;
@property (nonatomic,strong) UIImage* background;
@property (nonatomic,strong) UIImage* separator;
@property (nonatomic,strong) UIImage* avatarframe;
@property (nonatomic,strong) NSString* identity_name;
//@property float text_height;

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

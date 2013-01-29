//
//  ImgCache.h
//  exfe
//
//  Created by 霍 炬 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImgCache : NSObject {
    NSString *cachepath;    
}


+ (id)sharedManager;
+ (NSString*) CachePath;
+ (NSString *) md5:(NSString *)str;
+ (NSString *) getImgName:(NSString *)url;
- (UIImage*) getImgFrom:(NSString*)url;
- (UIImage*) getImgFrom:(NSString*)url withSize:(CGSize)size;
- (UIImage*) getImgFromCache:(NSString*)url;
- (UIImage*) getImgFromCache:(NSString*)url withSize:(CGSize)size;

- (UIImage*) checkImgFrom:(NSString*)url;
+ (NSString *) getImgUrl:(NSString*)imgName;

+ (UIImage *) getDefaultImage;
@end

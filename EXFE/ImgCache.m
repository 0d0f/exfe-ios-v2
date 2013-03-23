//
//  ImgCache.m
//  exfe
//
//  Created by 霍 炬 on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImgCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ImgCache

static id sharedManager = nil;
static NSMutableDictionary *imgs;

+ (id)sharedManager {
    @synchronized(self)    
    {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
            imgs = [[NSMutableDictionary alloc]initWithCapacity:50];
            
        }
    }
    return sharedManager;
}
+ (NSString*) CachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documentsDirectory = [paths objectAtIndex:0]; 
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/images"];
    BOOL writedir=[[NSFileManager defaultManager] isWritableFileAtPath:path];
    if(writedir == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *) md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], 
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}
+ (NSString *) getImgName:(NSString *)url
{
    NSString *md5key=[ImgCache md5:url];
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
	NSFileManager *fileManager=[NSFileManager defaultManager];
    
    BOOL success=[fileManager fileExistsAtPath:cachefilename];
    if(!success)
    {
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [data writeToFile:cachefilename atomically:YES];
        
    }
    
    return md5key;
}
- (UIImage*) checkImgFrom:(NSString*)url{
    NSString *md5key=[ImgCache md5:url];
    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
    return imgfromdict;
}
- (UIImage*) getImgFromCache:(NSString*)url withSize:(CGSize)size{
    NSString *md5key=[ImgCache md5:[NSString stringWithFormat:@"%@_%f_%f",url,size.width,size.height]];
//    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
//    if(imgfromdict!=nil)
//        return imgfromdict;
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
    UIImage *img=[UIImage imageWithContentsOfFile:cachefilename];
    return img;
}

- (UIImage*) getImgFromCache:(NSString*)url{
    NSString *md5key=[ImgCache md5:url];
    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
    if(imgfromdict!=nil)
        return imgfromdict;
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
    UIImage *img=[UIImage imageWithContentsOfFile:cachefilename];
    return img;
}

- (UIImage*) getImgFrom:(NSString*)url withSize:(CGSize)size{
    NSString *md5key=[ImgCache md5:[NSString stringWithFormat:@"%@_%f_%f",url,size.width,size.height]];
//    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
//    if(imgfromdict!=nil)
//        return imgfromdict;
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
    UIImage *image=nil;//[UIImage imageWithContentsOfFile:cachefilename];
    if(image==nil)
    {

        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        image = [UIImage imageWithData:data];
        if(image!=nil && ![image isEqual:[NSNull null]]){
            CGFloat scaleFactor = 1.0;
            
            if (image.size.width > size.width || image.size.height > size.height){
                scaleFactor = MAX((size.width / image.size.width), (size.height / image.size.height));
            }
            
            UIGraphicsBeginImageContext(size);
            
            CGRect rect = CGRectMake((size.width / 2 - image.size.width / 2 * scaleFactor),(0 - image.size.height * 198.0f / 495.0f * scaleFactor),image.size.width * scaleFactor,image.size.height * scaleFactor);
            [image drawInRect:rect];
            UIImage *backimg = UIGraphicsGetImageFromCurrentImageContext();
            [UIImageJPEGRepresentation(backimg, 1.0) writeToFile:cachefilename atomically:YES];
            return backimg;
        }

    }
//    if(image!=nil)
//        [imgs setObject:image forKey:md5key];
//    else
//        [imgs setObject:[NSNull null] forKey:md5key];
    return image;
}

- (UIImage*) getImgFrom:(NSString*)url
{
    NSString *md5key=[ImgCache md5:url];
    UIImage* imgfromdict=(UIImage*)[imgs objectForKey:md5key];
    if(imgfromdict!=nil)
        return imgfromdict;
    NSString *cachefilename=[[ImgCache CachePath] stringByAppendingPathComponent:md5key];
    UIImage *img=[UIImage imageWithContentsOfFile:cachefilename];
    if(img==nil)
    {
        NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        img = [UIImage imageWithData:data];
        [data writeToFile:cachefilename atomically:YES];
    }
    
    if(img!=nil)
        [imgs setObject:img forKey:md5key];
    else
        [imgs setObject:[NSNull null] forKey:md5key];
    return img;
    
}

+ (NSString *) getImgUrl:(NSString*)imgName
{
    if([imgName length]<5)
        imgName=@"default.png";
//        return @"";
    if([[imgName substringWithRange:NSMakeRange(0,5)] isEqualToString:@"http:"])
        return imgName;
    
    if([imgName isEqualToString:@"default.png"])
        return [NSString stringWithFormat:@"http://img.exfe.com/web/80_80_%@",imgName];
    else
        return [NSString stringWithFormat:@"http://img.exfe.com/%@/%@/80_80_%@",[imgName substringWithRange:NSMakeRange(0, 1)],[imgName substringWithRange:NSMakeRange(1, 2)],imgName];
}

+ (UIImage *) getDefaultImage{
    return [UIImage imageNamed:@"portrait_default.png"];
}


#pragma mark tools
- (void)fillImageWith:(NSString*)url byDefault:(UIImage*)defImage using:(void(^)(UIImage* image))fill{
    if (url == nil || url.length == 0) {
        fill(defImage);
    } else {
        UIImage *avatarImg=[self getImgFromCache:url];
        if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [self getImgFrom:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                        fill(avatar);
                    }else{
                        fill(defImage);
                    }
                });
            });
            dispatch_release(imgQueue);
        }else{
            fill(avatarImg);
        }
    }
}

- (void)fillImage:(UIImageView*)avatarView with:(NSString*)url byDefault:(UIImage*)defImage
{
    if (url == nil || url.length == 0) {
        avatarView.image = defImage;
    } else {
        UIImage *avatarImg = [self getImgFromCache:url];
        if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [self getImgFrom:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                        avatarView.image = avatar;
                    }else{
                        avatarView.image = defImage;
                    }
                });
            });
            dispatch_release(imgQueue);
            
        }else{
            avatarView.image = avatarImg;
        }
    }
    
}

- (void)fillAvatarWith:(NSString*)url byDefault:(UIImage*)defImage using:(void(^)(UIImage* image))fill{
    if (url == nil || url.length == 0) {
        fill(defImage);
    } else {
        UIImage *avatarImg=[self checkImgFrom:url];
        if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [self getImgFrom:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                        fill(avatar);
                    }else{
                        fill(defImage);
                    }
                });
            });
            dispatch_release(imgQueue);
        }else{
            fill(avatarImg);
        }
    }
}

- (void)fillAvatar:(UIImageView*)avatarView with:(NSString*)url byDefault:(UIImage*)defImage
{
    if (url == nil || url.length == 0) {
        avatarView.image = defImage;
    } else {
        UIImage *avatarImg = [self checkImgFrom:url];
        if(avatarImg == nil || [avatarImg isEqual:[NSNull null]]){
            dispatch_queue_t imgQueue = dispatch_queue_create("fetchimg thread", NULL);
            dispatch_async(imgQueue, ^{
                UIImage *avatar = [self getImgFrom:url];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(avatar != nil && ![avatar isEqual:[NSNull null]]) {
                        avatarView.image = avatar;
                    }else{
                        avatarView.image = defImage;
                    }
                });
            });
            dispatch_release(imgQueue);
            
        }else{
            avatarView.image = avatarImg;
        }
    }
    
}

@end

//
//  UIApplication+EXFE.h
//  EXFE
//
//  Created by Stony Wang on 13-3-29.
//
//

// http://stackoverflow.com/questions/7608632/how-do-i-get-the-current-version-of-my-ios-project-in-code

#import <UIKit/UIKit.h>

@interface UIApplication (EXFE)

@property (nonatomic, strong, readonly) NSString *defaultScheme;

+ (NSString *) appVersion;
+ (BOOL) isNewVersion:(NSString *)checkVersion;
+ (NSString *) build;
+ (NSString *) versionBuild;


@end

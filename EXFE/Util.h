//
//  Util.h
//  EXFE
//
//  Created by ju huo on 5/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



#define FONT_COLOR_100 [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:1]
#define FONT_COLOR_69 [UIColor colorWithRed:69/255.0f green:69/255.0f blue:69/255.0f alpha:1]
#define FONT_COLOR_233 [UIColor colorWithRed:233/255.0f green:233/255.0f blue:233/255.0f alpha:1]
#define FONT_COLOR_FA [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1]
#define FONT_COLOR_CCC [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1]
#define FONT_COLOR_232737 [UIColor colorWithRed:35/255.0f green:39/255.0f blue:55/255.0f alpha:0.9]
#define FONT_COLOR_98 [UIColor colorWithRed:98/255.0f green:132/255.0f blue:159/255.0f alpha:1]
#define FONT_COLOR_88 [UIColor colorWithRed:88/255.0f green:156/255.0f blue:209/255.0f alpha:1]
#define FONT_COLOR_51 [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1]
#define FONT_COLOR_25 [UIColor colorWithRed:25/255.0f green:25/255.0f blue:25/255.0f alpha:1]
#define FONT_COLOR_HL [UIColor colorWithRed:58/255.0f green:110/255.0f blue:165/255.0f alpha:1]
#define FONT_COLOR_250 [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1]

// Color for 255-based integer
#define COLOR255(d) (d/255.0f)
#define COLOR_RGBA(r,g,b,a) colorWithRed:COLOR255(r) green:COLOR255(g) blue:COLOR255(b) alpha:COLOR255(a)
#define COLOR_RGB(r,g,b) colorWithRed:COLOR255(r) green:COLOR255(g) blue:COLOR255(b) alpha:1
#define COLOR_WA(w,a) colorWithWhite:COLOR255(w) alpha:COLOR255(a)
#define COLOR_GR(gray) colorWithWhite:COLOR255(gray) alpha:1

#define COLOR_EXFEE_BLUE          COLOR_RGB(0x37, 0x84,0xD5)

// Color Template
#define COLOR_WHITE               COLOR_RGB(0xFF, 0xFF, 0xFF)
#define COLOR_SNOW                COLOR_RGB(0xFA, 0xFA, 0xFA)
#define COLOR_IRON                COLOR_RGB(0xDD, 0xDD, 0xDD)
#define COLOR_ALUMINUM            COLOR_RGB(0xB2, 0xB2, 0xB2)
#define COLOR_GRAY                COLOR_RGB(0x7F, 0x7F, 0x7F)
#define COLOR_CARBON              COLOR_RGB(0x33, 0x33, 0x33)
#define COLOR_BLACK_19            COLOR_RGB(0x19, 0x19, 0x19)
#define COLOR_BLACK               COLOR_RGB(0x00, 0x00, 0x00)

#define COLOR_BLUE_EXFE           COLOR_RGB(0x3A, 0x6E, 0xA5)
#define COLOR_BLUE_SEA            COLOR_RGB(0x37, 0x84, 0xD5)
#define COLOR_BLUE_LAKE           COLOR_RGB(0x60, 0xAD, 0xFF)
#define COLOR_BLUE_AQUA           COLOR_RGB(0xA9, 0xD3, 0xFF)
#define COLOR_BLUE_NAVY           COLOR_RGB(0x15, 0x33, 0x53)

#define COLOR_RED_EXFE            COLOR_RGB(0xE5, 0x2E, 0x53)
#define COLOR_RED_MEXICAN         COLOR_RGB(0xA3, 0x23, 0x3D)

// Const
#define HEADER_BACKGROUND_WIDTH     (880.0f)
#define HEADER_BACKGFOUND_HEIGHT    (495.0f)
#define HEADER_BACKGROUND_Y_OFFSET  (198.0f)


// Notification Definition
extern NSString *const EXCrossListDidChangeNotification;

#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395

@class EFNetworkOperation;

@interface Util : NSObject

+ (NSDictionary *) keywordDict;

+ (NSString *) getBackgroundLink:(NSString*)imgname;

// Provider and Identity
+ (NSString *) findProvider:(NSString*)external_id __attribute__ ((deprecated));
+ (Provider) candidateProvider:(NSString *)raw;
+ (Provider) matchedProvider:(NSString *)raw;
+ (NSDictionary *) parseIdentityString:(NSString *)raw;
+ (NSDictionary *) parseIdentityString:(NSString *)raw byProvider:(Provider)p;

// PhoneNumber
+ (NSString *) getDeviceCountryCode;
+ (BOOL) isAcceptedPhoneNumber:(NSString*)phonenumber;
+ (NSString *) getTelephoneCountryCode:(NSString*)isocode;
+ (NSString *) getTelephoneCountryCode;
+ (BOOL) isValidPhoneNumber:(NSString*)phonenumber;
+ (NSString *) formatPhoneNumber:(NSString*)phonenumber;

+ (void) showConnectError:(NSError *)err delegate:(id)delegate;
+ (void) handleDefaultBannerTitle:(NSString *)title andMessage:(NSString *)message;
+ (void) handleRetryBannerFor:(EFNetworkOperation *)operation withTitle:(NSString *)title andMessage:(NSString *)message andRetry:(BOOL)retry;
+ (void) handleDefaultRetryBannerFor:(EFNetworkOperation *)operation withError:(NSError *)error;

+ (void) signout;

+ (CGRect) expandRect:(CGRect)rect;
+ (CGRect) expandRect:(CGRect)rect1 with:(CGRect)rect2;
+ (CGRect) expandRect:(CGRect)rect1 with:(CGRect)rect2  with:(CGRect)rect3;


+ (void)checkUpdate;

+ (int) daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;

// URL query param tool: XQueryComponents.h
+ (NSString *) concatenateQuery:(NSDictionary *)parameters __attribute__ ((deprecated));
+ (NSDictionary *) splitQuery:(NSString *)query __attribute__ ((deprecated)) ;
+ (NSString *) decodeFromPercentEscapeString:(NSString *)string __attribute__ ((deprecated)) ;
+ (NSString *) encodeToPercentEscapeString:(NSString *)string __attribute__ ((deprecated));
+ (NSString *) EFPercentEscapedQueryStringPairMemberFromString:(NSString *)string __attribute__ ((deprecated));

@end


//
//  EFKeys.h
//  EXFE
//
//  Created by 0day on 13-5-15.
//
//

#ifndef EXFE_EFKeys_h
#define EXFE_EFKeys_h

/**
 * DB version && name
 */
#define APP_DB_VERSION 215

/**
 * Flurry key
 */
#define kFlurryKey  @"8R2R8KZG35DK6S6MDHGS"

/**
 * Weixin AppId
 */
#define kWeixinAppID    @"wxead9dbbbfe812a82"

/**
 * Google API Key
 */
#define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"

/**
 * Server && Twitter key && Google key
 */
#ifdef DEBUG
    #ifdef WWW
        #define kTWConsumerKey @"oGzqJNr6loHEsZOsIHTQ7w"
        #define kTWConsumerSecret @"1q54ZzPppYc4kMWZEQi5dHKtSVVUFWPMLLQWeTOu90"
    #elif defined LOCAL
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #elif (defined PANDA) || (defined PILOT)
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #else
    // DEV
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #endif  // #ifdef WWW
#else
// WWW
    #define kTWConsumerKey @"oGzqJNr6loHEsZOsIHTQ7w"
    #define kTWConsumerSecret @"1q54ZzPppYc4kMWZEQi5dHKtSVVUFWPMLLQWeTOu90"
#endif  // #ifdef DEBUG

#endif  // #ifndef EXFE_EFKeys_h
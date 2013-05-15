//
//  EFConfig.h
//  EXFE
//
//  Created by 0day on 13-5-15.
//
//

#ifndef EXFE_EFConfig_h
#define EXFE_EFConfig_h

/**
 * DB version && name
 */
#define APP_DB_VERSION 208
#define DBNAME @"exfe_v2_8.sqlite"

/**
 * Flurry key
 */
#define kFlurryKey  @"8R2R8KZG35DK6S6MDHGS"

/**
 * Server && Twitter key && Google key
 */
#ifdef DEBUG
    #ifdef WWW
        #define API_ROOT @"https://api.exfe.com/v2/"
        #define IMG_ROOT @"https://exfe.com/static/img"
        #define EXFE_OAUTH_LINK @"https://exfe.com/OAuth"
        #define kTWConsumerKey @"oGzqJNr6loHEsZOsIHTQ7w"
        #define kTWConsumerSecret @"1q54ZzPppYc4kMWZEQi5dHKtSVVUFWPMLLQWeTOu90"
    #elif defined LOCAL
        #define API_ROOT @"http://api.local.exfe.com/v2/"
        #define IMG_ROOT @"http://local.exfe.com/static/img"
        #define EXFE_OAUTH_LINK @"http://local.exfe.com/OAuth"
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #elif (defined PANDA) || (defined PILOT)
        #define API_ROOT @"http://api.panda.0d0f.com/v2/"
        #define IMG_ROOT @"http://panda.0d0f.com/static/img"
        #define EXFE_OAUTH_LINK @"http://panda.0d0f.com/oAuth"
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #else
    // DEV
        #define API_ROOT @"http://api.0d0f.com/v2/"
        #define IMG_ROOT @"http://0d0f.com/static/img"
        #define EXFE_OAUTH_LINK @"http://0d0f.com/OAuth"
        #define kTWConsumerKey @"VC3OxLBNSGPLOZ2zkgisA"
        #define kTWConsumerSecret @"Lg6b5eHdPLFPsy4pI2aXPn6qEX6oxTwPyS0rr2g4A"
    #endif  // #ifdef WWW
    #define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
#else
// WWW
    #define API_ROOT @"https://api.exfe.com/v2/"
    #define IMG_ROOT @"https://exfe.com/static/img"
    #define EXFE_OAUTH_LINK @"https://exfe.com/OAuth"
    #define GOOGLE_API_KEY @"AIzaSyDTc7JJomGg5SW7Zn7lTN0N6mqAI9T3tFg"
    #define kTWConsumerKey @"oGzqJNr6loHEsZOsIHTQ7w"
    #define kTWConsumerSecret @"1q54ZzPppYc4kMWZEQi5dHKtSVVUFWPMLLQWeTOu90"
#endif  // #ifdef DEBUG

#endif  // #ifndef EXFE_EFConfig_h
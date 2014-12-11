//
//  CTUtil.h
//  EXFE
//
//  Created by huoju on 8/8/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
@interface CTUtil : NSObject
+ (CGSize) CTSizeOfString:(NSMutableAttributedString*)attributedString minLineHeight:(float) minheight linespacing:(float)linespaceing constraint:(CGSize)constraint;
@end

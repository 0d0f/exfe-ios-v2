//
//  EXQuoteView.h
//  BubbleTextField
//
//  Created by huoju on 8/17/12.
//  Copyright (c) 2012 huoju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface EXQuoteView : UIView{
    int cornerRadius;
    int arrowHeight;
    int arrowleft;
    BOOL gradientcolors;
}
@property int cornerRadius;
@property int arrowHeight;
@property int arrowleft;
@property BOOL gradientcolors;

@end

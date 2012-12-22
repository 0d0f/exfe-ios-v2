//
//  CustomAttributedTextView.h
//  EXFE
//
//  Created by huoju on 12/18/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CustomAttributedTextView : UIView{
        NSAttributedString *text;
}

@property (nonatomic,retain) NSAttributedString* text;

@end

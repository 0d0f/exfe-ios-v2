//
//  EXAttributedLabel.h
//  EXFE
//
//  Created by huoju on 8/29/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface EXAttributedLabel : UIView{
    NSAttributedString *attributedText;
}
@property (nonatomic,retain) NSAttributedString *attributedText;
@end

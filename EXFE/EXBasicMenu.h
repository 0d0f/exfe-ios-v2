//
//  EXBasicMenu.h
//  EXFE
//
//  Created by Stony Wang on 13-3-20.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EXMenuTextStyle){
    kMenuTextStyleNormal,
    kMenuTextStyleHighlight,
    kMenuTextStyleWarning,
    kMenuTextStyleAction,
    kMenuTextStyleLowlight
};

@class EXBasicMenu;

@protocol EXBasicMenuDelegate <NSObject>

@optional
- (void)basicMenu:(EXBasicMenu*)menu clickHeader:(UIView*)headView;
- (void)basicMenu:(EXBasicMenu*)menu clickFooter:(UIView*)footView;
- (void)basicMenu:(EXBasicMenu*)menu didSelectRowAtIndexPath:(NSNumber *)index;

@end

@interface EXBasicMenu : UIView{
    
}

@property (nonatomic, assign) id<EXBasicMenuDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andContent:(NSDictionary*)data;
- (void)setContent:(NSDictionary*)data;
@end

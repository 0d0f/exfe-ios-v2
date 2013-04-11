//
//  EXMenu.h
//  EXFE
//
//  Created by Stony Wang on 3/19/13.
//
//

// TODO unfinished

#import <UIKit/UIKit.h>

@class EXMenu;

typedef NS_ENUM(NSInteger, LayoutDirection) {
    Horizontal,
    Vertical
};

@protocol EXMenuDelegate <NSObject>

@optional
- (void)menu:(EXMenu*)menu clickHeader:(UIView*)headView;
- (void)menu:(EXMenu*)menu clickFooter:(UIView*)footView;
- (void)menu:(EXMenu*)menu didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol EXMenuDatasouce <NSObject>
- (NSInteger)numberOfRowsInMenu:(EXMenu*)menu;
- (UIView *)menu:(EXMenu*)menu cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (UIView *) viewForHeaderInMenu:(EXMenu*)menu;
- (UIView *) viewForFooterInMenu:(EXMenu*)menu;

@end

@interface EXMenu : UIView{
    
}

@property (nonatomic, assign) LayoutDirection direction;
@property (nonatomic, assign) id<EXMenuDelegate> delegate;
@property (nonatomic, assign) id<EXMenuDatasouce> datasource;

@end

//
//  EXTabWidget.h
//  EXFE
//
//  Created by Stony Wang on 13-3-1.
//
//

#import <UIKit/UIKit.h>

@protocol EXTabWidgetDelegate<NSObject>

- (void)widgetClick:(id)tab withButton:(id)widget;
- (void)updateLayout:(id)sender animationWithParam:(NSDictionary*)param;

@end

@interface EXTabWidgetItem : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, assign) NSUInteger *itemId;
@property (nonatomic, assign) NSString *content;
@property (nonatomic, assign) BOOL highlighted;

@end

@interface EXTabWidget : UIView{
    NSUInteger currentIndex;
    NSUInteger total;
    NSArray* notifications;
    NSArray* hiddens;
    
    NSUInteger gravity;
    
    BOOL _enable;
    NSUInteger _stage;
}

@property (nonatomic, retain) id<EXTabWidgetDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withImages:(NSArray*)imgs current:(NSInteger)index;
- (void)switchTo:(NSUInteger)idx animated:(BOOL)animated;

@end

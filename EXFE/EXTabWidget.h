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

@interface EXTabWidget : UIView{
    NSUInteger currentIndex;
    NSArray* notifications;
    NSArray* hiddens;
    
    NSUInteger gravity;
    
    BOOL _enable;
}

@property (nonatomic, retain) id<EXTabWidgetDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withImages:(NSArray*)imgs current:(NSInteger)index;

@end

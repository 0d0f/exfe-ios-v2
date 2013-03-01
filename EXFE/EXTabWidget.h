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
    NSArray* buttons;
    
    NSUInteger currentIndex;
    NSArray* notifications;
    NSArray* hiddens;
    
    NSUInteger gravity;
}

@property (nonatomic, retain) id<EXTabWidgetDelegate> delegate;

@end

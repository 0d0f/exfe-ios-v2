//
//  EXSpinView.m
//  EXFE
//
//  Created by huoju on 9/9/12.
//
//

#import "EXSpinView.h"

@interface EXSpinView ()
@property (nonatomic, retain) UIActivityIndicatorView   *activityIndicatorView;
@property (nonatomic, retain) UIImageView               *imageView;
@end

@implementation EXSpinView

- (id)initWithPoint:(CGPoint)point size:(int)size style:(EXSpinViewStyle)style {
    NSParameterAssert(style >= kEXSpinViewStyleSystem && style <= kEXSpinViewStyleEXFE);
    
    self = [super initWithFrame:CGRectMake(point.x, point.y, size, size)];
    if (self) {
        _style = style;
        
        if (kEXSpinViewStyleSystem == style) {
            self.activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithFrame:self.bounds] autorelease];
            
            [self addSubview:self.activityIndicatorView];
        } else {
            self.imageView = [[[UIImageView alloc] initWithFrame:self.bounds] autorelease];
            [self addSubview:self.imageView];
            
            if (size == 18) {
                self.imageView.animationImages = [NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"spin_36_0.png"],
                                        [UIImage imageNamed:@"spin_36_1.png"],
                                        [UIImage imageNamed:@"spin_36_2.png"],
                                        [UIImage imageNamed:@"spin_36_3.png"], nil];
            } else if (size == 40) {
                self.imageView.animationImages = [NSArray arrayWithObjects:
                                        [UIImage imageNamed:@"spin_80_0.png"],
                                        [UIImage imageNamed:@"spin_80_1.png"],
                                        [UIImage imageNamed:@"spin_80_2.png"],
                                        [UIImage imageNamed:@"spin_80_3.png"], nil];
            }
            
            self.imageView.animationDuration = 1.5f;
            self.imageView.animationRepeatCount = 0;
        }
    }
    
    return self;
}

- (id)initWithPoint:(CGPoint)point size:(int)size {
    return [self initWithPoint:point size:size style:kEXSpinViewStyleSystem];
}

- (void)dealloc {
    [_activityIndicatorView release];
    [_imageView release];
    [super dealloc];
}

- (void)startAnimating {
    if (kEXSpinViewStyleSystem == self.style) {
        [self.activityIndicatorView startAnimating];
    } else {
        [self.imageView startAnimating];
    }
}

- (void)stopAnimating {
    if (kEXSpinViewStyleSystem == self.style) {
        [self.activityIndicatorView stopAnimating];
    } else {
        [self.imageView stopAnimating];
    }
}

@end

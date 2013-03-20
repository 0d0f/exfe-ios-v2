//
//  EXBasicMenu.m
//  EXFE
//
//  Created by Stony Wang on 13-3-20.
//
//

#import "EXBasicMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"



@implementation EXBasicMenu

- (id)initWithFrame:(CGRect)frame andContent:(NSDictionary*)data
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor COLOR_WA(51, 245)];
        [self setContent:data];
    }
    return self;
}

- (void)setContent:(NSDictionary*)data
{
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    
    NSUInteger extra = 0;
    CGFloat startY = 0;
    if (data) {
        NSString *headerText = [data objectForKey:@"header"];
        if (headerText) {
            UIView *responseview = [[UIView alloc] initWithFrame:CGRectMake(0, startY, CGRectGetWidth(self.bounds), 20)];
            responseview.backgroundColor = [UIColor COLOR_WA(76, 245)];
            
            UILabel *responselabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, CGRectGetWidth(responseview.bounds) - 10, 16)];
            responselabel.text = headerText;
            responselabel.backgroundColor = [UIColor clearColor];
            responselabel.textColor = [UIColor COLOR_WA(250, 255)];
            responselabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
            
            [responseview addSubview:responselabel];
            [responselabel release];
            [self addSubview:responseview];
            [responseview release];
            startY += CGRectGetHeight(responseview.bounds);
            extra ++;
        }
        NSString *footerText = [data objectForKey:@"footer"];
        if (footerText) {
            extra ++;
        }
        
        NSUInteger itemCount = data.count - extra;
        for (NSUInteger i = 0; i < itemCount; i ++) {
            NSString *key = [NSString stringWithFormat:@"item%i", i];
            NSDictionary* dict = [data objectForKey:key];
            if (dict) {
                NSString *main = [dict objectForKey:@"main"];
                NSString *alt = [dict objectForKey:@"alt"];
                EXMenuTextStyle style = [EXBasicMenu getTextStyleFromString:[dict objectForKey:@"style"]];
                if (alt){
                    // unfinished
                }else{
                    UIButton *btnaccepted=[UIButton buttonWithType:UIButtonTypeCustom];
                    btnaccepted.frame = CGRectMake(0, startY, CGRectGetWidth(self.bounds), 44);
                    [btnaccepted setTitle:main forState:UIControlStateNormal];
                    btnaccepted.tag = i;
                    
                    switch (style) {
                        case kMenuTextStyleHighlight: //white, bold
                            [btnaccepted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            btnaccepted.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
                            break;
                        case kMenuTextStyleWarning: //red
                            [btnaccepted setTitleColor:[UIColor COLOR_RGB(229, 46,83)] forState:UIControlStateNormal];
                            btnaccepted.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                            break;
                        case kMenuTextStyleAction: //blue
                            [btnaccepted setTitleColor:[UIColor COLOR_RGB(96, 173,155)] forState:UIControlStateNormal];
                            btnaccepted.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                            break;
                        case kMenuTextStyleLowlight: //grey
                            [btnaccepted setTitleColor:[UIColor COLOR_WA(127, 255)] forState:UIControlStateNormal];
                            btnaccepted.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                            break;
                        case kMenuTextStyleNormal: //
                        default:
                            [btnaccepted setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            btnaccepted.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
                            break;
                    }
                    
                    
                    
                    btnaccepted.titleLabel.textAlignment = NSTextAlignmentLeft;
                    btnaccepted.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                    btnaccepted.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
                    [btnaccepted addTarget:self action:@selector(clickItem:) forControlEvents:UIControlEventTouchUpInside];
                    
                    CALayer *bottomBorder = [CALayer layer];
                    bottomBorder.borderColor = [UIColor darkGrayColor].CGColor;
                    bottomBorder.borderWidth = 1;
                    bottomBorder.frame = CGRectMake(0, btnaccepted.frame.size.height-1,btnaccepted.frame.size.width , 1);
                    [btnaccepted.layer addSublayer:bottomBorder];
                    
                    [self addSubview:btnaccepted];
                    startY += 44;
                }
                
            }
        }
        
        
        if (footerText) {
            UIView *responseview = [[UIView alloc] initWithFrame:CGRectMake(0, startY, CGRectGetWidth(self.bounds), 20)];
            responseview.backgroundColor = [UIColor COLOR_WA(76, 245)];
            
            UILabel *responselabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, CGRectGetWidth(responseview.bounds) - 10, 16)];
            responselabel.text = footerText;
            responselabel.backgroundColor = [UIColor clearColor];
            responselabel.textColor = [UIColor COLOR_WA(250, 255)];
            responselabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
            
            [responseview addSubview:responselabel];
            [responselabel release];
            [self addSubview:responseview];
            [responseview release];
            startY += CGRectGetHeight(responseview.bounds);
        }
    }
}

- (void)clickItem:(id)sender
{
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(basicMenu:didSelectRowAtIndexPath:)]) {
            UIView *v = sender;
            NSNumber * num = [NSNumber numberWithInteger:v.tag];
            [_delegate performSelector:@selector(basicMenu:didSelectRowAtIndexPath:) withObject:self withObject:num];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

+ (EXMenuTextStyle)getTextStyleFromString:(NSString*)styleString{
    if ([@"Highlight" isEqualToString:styleString]) {
        return kMenuTextStyleHighlight;
    } else if ([@"Warning" isEqualToString:styleString]) {
        return kMenuTextStyleWarning;
    } else if ([@"Action" isEqualToString:styleString]) {
        return kMenuTextStyleAction;
    } else if ([@"Lowlight" isEqualToString:styleString]) {
        return kMenuTextStyleLowlight;
    } else {
        return kMenuTextStyleNormal;
    }
}


@end

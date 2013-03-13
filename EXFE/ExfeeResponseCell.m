//
//  ExfeeResponseCell.m
//  EXFE
//
//  Created by Stony Wang on 3/12/13.
//
//

#import "ExfeeResponseCell.h"

@implementation ExfeeResponseCell
@synthesize delegate = _delegate;

-(Identity *)getIdentity
{
    return _identity;
}

-(void)setIdentity:(Identity *)identity
{
    if (identity != _identity)
    {
        [_identity release];
        _identity = [identity retain];
        [self setNeedsDisplay];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        // Initialization code
        providerRect = CGRectMake(25, 3, 18, 18);
        verifyHint = CGRectMake(50, 3, 18, 18);
        displayNameRect = CGRectMake(50, 3, 320 - 75, 18);
        displayNameRect2 = CGRectMake(75, 3, 320 - 100, 18);
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//- (void)layoutSubviews
//{
//	CGRect b = [self bounds];
//	[contentView setFrame:b];
//    
//    
//    [super layoutSubviews];
//}

- (void)drawContentView:(CGRect)rect
{
	// subclasses should implement this
    if (_identity) {
        
        UIImage* provider_hint = nil;
        if([@"facebook" isEqualToString:_identity.provider]){
            provider_hint = [UIImage imageNamed:@"identity_facebook_18_grey.png"];
        }else if ([@"twitter" isEqualToString:_identity.provider]){
            provider_hint = [UIImage imageNamed:@"identity_twitter_18_grey.png"];
        }
        if (provider_hint) {
            [provider_hint drawInRect:providerRect];
        }
        
        
        
        [[UIColor redColor] set];
        UIRectFill(displayNameRect);
    }
    
}

@end

#import "CustomStatusBar.h"

@implementation CustomStatusBar

-(id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		// Place the window on the correct level & position
		self.windowLevel = UIWindowLevelStatusBar + 1.0f;
		self.frame = [UIApplication sharedApplication].statusBarFrame;
		// Create an image view with an image to make it look like the standard grey status bar
//		UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
//		backgroundImageView.image = [[UIImage imageNamed:@"toolbar_bg.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:0];
//		[self addSubview:backgroundImageView];
//		[backgroundImageView release];
        UIView *back=[[UIView alloc] initWithFrame:self.frame];
        back.backgroundColor=[UIColor clearColor];
        [self addSubview:back];
        [back release];
//		_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//		_indicator.frame = (CGRect){.origin.x = 2.0f, .origin.y = 3.0f, .size.width = self.frame.size.height - 6, .size.height = self.frame.size.height - 6};
//		_indicator.hidesWhenStopped = YES;
//		[self addSubview:_indicator];
		
		_statusLabel = [[UILabel alloc] initWithFrame:self.frame];
        _statusLabel.textAlignment=UITextAlignmentRight;
		_statusLabel.backgroundColor = [UIColor blackColor];
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.font = [UIFont boldSystemFontOfSize:10.0f];
		[self addSubview:_statusLabel];
	}
	return self;
}

-(void)dealloc
{
	[_statusLabel release];
//	[_indicator release];
	[super dealloc];
}

-(void)showWithStatusMessage:(NSString*)msg
{
	if (!msg)
		return;
    CGSize size=[msg sizeWithFont:_statusLabel.font constrainedToSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
	_statusLabel.text = msg;
    
    [_statusLabel setFrame:CGRectMake(self.frame.size.width-size.width, _statusLabel.frame.origin.y, size.width, _statusLabel.frame.size.height)];
//	[_indicator startAnimating];
	self.hidden = NO;
}

-(void)hide
{
//	[_indicator stopAnimating];
	self.hidden = YES;
}
@end
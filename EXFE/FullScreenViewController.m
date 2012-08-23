//
//  FullScreenViewController.m
//  EXFE
//
//  Created by huoju on 8/22/12.
//
//

#import "FullScreenViewController.h"

@interface FullScreenViewController ()

@end

@implementation FullScreenViewController
@synthesize image;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.backgroundColor=[UIColor blackColor];
    imageview=[[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:imageview];
    if(image!=nil){
        imageview.image=image;
        CGRect full=[UIScreen mainScreen].bounds;
        float x=(full.size.width-image.size.width)/2;
        float y=(full.size.height-image.size.height)/2;
        x=MAX(0,x);
        y=MAX(0,y);
        [imageview setFrame:CGRectMake(x, y, image.size.width, image.size.height)];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchesBegan:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];


    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [imageview release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc
{
	[super dealloc];
    [self.view release];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self dismissModalViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

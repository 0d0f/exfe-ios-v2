//
//  CrossDetailViewController.m
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import "CrossDetailViewController.h"


#define MAIN_TEXT_HIEGHT                 (21)
#define ALTERNATIVE_TEXT_HIEGHT          (15)
#define LARGE_SLOT                       (16)
#define SMALL_SLOT                      (5)

#define DECTOR_HEIGHT                    (88)
#define DECTOR_HEIGHT_EXTRA              (LARGE_SLOT)
#define DECTOR_MARGIN                    (SMALL_SLOT)
#define OVERLAP                          (0)
#define CONTAINER_TOP_MARGIN             (DECTOR_HEIGHT - OVERLAP)
#define CONTAINER_TOP_PADDING            (DECTOR_HEIGHT_EXTRA + DECTOR_MARGIN + OVERLAP)
#define CONTAINER_VERTICAL_PADDING       (8)
#define DESC_BOTTOM_MARGIN               (LARGE_SLOT)
#define EXFEE_HORIZON_PADDING            (SMAILL_SLOT)
#define EXFEE_HEIGHT                     (50)
#define EXFEE_BOTTOM_MARGIN              (LARGE_SLOT - SMALL_SLOT)
#define TIME_RELATIVE_HEIGHT             (MAIN_TEXT_HIEGHT)
#define TIME_RELATIVE_BOTTOM_MARGIN      (SMALL_SLOT)
#define TIME_ABSOLUTE_HEIGHT             (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_ABSOLUTE_RIGHT_MARGIN       (SMALL_SLOT)
#define TIME_ZONE_HEIGHT                 (ALTERNATIVE_TEXT_HIEGHT)
#define TIME_BOTTOM_MARGIN               (LARGE_SLOT)
#define PLACE_TITLE_HEIGHT               (MAIN_TEXT_HIEGHT)
#define PLACE_TITLE_BOTTOM_MARGIN        (SMALL_SLOT)
#define PLACE_DESC_HEIGHT                (ALTERNATIVE_TEXT_HIEGHT * 4)
#define PLACE_DESC_BOTTOM_MARGIN         (LARGE_SLOT)

@interface CrossDetailViewController ()

@end

@implementation CrossDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self initUI];
    }
    return self;
}

- (void)initUI{
   
    CGRect f = self.view.frame;
    CGRect c = CGRectMake(f.origin.x, f.origin.y + CONTAINER_TOP_MARGIN, f.size.width, f.size.height - f.origin.y - CONTAINER_TOP_MARGIN);
    container = [[UIScrollView alloc] initWithFrame:c];
    {
        
        int left = CONTAINER_VERTICAL_PADDING;
        descView = [[UITextView alloc] initWithFrame:CGRectMake(left, CONTAINER_TOP_PADDING, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, 40)];
        descView.delegate = self;
        descView.backgroundColor = [UIColor brownColor];
        [container addSubview:descView];
        //[descView release];
        
        int line = 2;
        exfee_root = [[UIView alloc]initWithFrame:CGRectMake(left, descView.frame.origin.y + descView.frame.size.height + DESC_BOTTOM_MARGIN, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, 60 * line)];
        exfee_root.backgroundColor = [UIColor redColor];
        [container addSubview:exfee_root];
        //[exfee_root release];
        
        timeRelView = [[UITextField alloc] initWithFrame:CGRectMake(left, exfee_root.frame.origin.y + exfee_root.frame.size.height + EXFEE_BOTTOM_MARGIN, c.size.width -  CONTAINER_VERTICAL_PADDING * 2, TIME_RELATIVE_HEIGHT)];
        timeRelView.backgroundColor = [UIColor brownColor];
        [container addSubview:timeRelView];
        //[timeRelView release];
        
        timeAbsView= [[UITextField alloc] initWithFrame:CGRectMake(left, timeRelView.frame.origin.y + timeRelView.frame.size.height + TIME_RELATIVE_BOTTOM_MARGIN, c.size.width /2 -  CONTAINER_VERTICAL_PADDING, TIME_ABSOLUTE_HEIGHT)];
        timeAbsView.backgroundColor = [UIColor redColor];
        [container addSubview:timeAbsView];
        //[timeAbsView release];
        
        timeZoneView= [[UITextField alloc] initWithFrame:CGRectMake(left + timeAbsView.frame.size.width + TIME_ABSOLUTE_RIGHT_MARGIN, timeAbsView.frame.origin.y, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 - timeAbsView.frame.size.width  - TIME_ABSOLUTE_RIGHT_MARGIN , TIME_ZONE_HEIGHT)];
        timeZoneView.backgroundColor = [UIColor greenColor];
        [container addSubview:timeZoneView];
        //[timeZoneView release];
        
        placeTitleView= [[UITextView alloc] initWithFrame:CGRectMake(left, timeAbsView.frame.origin.y + timeAbsView.frame.size.height + TIME_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_TITLE_HEIGHT)];
        placeTitleView.backgroundColor = [UIColor brownColor];
        [container addSubview:placeTitleView];
        //[placeTitleView release];
        
        placeDescView= [[UITextView alloc] initWithFrame:CGRectMake(left, placeTitleView.frame.origin.y + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN, c.size.width  -  CONTAINER_VERTICAL_PADDING * 2 , PLACE_DESC_HEIGHT)];
        placeDescView.backgroundColor = [UIColor brownColor];
        [container addSubview:placeDescView];
        //[placeDescView release];
        
        
        int a = CGRectGetHeight([UIScreen mainScreen].applicationFrame) ;
        int b = (placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN + placeTitleView.frame.size.height + PLACE_TITLE_BOTTOM_MARGIN + TIME_BOTTOM_MARGIN + c.origin.y + OVERLAP + DECTOR_HEIGHT_EXTRA);
        mapView = [[UIImageView alloc] initWithFrame:CGRectMake(0, placeDescView.frame.origin.y + placeDescView.frame.size.height + PLACE_DESC_BOTTOM_MARGIN, c.size.width  , a - b)];
        mapView.backgroundColor = [UIColor lightGrayColor];
        [container addSubview:mapView];
        //[mapView release];
        
        CGSize s = container.contentSize;
        if (mapView.hidden){
            s.height = container.frame.origin.y + placeDescView.frame.origin.y + placeDescView.frame.size.height;
        }else{
            s.height = container.frame.origin.y + mapView.frame.origin.y + mapView.frame.size.height;
        }
        container.contentSize = s;
        
    }
    container.backgroundColor = [UIColor blueColor];
    [self.view addSubview:container];
    [container release];
    
    dectorView = [[EXCurveImageView alloc] initWithFrame:CGRectMake(f.origin.x, f.origin.y, f.size.width, DECTOR_HEIGHT + DECTOR_HEIGHT_EXTRA) withCurveFrame:CGRectMake(f.origin.x + f.size.width / 2,  f.origin.y +  DECTOR_HEIGHT, 20, DECTOR_HEIGHT_EXTRA) ];
    dectorView.backgroundColor = [UIColor colorWithWhite:1 alpha:0x77/255.0f];
    dectorView.image = [UIImage imageNamed:@"iTunesArtwork.png"];
    [self.view addSubview:dectorView];
    [descView release];
    
}

- (void)relayoutUI{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [descView setText:@"agefaegefjeaiojgieoafjieoa;pgjieoa;gjvieaow;gjiewaofpjeiawop;fjeiwaopjgiewoapfjieawopjgieowapjfiewao"];
    
}

- (void)dealloc {
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    CGRect frame = textView.frame;
    frame.size.height = [textView contentSize].height;
    textView.frame = frame;
    
}

@end

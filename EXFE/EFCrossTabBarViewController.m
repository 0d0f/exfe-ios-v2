//
//  EFCrossTabBarViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-8-26.
//
//

#import "EFCrossTabBarViewController.h"
#import "Cross.h"
#import "Util.h"
#import "EFKit.h"

@interface EFCrossTabBarViewController ()

@end

@implementation EFCrossTabBarViewController
{}
#pragma mark Getter/Setter

#pragma mark Lifecycle
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
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Update UI Views
- (void)refreshUI
{
    if (self.cross) {
        [self fillHead:self.cross];
    }
}

- (void)fillHead:(Cross *)cross
{
    if (!cross) {
        return;
    }
    
    self.title = cross.title;
    
    // Fetch background image
    BOOL flag = NO;
    for(NSDictionary *widget in cross.widget) {
        if([[widget objectForKey:@"type"] isEqualToString:@"Background"]) {
            NSString* url = [widget objectForKey:@"image"];
            
            if (url && url.length > 0) {
                NSString *imgurl = [Util getBackgroundLink:[widget objectForKey:@"image"]];
                
                if (!imgurl) {
                    self.tabBar.backgroundImage = [UIImage imageNamed:@"x_titlebg_default.jpg"];
                } else {
                    [[EFDataManager imageManager] loadImageForView:self.tabBar
                                                  setImageSelector:@selector(setBackgroundImage:)
                                                       placeHolder:[UIImage imageNamed:@"x_titlebg_default.jpg"]
                                                               key:imgurl
                                                   completeHandler:nil];
                }
                
                flag = YES;
                break;
            }
        }
    }
    if (flag == NO) {
        // Missing Background widget
        self.tabBar.backgroundImage = [UIImage imageNamed:@"x_titlebg_default.jpg"];
    }
}

@end

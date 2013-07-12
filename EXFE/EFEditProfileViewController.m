//
//  EFEditProfile.m
//  EXFE
//
//  Created by Stony Wang on 13-7-8.
//
//

#import "EFEditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "EFModel.h"
#import "Util.h"
#import "EXGradientToolbarView.h"

@interface EFEditProfileViewController ()

@property (nonatomic, weak) EXFEModel *model;

@property (nonatomic, strong) UITextField *name;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UITextField *bio;

// name
// bio
// external_id
// provider
// avatar_filename
// provider

@end

@implementation EFEditProfileViewController


#pragma mark - Getter/Setter
- (BOOL)isEditUser
{
    return self.user != nil;
}

#pragma mark - View Controller Live cycle
- (id)initWithModel:(EXFEModel*)model
{
    self = [super init];
    if (self) {
        self.model = model;
    }
    return self;
}

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = [UIColor COLOR_SNOW];
    self.view = contentView;
    
    UIImageView *fullScreen = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:fullScreen];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 80)];
    
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20,  CGRectGetHeight(header.bounds))];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:btnBack];
    
    UITextField *fullName = [[UITextField alloc] initWithFrame:CGRectMake(30, 15, 260, 50)];
    
    
    [self.view addSubview:header];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark KVO methods

#pragma mark - UI Refresh

#pragma mark - UI Events

#pragma mark UIButton action
- (void)goBack:(id)view
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

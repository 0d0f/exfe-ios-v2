//
//  EFViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-6-28.
//
//

#import "EFViewController.h"

@interface EFViewController ()

@end

@implementation EFViewController

- (id)initWithModel:(EXFEModel*)exfeModel
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.model = exfeModel;
    }
    return self;
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

@end

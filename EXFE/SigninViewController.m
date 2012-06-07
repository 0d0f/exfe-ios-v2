//
//  SigninViewController.m
//  EXFE
//
//  Created by ju huo on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"

@interface SigninViewController ()

@end

@implementation SigninViewController
@synthesize delegate;

- (IBAction) Signin:(id) sender{
    
//    NSString *identity=@"virushuo@gmail.com";
//    NSString *password=@"tmdtmd";
    NSString *password=[textPassword text];
    NSString *identity=[textUsername text];

    NSDictionary* params=[NSDictionary dictionaryWithObjectsAndKeys:identity, @"external_id",
                          @"email", @"provider",
                          password, @"password", nil];
    
    [[RKClient sharedClient] post:@"/users/signin" params:params delegate:self];
    
}
#pragma Mark - RKRequestDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    
    if ([request isGET]) {
        if ([response isOK]) {
            NSLog(@"Data returned: %@", [response bodyAsString]);
        }
    } else if ([request isPOST]) {
        if ([response isJSON]) {
            NSError *error = nil;
            id jsonParser =[[RKParserRegistry sharedRegistry] parserForMIMEType:RKMIMETypeJSON];
            NSDictionary *parsedResponse = [jsonParser objectFromString:[response bodyAsString] error:&error];
            [self processResponse:parsedResponse];
        }
    } else if ([request isDELETE]) {
        if ([response isNotFound]) {
            NSLog(@"Resource '%@' not exists", [request resourcePath]);
        }
    }    //    NSLog(@"Response code=%@, token=[%@], userName=[%@]", [[result meta] code], [result token], [[result user] userName]);
}

- (void) processResponse:(id)obj{
    if([obj isKindOfClass:[NSDictionary class]])
    {
        id meta=[obj objectForKey:@"meta"];
        if([meta isKindOfClass:[NSDictionary class]])
        {
            id code=[[obj objectForKey:@"meta"] objectForKey:@"code"];
            if([code isKindOfClass:[NSNumber class]])
            {
                if([code intValue]==200)
                {
                    id response=[obj objectForKey:@"response"];
                    if([response isKindOfClass:[NSDictionary class]])
                    {
                        NSString *token=[response objectForKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"access_token"];
                        [[NSUserDefaults standardUserDefaults] setObject:[response objectForKey:@"user_id"]   forKey:@"userid"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [delegate SigninDidFinish];
                    }
                }
            }
        }
    }
    NSLog(@"POST returned a JSON response:%@",obj);
}
- (void)request:(RKRequest *)request didFailLoadWithError:(NSError *)error{
    NSLog(@"error:%@",error);   
}

- (void)SigninDidFinish{
    [delegate SigninDidFinish];
}

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

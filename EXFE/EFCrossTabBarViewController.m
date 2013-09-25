//
//  EFCrossTabBarViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-8-26.
//
//

#import "EFCrossTabBarViewController.h"
#import <BlocksKit/BlocksKit.h>

#import "Util.h"
#import "EFKit.h"
#import "EFEntity.h"
#import "EFModel.h"
#import "CCTemplate.h"

@interface EFCrossTabBarViewController ()
@property (nonatomic, assign) BOOL hasLocalCross;
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
    [self regObserver];
    if (!self.cross) {
        self.hasLocalCross = NO;
        
        self.cross = [self.model getCrossById:self.crossId];
        [self.model loadCrossWithCrossId:self.crossId updatedTime:nil];
    } else {
        self.hasLocalCross = YES;
        
        [self.model loadCrossWithCrossId:[self.cross.cross_id unsignedIntegerValue] updatedTime:self.cross.updated_at];
    }
    [self refreshUI];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregObserver];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)regObserver
{
    //Cross
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadCrossSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameLoadCrossFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameEditCrossSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameEditCrossFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveCrossSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveCrossFailure
                                               object:nil];
    
    
    // Exfee
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveMyInvitationSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveMyInvitationFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveInvitationSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveInvitationFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameEditExfeeSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameEditExfeeFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveNotificationIdentitySuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRemoveNotificationIdentityFailure
                                               object:nil];
    
    // Rsvp (=>exfee)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRsvpSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNotification:)
                                                 name:kEFNotificationNameRsvpFailure
                                               object:nil];
}

- (void)unregObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    NSDictionary *userInfo = notification.userInfo;
    
    
    if ([name hasSuffix:@".success"] && userInfo) {
        // for success
        NSString *cat = userInfo[@"type"];
        NSNumber *num = userInfo[@"id"];
        
        if ([@"cross" isEqualToString:cat]) {
            if (num && self.crossId == [num unsignedIntegerValue] ) {
                // kEFNotificationNameEditCrossSuccess
                // kEFNotificationNameLoadCrossSuccess
                
                if ([kEFNotificationNameRemoveCrossSuccess isEqualToString:name]) {
                    // exit current page
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    Cross *c = [userInfo objectForKey:@"response.cross"];
                    if (self.crossId == [c.cross_id unsignedIntegerValue]) {
                        [self setValue:c forKeyPath:@"cross"];
                        [self refreshUI];
                        // notification to refresh cross
                    }
                }
            } else {
                // for cross list
            }
        } else if ([@"exfee" isEqualToString:cat]) {
            if (num && [self.cross.exfee.exfee_id isEqualToNumber:num] ) {
                // kEFNotificationNameRemoveInvitationSuccess
                // kEFNotificationNameRemoveMyInvitationSuccess
                // kEFNotificationNameEditExfeeSuccess
                //kEFNotificationNameRemoveNotificationIdentitySuccess
                
                Exfee *exfee = [userInfo objectForKey:@"response.exfee"];
                NSArray * list = [exfee getMyInvitations];
                if (list.count == 0 && [kEFNotificationNameRemoveMyInvitationSuccess isEqualToString:name]) {
                        // exit cross and remove from local
                        [self removeCrossAndExit];
                } else {
                    Cross *c = [self.model getCrossById:self.crossId];
                    [self setValue:c forKeyPath:@"cross"];
                    [self refreshUI];
                    // notification to refresh exfee
                }
            } else {
                // for exfee list
            }
        } else if ([@"rsvp" isEqualToString:cat]) {
            if (num && [self.cross.exfee.exfee_id isEqualToNumber:num] ) {
                // kEFNotificationNameRsvpSuccess
                [self.model loadCrossWithCrossId:self.crossId updatedTime:nil];
            } else {
                
            }
        } else {
            // for others
        }
        
    } else if ([name hasSuffix:@".failure"] && userInfo) {
        // for failure
        NSString *cat = userInfo[@"type"];
        NSNumber *num = userInfo[@"id"];
        
        if ([@"cross" isEqualToString:cat]) {
            if (num && self.crossId == [num unsignedIntegerValue] ) {
                if ([kEFNotificationNameLoadCrossFailure isEqualToString:name]) {
                    Meta *meta = userInfo[@"meta"];
                    if (meta) {
                        NSInteger c = [meta.code integerValue];
                        NSInteger t = c / 100;
                        
                        switch (t) {
                            case 3:{
                                if (c == 304) {
                                    // "errorType":"Cross Not Modified."
                                    // do nothing
                                }
                            } break;
                            case 4:{
                                if (c == 403) {
                                    UIAlertView *alert = [UIAlertView alertViewWithTitle:NSLocalizedString(@"Privacy Control", nil)
                                                                                 message:[NSLocalizedString(@"You have no access to this private {{X_NOUN}}.", nil) templateFromDict:[Util keywordDict]]];
                                    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil) handler:^{
                                        [self removeCrossAndExit];
                                    }];
                                    [alert show];
                                }
                            } break;
                                
                            default:{
                                
                            } break;
                        }
                    } else {
                        NSError *error __attribute__((unused)) = userInfo[@"error"];
//                        if ([@"NSCocoaErrorDomain" isEqualToString:error.domain]) {
//                            [self.model loadCrossListAfter:self.model.latestModify];
//                        }
                    }
                    
                } else if ([kEFNotificationNameEditCrossFailure isEqualToString:name]) {
                    [self willChangeValueForKey:@"cross"];
                    [self.model.objectManager.managedObjectStore.mainQueueManagedObjectContext refreshObject:self.cross mergeChanges:NO];
                    [self didChangeValueForKey:@"cross"];
//                    [self.model loadCrossWithCrossId:self.crossId updatedTime:self.cross.updated_at];
                }
                
            }  else {
                // for cross list
            }
        } else if ([@"exfee" isEqualToString:cat]) {
            if (num && [self.cross.exfee.exfee_id isEqualToNumber:num] ) {
                Meta *meta = userInfo[@"meta"];
                if (meta) {
                    NSInteger c = [meta.code integerValue];
                    NSInteger t = c / 100;
                    // [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                    switch (t) {
                        case 3:{
                            if (c == 304) {
                                // "errorType":"Cross Not Modified."
                                // do nothing
                            }
                        } break;
                        case 4:{
                            if (c == 400) {
                                // 400 Over people max limited
                            }
                        } break;
                            
                        default:{
                            
                        } break;
                    }
                } else {
                    NSError *error __attribute__((unused)) = userInfo[@"error"];
                    // [objectManager.managedObjectStore.mainQueueManagedObjectContext rollback];
                }
            } else if ([@"rsvp" isEqualToString:cat]) {
                if (num && [self.cross.exfee.exfee_id isEqualToNumber:num] ) {
                    // kEFNotificationNameRsvpFailure
                    [self.model loadCrossWithCrossId:self.crossId updatedTime:nil];
                } else {
                    
                }
            }else {
                // for exfee list
            }
        } else {
            // for others
        }
    }
}

#pragma mark - Update UI Views
- (void)refreshUI
{
    if (self.cross) {
        [self fillHead:self.cross];
        
        if (!self.hasLocalCross) {
            self.hasLocalCross = YES;
            [self reorderViewControllers];
            [self setSelectedIndex:self.defaultIndex animated:YES];
        }
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

- (void)removeCrossAndExit
{
    // remove self from local storage
    Cross * c = [self.model getCrossById:self.crossId];
    if (c) {
        [self.model deleteCross:c];
    }
    
    // exit current page
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

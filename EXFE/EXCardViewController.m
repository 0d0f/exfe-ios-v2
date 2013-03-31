//
//  EXCardViewController.m
//  EXFE
//
//  Created by 0day on 13-3-31.
//
//

#import "EXCardViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "User+EXFE.h"
#import "Identity.h"
#import "Identity+EXFE.h"
#import "Util.h"
#import "AppDelegate.h"
#import "EXCardCell.h"

#define kViewRestHeight             (126.0f)
#define kTableViewCellHeight        (30.0f)
#define kLastTableViewCellHeight    (20.0f)
#define kViewHeightMax              (CGRectGetHeight([UIScreen mainScreen].applicationFrame) - 85.0f)

@interface EXCardViewController ()
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, assign) CGFloat moveDistance;
@property (nonatomic, retain) UIViewController *sourceViewController;
@property (nonatomic, retain) NSArray *sortedUserIdentities;

- (void)moveVertiallyWithDistance:(CGFloat)distance animated:(BOOL)animated completion:(void (^)(void))handler;
@end

@implementation EXCardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CAGradientLayer *bgLayer = [CAGradientLayer layer];
    bgLayer.colors = @[(id)[UIColor COLOR_RGB(0x33, 0x33, 0x33)].CGColor, (id)[UIColor COLOR_RGB(0x22, 0x22, 0x22)].CGColor];
    bgLayer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
    
    CAGradientLayer *innerShadowLayer = [CAGradientLayer layer];
    innerShadowLayer.colors = @[(id)[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor, (id)[UIColor clearColor].CGColor];
    innerShadowLayer.frame = (CGRect){{0, 0}, {CGRectGetWidth(self.view.layer.bounds), 4}};
    [self.view.layer addSublayer:innerShadowLayer];
    
    self.nameLabel.text = self.user.name;
}

- (void)dealloc {
    [_sortedUserIdentities release];
    [_window release];
    [_user release];
    [_tableView release];
    [_nameLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [self setNameLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Getter && Setter
- (void)setUser:(User *)user {
    if (user == _user)
        return;
    if (_user) {
        [_user release];
        _user = nil;
        
        self.sortedUserIdentities = nil;
    }
    
    if (user) {
        _user = [user retain];
        NSArray *identities = [user.identities allObjects];
        identities = [identities sortedArrayUsingComparator:^(id obj1, id obj2){
            Identity *identity1 = (Identity *)obj1;
            Identity *identity2 = (Identity *)obj2;
            
            if ([identity1.a_order longValue] > [identity2.a_order longValue]) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
        
        self.sortedUserIdentities = identities;
    }
}

#pragma mark - Action
- (IBAction)doneButtonPressed:(id)sender {
}

- (void)tapHandler:(UITapGestureRecognizer *)recognizer {
    [recognizer.view removeGestureRecognizer:recognizer];
    [self dismissWithAnimated:YES
                   completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.user.identities count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentity = @"CardCell";
    EXCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentity];
    if (nil == cell) {
        cell = [[[EXCardCell alloc] init] autorelease];
    }
    
    if (indexPath.row < [self.user.identities count]) {
        Identity *identity = [self.sortedUserIdentities objectAtIndex:indexPath.row];
        cell.identity = identity;
    } else {
        cell.identity = nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.user.identities count]) {
        return kTableViewCellHeight;
    } else {
        return kLastTableViewCellHeight;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#warning test only 得知接口之后改为根据数据来获取 pravicy 信息
    EXCardCell *cell = (EXCardCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (kEXCardCellPravicyStatePublic == cell.pravicyState) {
        cell.pravicyState = kEXCardCellPravicyStatePrivate;
    } else {
        cell.pravicyState = kEXCardCellPravicyStatePublic;
    }
}

#pragma mark - Public
- (void)presentFromViewController:(UIViewController *)controller animated:(BOOL)animated completion:(void (^)(void))handler {
    [self retain];
    
    self.sourceViewController = controller;
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    self.window = [[[UIWindow alloc] initWithFrame:screenBounds] autorelease];
    self.window.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapHandler:)];
    tap.delegate = self;
    [self.window addGestureRecognizer:tap];
    [tap release];
    
    CGFloat viewHeight = kViewRestHeight;
    viewHeight += kTableViewCellHeight * [self.user.identities count] + kLastTableViewCellHeight;
    
    viewHeight = viewHeight > kViewHeightMax ? kViewHeightMax : viewHeight;
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = CGRectGetHeight(screenBounds);
    viewFrame.size.height = viewHeight;
    self.view.frame = viewFrame;
    [self.window addSubview:self.view];
    
    [self.window makeKeyAndVisible];
    
    [self moveVertiallyWithDistance:-CGRectGetHeight(self.view.bounds)
                           animated:YES
                         completion:handler];
}

- (void)dismissWithAnimated:(BOOL)animated completion:(void (^)(void))handler {
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat viewOriginY = CGRectGetMinY(self.view.frame);
    
    if ([self.delegate respondsToSelector:@selector(cardViewControllerWillFinish:)]) {
        [self.delegate cardViewControllerWillFinish:self];
    }
    
    [self moveVertiallyWithDistance:(screenHeight - viewOriginY)
                           animated:YES
                         completion:^{
                             [self.view removeFromSuperview];
                             [((AppDelegate *)[UIApplication sharedApplication].delegate).window makeKeyAndVisible];
                             self.window.hidden = YES;
                             
                             if ([self.delegate respondsToSelector:@selector(cardViewControllerDidFinish:)]) {
                                 [self.delegate cardViewControllerDidFinish:self];
                             }
                             
                             if (handler)
                                 handler();
                             [self release];
                         }];
}

- (void)moveVertiallyWithDistance:(CGFloat)distance animated:(BOOL)animated completion:(void (^)(void))handler {
    [UIView setAnimationsEnabled:animated];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         CGRect sourceViewFrame = self.sourceViewController.view.frame;
                         sourceViewFrame.origin.y += distance;
                         self.sourceViewController.view.frame = sourceViewFrame;
                         
                         CGRect viewFrame = self.view.frame;
                         viewFrame.origin.y += distance;
                         self.view.frame = viewFrame;
                     }
                     completion:^(BOOL finished){
                         if (handler)
                             handler();
                     }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x > 0 && location.y > 0)
        return NO;
    return YES;
}

@end

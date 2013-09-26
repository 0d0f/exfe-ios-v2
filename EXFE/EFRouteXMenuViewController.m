//
//  EFRouteXMenuViewController.m
//  EXFE
//
//  Created by 0day on 13-9-16.
//
//

#import "EFRouteXMenuViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "EFTouchDownGestureRecognizer.h"
#import "EFGradientView.h"
#import "Util.h"

#define kTableViewWidth (165.0f)
#define kCellHeight     (44.0f)
#define kCornerRadius   (4.0f)
#define kNumberOfRows   (2)

@interface EFRouteXMenuViewController ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) NSArray *titles;

@end

@implementation EFRouteXMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.layer.cornerRadius = kCornerRadius;
    
    EFGradientView *backgroundView = [[EFGradientView alloc] initWithFrame:self.tableView.bounds];
    backgroundView.colors = @[[UIColor COLOR_RGB(0x4C, 0x4C, 0x4C)], [UIColor COLOR_RGB(0x33, 0x33, 0x33)]];
    self.tableView.backgroundView = backgroundView;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    
    self.titles = @[NSLocalizedString(@"Show this map", nil),
                    NSLocalizedString(@"Share trail photos", nil)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RouteXMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        cell.textLabel.shadowOffset = (CGSize){0.0f, 0.5f};
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    }

    cell.textLabel.text = self.titles[indexPath.row];
    
    if (0 == indexPath.row) {
        cell.textLabel.textColor = [UIColor COLOR_RGB(0x59, 0xA9, 0xFF)];
    } else if (1 == indexPath.row) {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

#pragma mark - Table View delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (0 == indexPath.row) {
        if ([self.delegate respondsToSelector:@selector(menuViewControllerWannaShowRouteX:)]) {
            [self.delegate menuViewControllerWannaShowRouteX:self];
        }
    } else if (1 == indexPath.row) {
        if ([self.delegate respondsToSelector:@selector(menuViewControllerWannaShowPhoto:)]) {
            [self.delegate menuViewControllerWannaShowPhoto:self];
        }
    }
}

#pragma mark - Public

- (void)presentFromViewController:(UIViewController *)fromViewController animated:(BOOL)animated {
    if (!self.maskView) {
        UIView *maskView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
        EFTouchDownGestureRecognizer *touchDown = [[EFTouchDownGestureRecognizer alloc] init];
        __weak typeof(self) weakSelf = self;
        
        touchDown.touchesBeganCallback = ^(NSSet * touches, UIEvent * event){
            UITouch *touch = [touches anyObject];
            CGPoint location = [touch locationInView:self.tableView];
            if (!CGRectContainsPoint(self.tableView.bounds, location)) {
                [weakSelf dismissAnimated:YES];
            }
        };
        
        [maskView addGestureRecognizer:touchDown];
        self.maskView = maskView;
        
        [fromViewController.view addSubview:self.maskView];
    }
    
    CGRect selfFrame = (CGRect){{CGRectGetWidth(self.maskView.frame), 28.0f}, {kTableViewWidth + kCornerRadius, kCellHeight * kNumberOfRows}};
    self.tableView.frame = selfFrame;
    [self.maskView addSubview:self.tableView];
    
    selfFrame.origin.x -= kTableViewWidth;
    
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.tableView.frame = selfFrame;
                     }];
}

- (void)dismissAnimated:(BOOL)animated {
    CGRect selfFrame = self.tableView.frame;
    selfFrame.origin.x += kTableViewWidth;
    
    [UIView animateWithDuration:0.233f
                     animations:^{
                         self.tableView.frame = selfFrame;
                     }
                     completion:^(BOOL finished){
                         [self.tableView removeFromSuperview];
                         [self.maskView removeFromSuperview];
                     }];
}

@end

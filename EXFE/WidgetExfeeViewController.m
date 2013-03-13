//
//  WidgetExfeeViewController.m
//  EXFE
//
//  Created by Stony Wang on 13-3-11.
//
//

#import "WidgetExfeeViewController.h"
#import "Util.h"
#import "CrossCard.h"

#define EXFEE_CONTENT_HEIGHT      (236)

#define kTagViewExfeeRoot         10
#define kTagViewExfeeSelector     20
#define kTagViewExfeeContent      30

#define kTableFloating   222
#define kTableOrigin     223


@interface WidgetExfeeViewController ()

@end

@implementation WidgetExfeeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selected_invitation = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CGRect a = [UIScreen mainScreen].applicationFrame;
    CGRect b = self.view.bounds;
    self.view.tag = kTagViewExfeeRoot;
    
    
    exfeeContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, CGRectGetWidth(b), CGRectGetHeight(a) - 50)];
    exfeeContainer.delegate = self;
    exfeeContainer.backgroundColor = [UIColor darkGrayColor];
    exfeeContainer.alwaysBounceVertical = YES;
    exfeeContainer.contentOffset = CGPointMake(0, 0);
    exfeeContainer.tag = kTagViewExfeeSelector;
    {
        CGFloat maxHeight = 0;
        for (NSUInteger i = 1; i < 10; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(20, EXFEE_CONTENT_HEIGHT - 80 + i * 100, 48, 44);
            [btn addTarget:self action:@selector(testClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:[NSString stringWithFormat:@"%i", i] forState:UIControlStateNormal];
            btn.tag = i;
            maxHeight = CGRectGetMaxY(btn.frame);
            [exfeeContainer addSubview:btn];
        }
        
        if (exfeeContainer.contentSize.height < maxHeight) {
            exfeeContainer.contentSize = CGSizeMake(exfeeContainer.contentSize.width, maxHeight);
        }
    }
    [self.view addSubview:exfeeContainer];
    
    
    
    invTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(b), EXFEE_CONTENT_HEIGHT)];
    invTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    invTable.dataSource = self;
    invTable.delegate = self;
    invTable.backgroundColor = [UIColor COLOR_SNOW];
    invTable.tag = kTableOrigin;
    [exfeeContainer addSubview:invTable];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [invTable release];
    
    [exfeeContainer release];
    
    [super dealloc];
}

#pragma mark UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 2; //depends on Exfee
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            if (tableHeader == nil) {
                tableHeader = [[ExfeeRsvpCell alloc] initWithFrame:CGRectMake(0, 0, 320, 87)];
                tableHeader.backgroundColor = [UIColor redColor];
                NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"Pending"];
                tableHeader.MainText = as;
                tableHeader.AltText = @"agda by fejao";
                tableHeader.RsvpString = @"Pending";
                tableHeader.NameText = @"Steve Exfer";
            }
            return tableHeader;
        }
        case 1:
        {
            NSString* reuseIdentifier = @"Exfee Identity Cell";
            ExfeeResponseCell *cell =[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
            if (nil == cell) {
                cell = [[[ExfeeResponseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
            }
            // fill UI element;
            [cell setNeedsDisplay];
            return cell;
        }
        case 2:
        {
            if (tableFooter == nil) {
                tableFooter = [[ABTableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
                tableFooter.backgroundColor = [UIColor greenColor];
            }
            return tableFooter;
        }
            break;
            
        default:
            return nil;
            //break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 121.0f;
        case 1:
            return 32.0f;
        case 2:
            return 32.0f;
        default:
            return 0;
    }}

#pragma mark UITableViewDelegate methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                default:
                    break;
            }
            
            break;
        case 2:
            
            break;
            
        default:
            break;
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
    NSLog(@"Scroll Start");
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastContentOffset = CGPointMake(-1, -1);
    NSLog(@"Scroll Finished");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == kTagViewExfeeSelector) {
        
        CGPoint offset = scrollView.contentOffset;
        ScrollDirection direction = ScrollDirectionNone;
        
        if (_lastContentOffset.x >= 0) {
            if (offset.y > _lastContentOffset.y) {
                direction = ScrollDirectionUp;
            }else{
                direction = ScrollDirectionDown;
            }
        }
        _lastContentOffset = offset;
        
        if (invTable.tag == kTableFloating) {
            if (direction == ScrollDirectionDown){
                NSLog(@"Block view position when floating with drop down: %@", NSStringFromCGPoint(offset));
                if (offset.y < CGRectGetMinY(invTable.frame)) {
                    CGRect newFrame = CGRectOffset(invTable.bounds, 0, MAX(offset.y, 0));
                    invTable.frame = newFrame;
                }
                return;
            }
            
            if (offset.y > CGRectGetMaxY(invTable.frame)){
                NSLog(@"Convert floating to origin: %@", NSStringFromCGPoint(offset));
                CGRect newFrame = CGRectOffset(invTable.bounds, 0, 0);
                invTable.frame = newFrame;
                invTable.tag = kTableOrigin;
                return;
            }
        }
        
    }
    
}

- (void)testClick:(id)sender{
    UIButton* btn = sender;
    NSLog(@"button click: %i", btn.tag);
    
    CGPoint offset = exfeeContainer.contentOffset;
    BOOL flag = NO;
    if (CGRectGetMinY(btn.frame) - offset.y < CGRectGetHeight(invTable.frame)) {
        // click target is upper than the normal area
        offset = CGPointMake(offset.x, CGRectGetMinY(btn.frame) - 20 - CGRectGetHeight(invTable.frame));
        flag = YES;
    } else if(CGRectGetMaxY(btn.frame) - offset.y > CGRectGetHeight(exfeeContainer.bounds)){
        // click target is lower than the normal area
        offset = CGPointMake(offset.x, CGRectGetMaxY(btn.frame) + 20 - CGRectGetHeight(exfeeContainer.bounds));
        flag = YES;
    }
    
    invTable.frame = CGRectOffset(invTable.bounds, offset.x, MAX(offset.y ,0));
    if (flag) {
        exfeeContainer.contentOffset = offset;
        //exfeeContainer.bounds.y += offset.y - exfeeContainer.contentOffset.y; // for animation
    }
    invTable.tag = kTableFloating;
    
}
@end

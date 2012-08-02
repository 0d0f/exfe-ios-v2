//
//  TimeViewController.m
//  EXFE
//
//  Created by huoju on 7/10/12.
//
//

#import "TimeViewController.h"

@interface TimeViewController ()

@end

@implementation TimeViewController
@synthesize gatherview;

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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44,320,200) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    _times=[[NSArray alloc] initWithObjects:@"Sometime",@"Anytime",@"All-day",@"Breakfast",@"Morning", @"Brunch", @"Lunch", @"Noon", @"Afternoon", @"Tea-time", @"Dinner", @"Evening", @"Night", @"Midnight", @"Daybreak", nil];
    NSLocale *locale = [NSLocale currentLocale];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:locale];
    datepicker.calendar=cal;
    
//    [datepicker addTarget:self action:@selector(updateDate:) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITableView Datasource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if(_times)
        return [_times count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"datetime view";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	NSString *timestr=[_times objectAtIndex:indexPath.row];
    if(timestr!=nil)
        cell.textLabel.text =timestr;
        
    return cell;
    
}
- (IBAction) Done:(id) sender{
    [self saveDate:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) saveDate:(NSString*) time_word{
    EFTime *eftime=[EFTime object];
    CrossTime *crosstime=[CrossTime object];
    
    NSDate *date=datepicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr=[formatter stringFromDate:date];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timestr=[formatter stringFromDate:date];
    
    [formatter setDateFormat:@"z"];
    NSString *timezonestr=[formatter stringFromDate:date];
    NSString *eftimezone=[timezonestr substringFromIndex:3];
    [formatter release];
    
    if(time_word!=nil)
    {
        crosstime.outputformat=[NSNumber numberWithInt:0];
        crosstime.origin=[NSString stringWithFormat:@"%@ %@",stringFromDate,time_word];
        eftime.time_word=time_word;
    }
    else{
        crosstime.origin=stringFromDate;
        eftime.time_word=@"";
    }
    eftime.date=datestr;
    eftime.time=timestr;
    eftime.date_word=@"";
    eftime.timezone=eftimezone;
    crosstime.begin_at=eftime;
    [(GatherViewController*)gatherview setDateTime:crosstime];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==0)
        [self cleanDate];
    else{
        NSString *timeword=[_times objectAtIndex:indexPath.row];
        [self saveDate:timeword];
    }
    [self dismissModalViewControllerAnimated:YES];
//    [self selectPlace:indexPath.row];
}
- (void) cleanDate{
    [(GatherViewController*)gatherview setDateTime:nil];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [inputtimeword resignFirstResponder];
    [_tableView becomeFirstResponder];
}
- (void)dealloc {
    [_times release];
    [super dealloc];
}

@end

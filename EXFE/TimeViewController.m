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
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;
    [self.view setFrame:screenframe];

    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 47)];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navbar.png"]]];
    [self.view addSubview:toolbar];
    UIImageView *lefticon=[[UIImageView alloc] initWithFrame:CGRectMake(11, 13, 18, 18)];
    lefticon.image= [UIImage imageNamed:@"time_18.png"];
    [toolbar addSubview:lefticon];
    [lefticon release];
    
    UILabel *titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(11+18+8, 7, 80, 33)];
    titleLabel.text=@"Time";
    titleLabel.backgroundColor=[UIColor clearColor];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [titleLabel setTextColor:FONT_COLOR_FA];
    [titleLabel setShadowColor:[UIColor blackColor]];
    [titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [toolbar addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *doneButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(265, 7, 50, 30)];
    [doneButton setTitle:@"Save" forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    [doneButton setTitleColor:[UIColor colorWithRed:204.0/255.0f green:229.0/255.0f blue:255.0/255.0f alpha:1] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"btn_dark.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:doneButton];
    lasttimebutton=[[UIButton alloc] initWithFrame:CGRectMake(0, 44, 320, 0)];
    NSString *lasttime=@"";
    if(_crosstime){
        lasttime=[[Util getTimeDesc:_crosstime] stringByTrimmingCharactersInSet:
         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if(![lasttime isEqualToString:@""])
            [lasttimebutton setFrame:CGRectMake(0, 44, 320, 44)];
    }
    [lasttimebutton addTarget: self action: @selector(uselasttime) forControlEvents: UIControlEventTouchUpInside];
    [lasttimebutton setBackgroundColor:[UIColor colorWithRed:127.f/255.f green:127.f/255.f blue:127.f/255.f alpha:0.15]];
    UILabel *revertto=[[UILabel alloc] initWithFrame:CGRectMake(8, 2, 80, 12)];
    revertto.text=@"Revert to";
    revertto.textColor=[UIColor colorWithRed:127/255.f green:127/255.f blue:127/255.f alpha:1];
    revertto.font=[UIFont fontWithName:@"HelveticaNeue" size:12];
    revertto.backgroundColor=[UIColor clearColor];
    [lasttimebutton addSubview:revertto];
    [revertto release];
    
    UILabel *lasttimelabel=[[UILabel alloc] initWithFrame:CGRectMake(8, 2+12+4,320-16 , 18)];
    lasttimelabel.text=lasttime;
    lasttimelabel.textColor=[UIColor blackColor];
    lasttimelabel.font=[UIFont fontWithName:@"HelveticaNeue" size:18];
    lasttimelabel.backgroundColor=[UIColor clearColor];
    [lasttimebutton addSubview:lasttimelabel];
    [lasttimelabel release];
    
    [self.view addSubview:lasttimebutton];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,44+lasttimebutton.frame.size.height,320,self.view.frame.size.height-datepicker.frame.size.height-lasttimebutton.frame.size.height-44) style:UITableViewStylePlain];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    _times=[[NSArray alloc] initWithObjects:@"Sometime",@"Anytime",@"All-day",@"Breakfast",@"Morning", @"Brunch", @"Lunch", @"Noon", @"Afternoon", @"Tea-time", @"Dinner", @"Evening", @"Night", @"Midnight", @"Daybreak", nil];
    NSLocale *locale = [NSLocale currentLocale];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:locale];
    
    datepicker.calendar=cal;
    [datepicker setTimeZone:[NSTimeZone localTimeZone]];
    [datepicker addTarget:self action:@selector(dateChanged:)
     forControlEvents:UIControlEventValueChanged];
//    if(_crosstime!=nil){
//        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
//        NSString *datetimestr=@"";
//        NSString *timeword=@"";
//        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
//        [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        if(![_crosstime.begin_at.date isEqualToString:@""] &&![_crosstime.begin_at.time isEqualToString:@""]){
//            datetimestr=[NSString stringWithFormat:@"%@ %@",_crosstime.begin_at.date,_crosstime.begin_at.time];
//            NSDate *date=[dateformat dateFromString:datetimestr];
//            if(date)
//                [datepicker setDate:date];
//        }
//        else  if(![_crosstime.begin_at.date isEqualToString:@""]){
//            datetimestr=[NSString stringWithFormat:@"%@ 00:00:00",_crosstime.begin_at.date];
//            timeword=_crosstime.begin_at.time_word;
//            NSDate *_date=[dateformat dateFromString:datetimestr];
//            [dateformat setDateFormat:@"yyyy-MM-dd"];
//            [dateformat setTimeZone:[NSTimeZone localTimeZone]];
//            NSString *localdatestr=[dateformat stringFromDate:_date];
//            [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//            datetimestr=[NSString stringWithFormat:@"%@ 10:00:00",localdatestr];
//            _date=[dateformat dateFromString:datetimestr];
//            if(_date)
//                [datepicker setDate:_date];
//            for(int i=0;i<[_times count];i++){
//                if([(NSString*)[_times objectAtIndex:i] isEqualToString:timeword]){
//                    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
//                }
//            }
//        }
//        [dateformat release];
//        
//    }

}
- (void) dateChanged:(id) sender{
    datechanged=YES;
}
- (void) setDateTime:(CrossTime*)crosstime{
    if(crosstime!=nil) {
        _crosstime=crosstime;
    }
}
- (void) uselasttime{
    [self dismissModalViewControllerAnimated:YES];
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
    if(datechanged==YES)
        [self saveDate:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) saveDate:(NSString*) time_word{
    if([time_word isEqualToString:@"Sometime"])
            [self dismissModalViewControllerAnimated:YES];
    EFTime *eftime=[EFTime object];
    CrossTime *crosstime=[CrossTime object];
    
    NSDate *date=datepicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr=[formatter stringFromDate:date];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timestr=[formatter stringFromDate:date];
    if(time_word!=nil){
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        datestr=[formatter stringFromDate:date];
        timestr=@"";
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    }
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"ZZZZ"];
    NSString *timezonestr=[formatter stringFromDate:date];
    NSString *eftimezone=[timezonestr substringFromIndex:3];
    if([eftimezone isEqualToString:@""])
        eftimezone=@"+00:00";

    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *origin_date=[formatter stringFromDate:date];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *origin_datetime=[formatter stringFromDate:date];

    [locale release];
    [formatter release];

    if(time_word!=nil)
    {
        crosstime.outputformat=[NSNumber numberWithInt:0];
        crosstime.origin=[NSString stringWithFormat:@"%@ %@",origin_date,time_word];
        eftime.time_word=time_word;
    }
    else{
        crosstime.origin=origin_datetime;
        eftime.time_word=@"";
    }
    eftime.date=datestr;
    if(time_word==nil)
        eftime.time=timestr;
    else
        eftime.time=@"";
    eftime.date_word=@"";
    eftime.timezone=eftimezone;
    crosstime.begin_at=eftime;
    [(GatherViewController*)gatherview saveDateTime:crosstime];
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
}

- (void) cleanDate{
    [(GatherViewController*)gatherview setDateTime:nil];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [inputtimeword resignFirstResponder];
    [_tableView becomeFirstResponder];
}
- (void)dealloc {
    [lasttimebutton release];
    [_tableView release];
    [_times release];
    [super dealloc];
}

@end

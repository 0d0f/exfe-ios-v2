//
//  TimeViewController.m
//  EXFE
//
//  Created by huoju on 7/10/12.
//
//

#import "TimeViewController.h"
#import "TTTAttributedLabel.h"

@interface TimeViewController ()

@end

@implementation TimeViewController

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
    [Flurry logEvent:@"EDIT_TIME"];
    CGRect screenframe=[[UIScreen mainScreen] bounds];
    
    CGRect statusframe=[[UIApplication sharedApplication] statusBarFrame];
    screenframe.size.height-=statusframe.size.height;
    [self.view setFrame:screenframe];

    toolbar = [[EXGradientToolbarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [toolbar.layer setShadowColor:[UIColor blackColor].CGColor];
    [toolbar.layer setShadowOpacity:0.8];
    [toolbar.layer setShadowRadius:3.0];
    [toolbar.layer setShadowOffset:CGSizeMake(0, 0)];
    
    [self.view addSubview:toolbar];

    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom ];
    [btnBack setFrame:CGRectMake(0, 0, 20, 44)];
    btnBack.backgroundColor = [UIColor COLOR_WA(0x33, 0xAA)];
    [btnBack setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [btnBack setImage:[UIImage imageNamed:@"back_pressed.png"] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(Close) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchDragExit];
    [toolbar addSubview:btnBack];

//    timeInput =[[UITextField alloc] initWithFrame:CGRectMake(54, 13.5, 195-18, 18.5)];
    
//    UIImageView *inputframeview=[[UIImageView alloc] initWithFrame:CGRectMake(28, 7, 229, 31)];
//    inputframeview.image=[UIImage imageNamed:@"textfield.png"];
//    inputframeview.contentMode    = UIViewContentModeScaleToFill;
//    inputframeview.contentStretch = CGRectMake(0.5, 0.5, 0, 0);
//    [toolbar addSubview:inputframeview];
//    [toolbar addSubview:timeInput];
//    [inputframeview.contentStretch release]

    UIImageView *icon=[[UIImageView alloc] initWithFrame:CGRectMake(33, 13.5, 18, 18)];
    icon.image=[UIImage imageNamed:@"time_18.png"];
//    [toolbar addSubview:icon];

    TTTAttributedLabel *viewtitle = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(60, (44-30)/2, self.view.frame.size.width-60-60, 30)];
    viewtitle.backgroundColor = [UIColor clearColor];
    viewtitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    viewtitle.textAlignment = NSTextAlignmentCenter;
    viewtitle.textColor = FONT_COLOR_51;
    [viewtitle setText:NSLocalizedString(@"Edit ·X· time", nil) afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange range = [[mutableAttributedString string] rangeOfString:NSLocalizedString(@"·X·", nil) options:NSCaseInsensitiveSearch];
        
        [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)FONT_COLOR_HL.CGColor range:range];
        return mutableAttributedString;
    }];
    [self.view addSubview:viewtitle];
    
    
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    [doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
    doneButton.frame = CGRectMake(265, 7, 50, 31);
    [doneButton addTarget:self action:@selector(Done:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"btn_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0,3)] forState:UIControlStateNormal];
    
    [toolbar addSubview:doneButton];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,toolbar.frame.size.height,320,self.view.frame.size.height-datepicker.frame.size.height-toolbar.frame.size.height) style:UITableViewStylePlain];

    _tableView.dataSource=self;
    _tableView.delegate=self;
    [self.view addSubview:_tableView];
    _times=[[NSArray alloc] initWithObjects:NSLocalizedString(@"Clear Time", nil),
            NSLocalizedString(@"All-day", nil),
            NSLocalizedString(@"Breakfast",nil),
            NSLocalizedString(@"Morning", nil),
            NSLocalizedString(@"Brunch", nil),
            NSLocalizedString(@"Lunch", nil),
            NSLocalizedString(@"Noon", nil),
            NSLocalizedString(@"Afternoon", nil),
            NSLocalizedString(@"Tea-break", nil),
            NSLocalizedString(@"Dinner", nil),
            NSLocalizedString(@"Evening", nil),
            NSLocalizedString(@"Night", nil),
            NSLocalizedString(@"Midnight", nil),
            NSLocalizedString(@"Daybreak", nil),
            nil];
    NSLocale *locale = [NSLocale currentLocale];
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setLocale:locale];
    
    datepicker.calendar=cal;
    [datepicker setTimeZone:[NSTimeZone localTimeZone]];
    [datepicker addTarget:self action:@selector(dateChanged:)
     forControlEvents:UIControlEventValueChanged];
    [self regObserver];
    [self refreshUI];
}

- (void)regObserver
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:timeInput];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:inputplace];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editingDidBegan:) name:UITextFieldTextDidBeginEditingNotification object:inputplace];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:placeedit.PlaceTitle];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:placeedit.PlaceDesc];
}

- (void)textDidChange:(NSNotification*)notification
{

//    if([timeInput.text length]>2)
//    {
//        editinginterval=CFAbsoluteTimeGetCurrent();
//        [self performSelector:@selector(getTimeFromAPI) withObject:self afterDelay:0.8];
//    }
}

- (void) getTimeFromAPI{
    if(CFAbsoluteTimeGetCurrent()-editinginterval>0.8)
    {
//        NSString *params_timezone=[DateTimeUtil timezoneString:[NSTimeZone localTimeZone]];        
//        RKParams* rsvpParams = [RKParams params];
//        [rsvpParams setValue:params_timezone forParam:@"timezone"];
////        [rsvpParams setValue:timeInput.text forParam:@"time_string"];
//        RKClient *client = [RKClient sharedClient];
//        [client setBaseURL:[RKURL URLWithBaseURLString:API_V2_ROOT]];
//        NSString *endpoint = [NSString stringWithFormat:@"/time/Recognize"];
//        [client post:endpoint usingBlock:^(RKRequest *request){
//            request.method=RKRequestMethodPOST;
//            request.params=rsvpParams;
//            request.onDidLoadResponse=^(RKResponse *response){
//                if (response.statusCode == 200) {
//                    NSDictionary *body=[response.body objectFromJSONData];
//                    id code=[[body objectForKey:@"meta"] objectForKey:@"code"];
//                    if(code){
//                        if([code intValue]==200) {
////                            NSLog(@"%@",[body objectForKey:@"response"]);
//                            NSDictionary *cross_time=[[body objectForKey:@"response"] objectForKey:@"cross_time"];
//                            NSDictionary *begin_at=[cross_time objectForKey:@"begin_at"];
////                            if(_crosstime==nil){
////                                _crosstime=[CrossTime object];
////                                _crosstime.begin_at=[EFTime object];
////                                
////                            }
//                            CrossTime *crosstime=[CrossTime object];
//                            crosstime.begin_at=[EFTime object];
//                            
//                            crosstime.origin=[cross_time objectForKey:@"origin"];
//                            crosstime.outputformat=[NSNumber numberWithBool:[[cross_time objectForKey:@"outputformat"] boolValue]];
//                            crosstime.begin_at.date=[begin_at objectForKey:@"date"];
//                            crosstime.begin_at.date_word=[begin_at objectForKey:@"date_word"];
//                            crosstime.begin_at.time=[begin_at objectForKey:@"time"];
//                            crosstime.begin_at.time_word=[begin_at objectForKey:@"time_word"];
//                            crosstime.begin_at.timezone=[begin_at objectForKey:@"timezone"];
//                            [self setDateTime:crosstime];
//                            datechanged=YES;
//                        }
//
//                    }
//
//                }
//            };
//            request.onDidFailLoadWithError=^(NSError *error){
//        //            NSString *errormsg=[error.userInfo objectForKey:@"NSLocalizedDescription"];
//        //            if(error.code==2)
//        //                errormsg=@"A connection failure has occurred.";
//        //            else
//        //                errormsg=@"Could not connect to the server.";
//        //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:errormsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        //            [alert show];
//        //            [alert release];
//            };
//        }];
    }
    
}

// deprecated
- (void) dateChanged:(id) sender{
    datechanged=YES;
}

- (void) refreshUI{
    if(_crosstime!=nil){
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        NSString *datetimestr=@"";
        NSString *timeword=@"";
        [dateformat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        if(![_crosstime.begin_at.date isEqualToString:@""] &&![_crosstime.begin_at.time isEqualToString:@""]){
            datetimestr=[NSString stringWithFormat:@"%@ %@",_crosstime.begin_at.date,_crosstime.begin_at.time];
            NSDate *date=[dateformat dateFromString:datetimestr];
            if(date){
//                NSLog(@"set datepicker %@",date);
                [datepicker setDate:date];
            }
        }
        else  if(![_crosstime.begin_at.date isEqualToString:@""]){
            datetimestr=[NSString stringWithFormat:@"%@ 00:00:00",_crosstime.begin_at.date];
            timeword=_crosstime.begin_at.time_word;
            NSDate *_date=[dateformat dateFromString:datetimestr];
            [dateformat setDateFormat:@"yyyy-MM-dd"];
            [dateformat setTimeZone:[NSTimeZone localTimeZone]];
            NSString *localdatestr=[dateformat stringFromDate:_date];
            [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            datetimestr=[NSString stringWithFormat:@"%@ 10:00:00",localdatestr];
            _date=[dateformat dateFromString:datetimestr];
            if(_date)
                [datepicker setDate:_date];
            for(int i=0;i<[_times count];i++){
                if([(NSString*)[_times objectAtIndex:i] isEqualToString:timeword]){
                    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
        
    }
}
- (void) setDateTime:(CrossTime*)crosstime{
    if(crosstime!=nil) {
        _crosstime=crosstime;
    }
    [self refreshUI];

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	NSString *timestr=[_times objectAtIndex:indexPath.row];
    if(timestr != nil){
        cell.textLabel.text = timestr;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.textColor = [UIColor COLOR_WA(0x7F, 0xFF)];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    return cell;
    
}
- (IBAction) Done:(id) sender{
//    if(datechanged==YES)
    [self saveDate:nil];
    [self dismissModalViewControllerAnimated:YES];
//    
}

- (void) Close{
    [self dismissModalViewControllerAnimated:YES];
}


- (void) saveDate:(NSString*) time_word{
    if([time_word isEqualToString:@"Sometime"])
            [self dismissModalViewControllerAnimated:YES];
  
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    NSEntityDescription *eftimeEntity = [NSEntityDescription entityForName:@"EFTime" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    EFTime *eftime=[[EFTime alloc] initWithEntity:eftimeEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];


    NSEntityDescription *crosstimeEntity = [NSEntityDescription entityForName:@"CrossTime" inManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];
    CrossTime *crosstime=[[CrossTime alloc] initWithEntity:crosstimeEntity insertIntoManagedObjectContext:objectManager.managedObjectStore.mainQueueManagedObjectContext];

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


    if(time_word!=nil) {
        crosstime.outputformat=[NSNumber numberWithInt:0];
        crosstime.origin=[NSString stringWithFormat:@"%@ %@",origin_date,time_word];
        eftime.time_word=time_word;
    }
    else {
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
//    [delegate setTime:crosstime];
    [self.delegate setTime:crosstime];
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
    [(NewGatherViewController*)self.delegate setTime:nil];
}

#pragma mark UIScrollView methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [inputtimeword resignFirstResponder];
//    [timeInput resignFirstResponder];
    [_tableView becomeFirstResponder];
}

@end

//
//  GatherViewController.h
//  EXFE
//
//  Created by huoju on 6/17/12.
//
//

#import <UIKit/UIKit.h>
#import <RestKit/JSONKit.h>
#import <RestKit/RestKit.h>
#import "AppDelegate.h"
#import "CrossesViewController.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "EXImagesCollectionView.h"
#import "ImgCache.h"
#import "APIProfile.h"
#import "Invitation.h"
#import "ImgCache.h"
#import "PlaceViewController.h"
#import "Place.h"
#import <MapKit/MapKit.h>
#import "WildcardGestureRecognizer.h"

#define VIEW_MARGIN 15

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate,EXImagesCollectionDelegate,UITextFieldDelegate,MKMapViewDelegate>{
    IBOutlet UIToolbar *toolbar;
    UITextField *crosstitle;
    UITextField *exfeeInput;
    UILabel *exfeenum;
    MKMapView *map;
    
    UITableView *suggestionTable;
    NSMutableArray *suggestIdentities;
    NSMutableArray *exfeeIdentities;
    Place *place;
    EXImagesCollectionView *exfeeShowview;
}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
- (void) ShowPlaceView;

- (void)textDidChange:(UITextField*)textField;
- (void) addDefaultIdentity;
- (NSString*) findProvider:(NSString*)external_id;
- (void) getIdentity:(NSString*)identity_json;
- (void) setPlace:(NSDictionary*)placedict;
- (void) ShowExfeeInput:(BOOL)show;
- (void) setExfeeNum;

@end

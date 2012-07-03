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

@interface GatherViewController : UIViewController <RKRequestDelegate,RKObjectLoaderDelegate,EXImagesCollectionDataSource,UITableViewDataSource,UITableViewDelegate,EXImagesCollectionDelegate,UITextFieldDelegate,MKMapViewDelegate>{
    IBOutlet UITextField *crosstitle;
    IBOutlet UITextField *ExfeeInput;
    MKMapView *map;
    
    UITableView *suggestionTable;
    NSMutableArray *suggestIdentities;
    NSMutableArray *exfeeIdentities;
    Place *place;
    IBOutlet EXImagesCollectionView *exfeeShowview;
}

- (IBAction) Gather:(id) sender;
- (IBAction) Close:(id) sender;
- (void) ShowPlaceView;

- (IBAction)textDidChange:(UITextField*)textField;
- (IBAction)textEditBegin:(id)textField;
- (void) addDefaultIdentity;
- (NSString*) findProvider:(NSString*)external_id;
- (void) getIdentity:(NSString*)identity_json;
- (void) setPlace:(NSDictionary*)placedict;
@end

//
//  CrossDetailViewController.h
//  EXFE
//
//  Created by Stony Wang on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "EXCurveImageView.h"
#import "Cross.h"
#import "Identity.h"
#import "Exfee.h"
#import "User.h"
#import "Invitation.h"
#import "CrossTime.h"
#import "Place.h"
#import "EXImagesCollectionView.h"

@interface CrossDetailViewController : UIViewController <UITextViewDelegate, EXImagesCollectionDataSource, EXImagesCollectionDelegate>{
    UIScrollView *container;
    EXCurveImageView *dectorView;
    UITextView *descView;
    //EXImagesCollectionView *exfeeShowview;
    UIView *exfeeShowview;
    UILabel *timeRelView;
    UILabel *timeAbsView;
    UILabel *timeZoneView;
    UILabel *placeTitleView;
    UILabel *placeDescView;
    MKMapView *mapView;
    UIButton *btnBack;
    UILabel *titleView;
    
    Cross* cross;
    User* default_user;
    
    BOOL layoutDirty;
    
    NSMutableArray *exfeeIdentities;
}
@property (retain,nonatomic) Cross* cross;
@property (retain,readonly) NSMutableArray *exfeeIdentities;
@property (retain,nonatomic) User* default_user;


- (void)initUI;
- (void)relayoutUI;
- (void)refreshUI;

#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView;

@end

//
//  EFGeomarkPersonCell.h
//  EXFE
//
//  Created by 0day on 13-8-17.
//
//

#import <UIKit/UIKit.h>

@class EFMapPerson, EFMarauderMapDataSource;
@interface EFGeomarkPersonCell : UITableViewCell

@property (nonatomic, weak) EFMapPerson *person;
@property (nonatomic, weak) EFMarauderMapDataSource *mapDataSource;

@end

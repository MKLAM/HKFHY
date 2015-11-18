//
//  DistrictViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月24日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigFinder.h"
#import "DataCollection.h"
#import "District.h"
#import "MessageProcessor.h"
#import "ImageDownloader.h"

@interface DistrictViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate,UIPopoverControllerDelegate, UIAlertViewDelegate>{
    UIActionSheet *actionSheet;
    int level2DistrictID;
    int spotTypeID;
    NSMutableArray *districtList;
    NSMutableArray *spotTypeList;
    NSMutableArray *currentSelectData;
    int currentSelectType;
    NSMutableArray *spotList;
    int districtSelectboxSelectedRow;
    int spotTypeSelectboxSelectedRow;
    MessageProcessor *msg;
    CoreDataHelper *districtDataHelper;
    CoreDataHelper *spotDataHelper;
    CoreDataHelper *photoDataHelper;
    CoreDataHelper *spotTypeDataHelper;
}

@property(nonatomic) int districtID;

@property(nonatomic, retain) IBOutlet UIImageView *mainView;
@property(nonatomic, retain) IBOutlet UIImageView *tableBg;

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

@property(nonatomic, retain) IBOutlet UIButton *HKBtn;
@property(nonatomic, retain) IBOutlet UIButton *KLNBtn;
@property(nonatomic, retain) IBOutlet UIButton *NTBtn;
@property(nonatomic, retain) IBOutlet UIButton *IslandBtn;
@property(nonatomic, retain) IBOutlet UIScrollView *imageList;
@property(nonatomic, retain) IBOutlet UIButton *leftArrow;
@property(nonatomic, retain) IBOutlet UIButton *rightArrow;
@property(nonatomic, retain) IBOutlet UIButton *topArrow;
@property(nonatomic, retain) IBOutlet UIButton *downArrow;
@property(nonatomic, retain) IBOutlet UIButton *districtSelectbox;
@property(nonatomic, retain) IBOutlet UIButton *spotTypeSelectbox;
@property(nonatomic, retain) IBOutlet UITableView *SpotTableView;


-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;

-(IBAction)NextPage:(id)sender;
-(IBAction)PrevPage:(id)sender;
-(IBAction)selectBoxDropDown:(id)sender;
-(void)dismissActionSheet:(id)sender;
-(void)getTableData;
-(IBAction)scrollDown:(id)sender;
-(IBAction)scrollUp:(id)sender;
-(IBAction)ChangeDistrict:(id)sender;
-(IBAction)EnterDetail:(id)sender;
-(void)EnterDetailWith:(int) spotID;

@end

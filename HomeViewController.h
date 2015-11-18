//
//  HomeViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月23日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"
#import "IntroViewController.h"
#import "DistrictViewController.h"
#import "OptinionViewController.h"
#import "GoogleMapViewController.h"
#import "MapViewController.h"
#import "BaiduMapViewController.h"
#import "SettingViewController.h"
#import "SearchViewController.h"
#import "ConfigFinder.h"
#import "DataCollection.h"

@interface HomeViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>{
    MessageProcessor *msg;
    Reachability *internetReach;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scroll;
@property(nonatomic, retain) IBOutlet UIButton *link1;
@property(nonatomic, retain) IBOutlet UIButton *link2;
@property(nonatomic, retain) IBOutlet UIImageView *scrollBg;
@property(nonatomic, retain) IBOutlet UIButton *hkBtn;
@property(nonatomic, retain) IBOutlet UIButton *klnBtn;
@property(nonatomic, retain) IBOutlet UIButton *ntBtn;
@property(nonatomic, retain) IBOutlet UIButton *islandBtn;
@property(nonatomic, retain) IBOutlet UIButton *tolletBtn;
@property(nonatomic, retain) IBOutlet UIButton *parkBtn;
@property(nonatomic, retain) IBOutlet UIButton *searchBtn;
@property(nonatomic, retain) IBOutlet UIButton *formBtn;
@property(nonatomic, retain) IBOutlet UIButton *introBtn;
@property(nonatomic, retain) IBOutlet UIButton *settingBtn;
@property(nonatomic, retain) IBOutlet UITextField *keywordField;
@property(nonatomic, retain) IBOutlet UIButton *submitSearchBtn;
@property(nonatomic, retain) IBOutlet UIImageView *bottomLabel;

@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(void)dismissKeyboard;
-(void)toSearch;
-(IBAction)launchWebSite:(id)sender;
-(IBAction)toNextView:(id)sender;
-(IBAction)submitSearch;
-(void) startDownload;

@end

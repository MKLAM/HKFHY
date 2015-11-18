//
//  SettingViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月1日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"

@interface SettingViewController : UIViewController{
    MessageProcessor *msg;
}

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UILabel *mapLbl;
@property(nonatomic, retain) IBOutlet UISegmentedControl *mapSegment;
@property(nonatomic, retain) IBOutlet UILabel *languageLbl;
@property(nonatomic, retain) IBOutlet UISegmentedControl *languageSegment;
@property(nonatomic, retain) IBOutlet UILabel *sizeLbl;
@property(nonatomic, retain) IBOutlet UISegmentedControl *sizeSegment;


-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)ChangeMap:(id)sender;
-(IBAction)BackHome:(id)sender;

@end

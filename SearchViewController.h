//
//  SearchViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月1日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"
#import "Spot.h"
#import "CoreDataHelper.h"
#import "Photo.h"
#import "SearchResultCell.h"
#import "SpotViewController.h"
#import "DataCollection.h"
#import "ImageDownloader.h"

@interface SearchViewController : UIViewController<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>{
    MessageProcessor *msg;
    NSMutableArray *resultList;
    DataCollection *dataColl;
}

@property(nonatomic, retain) NSString *keyword;

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

@property(nonatomic, retain) IBOutlet UITextField *keywordField;
@property(nonatomic, retain) IBOutlet UIButton *submitBtn;
@property(nonatomic, retain) IBOutlet UIButton *scrollUp;
@property(nonatomic, retain) IBOutlet UIButton *scrollDown;
@property(nonatomic, retain) IBOutlet UITableView *resultTableView;

-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;
-(void)dismissKeyboard;
-(void)getTableData;
-(IBAction)scrollDown:(id)sender;
-(IBAction)scrollUp:(id)sender;

@end

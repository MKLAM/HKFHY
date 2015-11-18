//
//  OptinionViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月29日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"
#import "CoreDataHelper.h"
#import "Spot.h"
#import "Reachability.h"
#import "JSON.h"

@interface OptinionViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate>{
    MessageProcessor *msg;
    NSString *formType;
}

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

@property(nonatomic, retain) IBOutlet UIButton *tab1;
@property(nonatomic, retain) IBOutlet UIButton *tab2;
@property(nonatomic, retain) IBOutlet UIButton *tab3;
@property(nonatomic, retain) IBOutlet UITextField *nameField;
@property(nonatomic, retain) IBOutlet UITextField *emailField;
@property(nonatomic, retain) IBOutlet UITextField *phoneField;
@property(nonatomic, retain) IBOutlet UITextField *remarkField;
@property(nonatomic, retain) IBOutlet UIButton *submitBtn;
@property(nonatomic, retain) IBOutlet UIButton *resetBtn;
@property(nonatomic, retain) IBOutlet UIScrollView *formScrollView;
@property(nonatomic, retain) IBOutlet UITextView *textArea;

-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;
-(void)dismissKeyboard;
-(IBAction)ResetForm;
-(IBAction)SubmitForm;
-(BOOL)PostToServer;
-(IBAction)ChangeTab:(id)sender;

@end

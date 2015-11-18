//
//  SpotOpinionViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月27日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"
#import "CoreDataHelper.h"
#import "Spot.h"
#import "Reachability.h"
#import "JSON.h"

@interface SpotOpinionViewController : UIViewController<UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    MessageProcessor *msg;
    Spot *spotDetail;
}

@property(nonatomic) int spotID;

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

@property(nonatomic, retain) IBOutlet UIView *pageTitle;
@property(nonatomic, retain) IBOutlet UITextField *nameField;
@property(nonatomic, retain) IBOutlet UITextField *emailField;
@property(nonatomic, retain) IBOutlet UITextField *phoneField;
@property(nonatomic, retain) IBOutlet UITextField *remarkField;
@property(nonatomic, retain) IBOutlet UIButton *uploadBtn;
@property(nonatomic, retain) IBOutlet UIButton *submitBtn;
@property(nonatomic, retain) IBOutlet UIButton *resetBtn;
@property(nonatomic, retain) IBOutlet UIImageView *imagePreview;
@property(nonatomic, retain) IBOutlet UIScrollView *formScrollView;
@property(nonatomic, retain) IBOutlet UITextView *textArea;

-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;
-(void)dismissKeyboard;
-(IBAction)SelectImage;
-(void)FromCam;
-(void)FromLibrary;
-(IBAction)ResetForm;
-(IBAction)SubmitForm;
-(BOOL)PostToServer;

@end

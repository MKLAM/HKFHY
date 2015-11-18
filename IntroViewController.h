//
//  IntroViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月24日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroViewController : UIViewController{
    NSTimer* holdTimer;
}

@property(nonatomic, retain) IBOutlet UIImageView *whole_bg;
@property(nonatomic, retain) IBOutlet UIImageView *intro_bg;
@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) IBOutlet UIButton *scrollUpBtn;
@property(nonatomic, retain) IBOutlet UIButton *scrollDownBtn;

@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;

-(IBAction)startScrollTo:(id)sender;
-(IBAction)stopScrollTo:(id)sender;
-(void) moveDown;
-(void) moveUp;

@end

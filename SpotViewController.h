//
//  SpotViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月26日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageProcessor.h"
#import "CoreDataHelper.h"
#import "Spot.h"
#import "Photo.h"
#import "NSString+HTML.h"
#import "SpotOpinionViewController.h"
#import "BaiduMapViewController.h"
#import "GoogleMapViewController.h"
#import "MapViewController.h"
#import "ConfigFinder.h"
#import "DataCollection.h"
#import "Rated.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ImageDownloader.h"

@interface SpotViewController : UIViewController<UIWebViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate>{
    MessageProcessor *msg;
    Spot *spotDetail;
    NSTimer* holdTimer;
    UIWebView *focusView;
    UIActionSheet *actionSheet;
    Reachability *internetReach;
    NSString *photoOrgPath;
}

@property(nonatomic) int spotID;


@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *languageChangeBtn;
@property(nonatomic, retain) IBOutlet UIButton *fontSizeChangeBtn;

@property(nonatomic, retain) IBOutlet UILabel *pageTitle;
@property(nonatomic, retain) IBOutlet UIScrollView *thumbnailView;
@property(nonatomic, retain) IBOutlet UILabel *rankTitle;
@property(nonatomic, retain) IBOutlet UILabel *rankPeopleNumber;
@property(nonatomic, retain) IBOutlet UIImageView *star1;
@property(nonatomic, retain) IBOutlet UIImageView *star2;
@property(nonatomic, retain) IBOutlet UIImageView *star3;
@property(nonatomic, retain) IBOutlet UIImageView *star4;
@property(nonatomic, retain) IBOutlet UIImageView *star5;
@property(nonatomic, retain) IBOutlet UIWebView *mainContentView;
@property(nonatomic, retain) IBOutlet UIWebView *transportContentView;
@property(nonatomic, retain) IBOutlet UIWebView *infoContentView;
@property(nonatomic, retain) IBOutlet UIButton *contentBtn;
@property(nonatomic, retain) IBOutlet UIButton *transportBtn;
@property(nonatomic, retain) IBOutlet UIButton *infoBtn;
@property(nonatomic, retain) IBOutlet UIButton *mapBtn;
@property(nonatomic, retain) IBOutlet UIButton *fbBtn;
@property(nonatomic, retain) IBOutlet UIButton *opinionBtn;
@property(nonatomic, retain) IBOutlet UIButton *scrollDown;
@property(nonatomic, retain) IBOutlet UIButton *scrollUp;
@property(nonatomic, retain) IBOutlet UIButton *voteBtn;


-(void) loadData;
-(void) setLayout;
-(IBAction)ChangeLanguage:(id)sender;
-(IBAction)ChangeFont:(id)sender;
-(IBAction)BackHome:(id)sender;

-(IBAction)changeContent:(id)sender;
-(void)doHighlight:(UIButton*)btn;
-(IBAction)startScrollTo:(id)sender;
-(IBAction)stopScrollTo:(id)sender;
-(void) moveDown;
-(void) moveUp;
-(void) setStarBy:(int)rate;
-(IBAction)VoteRate:(id)sender;
-(IBAction)GotoOptinion:(id)sender;
-(IBAction)GotoMap;
-(BOOL)postToServer:(NSInteger) rate;
- (NSDictionary*)parseURLParams:(NSString *)query;
-(IBAction)shareToFacebook;
-(NSString *)GetUUID;

@end

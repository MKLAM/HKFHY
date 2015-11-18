//
//  HomeViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月23日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

@synthesize scroll, link1, link2, scrollBg, hkBtn, klnBtn, ntBtn, islandBtn, tolletBtn, parkBtn, searchBtn, formBtn, introBtn, settingBtn, languageChangeBtn, keywordField, fontSizeChangeBtn, bottomLabel, submitSearchBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    msg = [[MessageProcessor alloc] init];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    [tap release];
    [keywordField setDelegate:self];
    [self setLayout];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus != NotReachable && [[msg ReadSetting:@"location_loaded"] isEqualToString:@"0"]){
        [self startDownload];
    }else{
        [self loadData];
    }
    
}

-(void) loadData{
    NSString *language = [msg ReadSetting:@"language"];
    
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", language]] forState:UIControlStateNormal];
    if(IPAD){
        [bottomLabel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ipad_bottom_link_layer_%@.png", language]]];
    }else{
        [bottomLabel setImage:[UIImage imageNamed:[NSString stringWithFormat:@"bottom_link_layer_%@.png", language]]];
    }
    
    [hkBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"hk_btn_%@.png", language]] forState:UIControlStateNormal];
    [klnBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kln_btn_%@.png", language]] forState:UIControlStateNormal];
    [ntBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"nt_btn_%@.png", language]] forState:UIControlStateNormal];
    [islandBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"island_btn_%@.png", language]] forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"search_btn_%@.png", language]] forState:UIControlStateNormal];
    [tolletBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"tollet_btn_%@.png", language]] forState:UIControlStateNormal];
    [parkBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"park_btn_%@.png", language]] forState:UIControlStateNormal];
    [formBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"form_btn_%@.png", language]] forState:UIControlStateNormal];
    [introBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro_btn_%@.png", language]] forState:UIControlStateNormal];
    [settingBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"setting_btn_%@.png", language]] forState:UIControlStateNormal];
    
    [keywordField setPlaceholder:[msg GetString:@"search_placeholder"]];
    
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    [hkBtn setAccessibilityLabel:[msg GetString:@"a_HK"]];
    [klnBtn setAccessibilityLabel:[msg GetString:@"a_KLN"]];
    [ntBtn setAccessibilityLabel:[msg GetString:@"a_NT"]];
    [islandBtn setAccessibilityLabel:[msg GetString:@"a_islands"]];
    [searchBtn setAccessibilityLabel:[msg GetString:@"a_search_page"]];
    [tolletBtn setAccessibilityLabel:[msg GetString:@"a_tollet"]];
    [parkBtn setAccessibilityLabel:[msg GetString:@"a_park"]];
    [formBtn setAccessibilityLabel:[msg GetString:@"a_opinion"]];
    [introBtn setAccessibilityLabel:[msg GetString:@"a_intro"]];
    [settingBtn setAccessibilityLabel:[msg GetString:@"a_setting"]];
    [link1 setAccessibilityLabel:[msg GetString:@"a_link_1"]];
    [link2 setAccessibilityLabel:[msg GetString:@"a_link_2"]];
    [submitSearchBtn setAccessibilityLabel:[msg GetString:@"a_search_sumbit"]];
}

-(void) startDownload{
    UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"download_data"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    [loadingView show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
        DataCollection *dataCollection = [[DataCollection alloc] init];
        [dataCollection downloadLocation];
        [dataCollection release];
        [msg SaveSettingTo:@"location_loaded" withValue:@"1"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView dismissWithClickedButtonIndex:0 animated:YES];
            [self loadData];
        });
    });
}

-(void) willPresentAlertView:(UIAlertView *)alertView{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alertView.bounds.size.width / 2, alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [alertView addSubview:indicator];
    [indicator release];
}

-(void) setLayout{
    
    scroll.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    keywordField.leftView = paddingView;
    keywordField.leftViewMode = UITextFieldViewModeAlways;
    [paddingView release];
}

-(IBAction)ChangeLanguage:(id)sender{
    [msg ChangeLanguage];
    [self loadData];
}

-(IBAction)ChangeFont:(id)sender{
    [msg ChangeFont];
}

-(void)dismissKeyboard {
    [keywordField resignFirstResponder];
}

-(void)toSearch{
    SearchViewController *view = [[SearchViewController alloc] initWithNibName:[msg GetLayoutType:@"SearchViewController"] bundle:nil];
    view.keyword = keywordField.text;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(IBAction)launchWebSite:(id)sender{
    UIButton *instanceButton = (UIButton*)sender;
    NSString *url;
    if(instanceButton.tag == 0){
        url = @"http://www.hkfhy.org.hk";
    }else{
        url = @"http://www.ogcio.gov.hk";
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: url]];
}

-(IBAction)toNextView:(id)sender{
    UIButton *clickedBtn = sender;
    
    switch (clickedBtn.tag) {
        case 0:{
                DistrictViewController *view = [[DistrictViewController alloc] initWithNibName:[msg GetLayoutType:@"DistrictViewController"] bundle:nil];
                view.districtID = 1;
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 1:{
                DistrictViewController *view = [[DistrictViewController alloc] initWithNibName:[msg GetLayoutType:@"DistrictViewController"] bundle:nil];
                view.districtID = 2;
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 2:{
                DistrictViewController *view = [[DistrictViewController alloc] initWithNibName:[msg GetLayoutType:@"DistrictViewController"] bundle:nil];
                view.districtID = 3;
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 3:{
                DistrictViewController *view = [[DistrictViewController alloc] initWithNibName:[msg GetLayoutType:@"DistrictViewController"] bundle:nil];
                view.districtID = 4;
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 4:{
                if([[msg ReadSetting:@"map_type"] isEqualToString:@"0"]){
                    if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"5.1")){
                        MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
                        view.has_tollet = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }else{
                        GoogleMapViewController *view = [[GoogleMapViewController alloc] initWithNibName:[msg GetLayoutType:@"GoogleMapViewController"] bundle:nil];
                        view.has_tollet = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }
                }else{
                    if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"4.3")){
                        MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
                        view.has_tollet = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }else{
                        BaiduMapViewController *view = [[BaiduMapViewController alloc] initWithNibName:[msg GetLayoutType:@"BaiduMapViewController"] bundle:nil];
                        view.has_tollet = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }
                }
            }
            break;
        case 5:{
                if([[msg ReadSetting:@"map_type"] isEqualToString:@"0"]){
                    if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"5.1")){
                        MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
                        view.has_park = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }else{
                        GoogleMapViewController *view = [[GoogleMapViewController alloc] initWithNibName:[msg GetLayoutType:@"GoogleMapViewController"] bundle:nil];
                        view.has_park = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }
                }else{
                    if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"4.3")){
                        MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
                        view.has_park = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }else{
                        BaiduMapViewController *view = [[BaiduMapViewController alloc] initWithNibName:[msg GetLayoutType:@"BaiduMapViewController"] bundle:nil];
                        view.has_park = YES;
                        [self.navigationController pushViewController:view animated:YES];
                        [view release];
                    }
                }
            }
            break;
        case 6: [self toSearch];
            break;
        case 7:{
                OptinionViewController *view = [[OptinionViewController alloc] initWithNibName:[msg GetLayoutType:@"OptinionViewController"] bundle:nil];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 8:{
                IntroViewController *view = [[IntroViewController alloc] initWithNibName:[msg GetLayoutType:@"IntroViewController"] bundle:nil];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        case 9:{
                SettingViewController *view = [[SettingViewController alloc] initWithNibName:[msg GetLayoutType:@"SettingViewController"] bundle:nil];
                [self.navigationController pushViewController:view animated:YES];
                [view release];
            }
            break;
        default:
            break;
    }
}

-(IBAction)submitSearch{
    if([keywordField.text length]>0){
        [self toSearch];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([keywordField.text length]>0){
        [self toSearch];
    }
    // We do not want UITextField to insert line-breaks.
    return NO;
}

- (void)dealloc {
    [scroll release];
    [link1 release];
    [link2 release];
    [scrollBg release];
    [hkBtn release];
    [klnBtn release];
    [ntBtn release];
    [islandBtn release];
    [tolletBtn release];
    [parkBtn release];
    [searchBtn release];
    [formBtn release];
    [introBtn release];
    [settingBtn release];
    [keywordField release];
    [submitSearchBtn release];
    [bottomLabel release];
    [languageChangeBtn release];
    [fontSizeChangeBtn release];
    [msg release];
    [internetReach release];
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end

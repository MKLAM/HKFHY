//
//  ViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月17日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "ViewController.h"
#import "DataCollection.h"
#import "MessageProcessor.h"

@implementation ViewController

@synthesize lanuchImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
            UIImage *image = [UIImage imageNamed: @"splash-568h@2x.png"];
            [lanuchImage setImage:image];
        } 
    }
    if(IPAD){
        UIImage *image = [UIImage imageNamed: @"ipad_splash.png"];
        [lanuchImage setImage:image];
    }
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [self lanuchChecking];
    
}

-(void) lanuchChecking{
    msg = [MessageProcessor alloc];
    [msg createUserFile];
    
    DataCollection *dataCollection = [[DataCollection alloc] init];
    
    NSString *sysLang = [msg ReadSetting:@"language"];
    
    if ( [sysLang length] == 0 ){
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        if([language rangeOfString:@"zh" options:NSCaseInsensitiveSearch].location == NSNotFound){
            [msg SaveSettingTo:@"language" withValue:@"en"];
        }else{
            [msg SaveSettingTo:@"language" withValue:@"zh_Hant"];
        }
    }
    
    NSString *version = [msg ReadSetting:@"db_version"];
    [internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    Boolean needUpdate = NO;
    if(netStatus == NotReachable){
        if([version isEqualToString:@"0"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"first_download"] delegate:self cancelButtonTitle:nil otherButtonTitles: [msg GetString:@"ok"], nil];
            [alert show];
            [alert release];
            needUpdate = YES;
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"no_network"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }else{
        NSString *db_version = [dataCollection checkVersion];
        
        if(![version isEqualToString:db_version]){
            needUpdate = YES;
            if([version isEqualToString:@"0"]){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"first_download"] delegate:self cancelButtonTitle:nil otherButtonTitles: [msg GetString:@"ok"], nil];
                [alert show];
                [alert release];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"3G_msg"] delegate:self cancelButtonTitle:nil otherButtonTitles: [msg GetString:@"ok"], [msg GetString:@"cancel"], nil];
                alert.tag = 2;
                [alert show];
                [alert release];
            }
        }
    }
    if(!needUpdate){
        HomeViewController *homePage = [[HomeViewController alloc] initWithNibName:[msg GetLayoutType:@"HomeViewController"] bundle:nil];
        [self.navigationController pushViewController:homePage animated:YES];
        [homePage release];
    }
    [dataCollection release];
    
}

-(void) startDownload{
    [msg createUserFile];
    loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"download_data"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    loadingView.tag = 1;
    [msg SaveSettingTo:@"location_loaded" withValue:@"0"];
    
    [loadingView show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
        DataCollection *dataCollection = [[DataCollection alloc] init];
        [dataCollection downloadPatch];
        [msg SaveSettingTo:@"db_version" withValue:[dataCollection checkVersion]];
        [dataCollection release];
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView dismissWithClickedButtonIndex:0 animated:YES];
            HomeViewController *homePage = [[HomeViewController alloc] initWithNibName:[msg GetLayoutType:@"HomeViewController"] bundle:nil];
            [self.navigationController pushViewController:homePage animated:YES];
            [homePage release];
        });
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 2){
        if(buttonIndex == 0){
            [self startDownload];
        }else{
            HomeViewController *homePage = [[HomeViewController alloc] initWithNibName:[msg GetLayoutType:@"HomeViewController"] bundle:nil];
            [self.navigationController pushViewController:homePage animated:YES];
            [homePage release];
        }
    }else{
        [internetReach startNotifier];
        
        NetworkStatus netStatus = [internetReach currentReachabilityStatus];
        if(netStatus == NotReachable){
            [self lanuchChecking];
        }else{
            [self startDownload];
        }
    }
}

-(void) willPresentAlertView:(UIAlertView *)alertView{
    if(alertView.tag == 1){
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height - 50);
        [indicator startAnimating];
        [alertView addSubview:indicator];
        [indicator release];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

-(void)dealloc{
    [msg release];
    [lanuchImage release];
    [internetReach release];
    [super dealloc];
}

@end

//
//  SpotViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月26日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "SpotViewController.h"


@implementation SpotViewController
@synthesize homeBtn,fontSizeChangeBtn,languageChangeBtn, pageTitle, thumbnailView, rankPeopleNumber, rankTitle, star1,star2, star3, star4, star5, mainContentView, transportContentView, infoContentView, contentBtn, transportBtn, infoBtn, mapBtn, fbBtn, opinionBtn, scrollDown, scrollUp, voteBtn;

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
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    msg = [[MessageProcessor alloc] init];
    [mainContentView setDelegate:self];
    [transportContentView setDelegate:self];
    [infoContentView setDelegate:self];
    focusView = mainContentView;
    //[self loadData];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"loading"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    [loadingView show];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
    });
}

-(void) willPresentAlertView:(UIAlertView *)alertView{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alertView.bounds.size.width / 2, alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [alertView addSubview:indicator];
    [indicator release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) loadData{
    NSString *language = [msg ReadSetting:@"language"];
    int currentFontSize = [[msg ReadSetting:@"font_size"] integerValue];
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", language]] forState:UIControlStateNormal];
    
    rankTitle.text = [msg GetString:@"rank_title"];
    
    CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    CoreDataHelper *photoDataHelper = [[CoreDataHelper alloc] init];
    photoDataHelper.entityName = @"Photo";
    photoDataHelper.defaultSortAttribute = @"id";
    [photoDataHelper setupCoreData];
    
    int thisId = self.spotID;
    NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND record_id = %d", language, thisId];
    
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    
    if([spotDataHelper.fetchedResultsController.fetchedObjects count] > 0 ){
        spotDetail = (Spot*) [spotDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
        pageTitle.text = spotDetail.title;
        
        [internetReach startNotifier];
        NetworkStatus netStatus = [internetReach currentReachabilityStatus];
        if(netStatus != NotReachable){
            DataCollection *datacollection = [[DataCollection alloc] init];
            NSDictionary *result = [datacollection getRateBy:self.spotID];
            if([result count] > 0){
                spotDetail.rate = [result objectForKey:@"rate"];
                spotDetail.total_rated = [result objectForKey:@"total_rated"];
                [spotDataHelper save];
            }
            [datacollection release];
        }
        
        rankPeopleNumber.text = [NSString stringWithFormat:[msg GetString:@"rank_people"], spotDetail.total_rated];
        [voteBtn setAccessibilityValue:[NSString stringWithFormat:[msg GetString:@"a_current_mark"], spotDetail.total_rated]];
        [self setStarBy:[spotDetail.rate intValue]];
        
        //DataCollection *dataColl = [[DataCollection alloc] init];
        ImageDownloader *downloader = [[[ImageDownloader alloc] init] autorelease];
        NSPredicate *photoQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND parent_id = %d", language, thisId];
        [photoDataHelper fetchItemsMatching:photoQuery sortingBy:@"id" asc:YES];
        CGFloat nextX = 0;
        if([photoDataHelper.fetchedResultsController.fetchedObjects count] > 0){
            for(Photo *photo in photoDataHelper.fetchedResultsController.fetchedObjects){
                if([photoOrgPath length]==0){
                    photoOrgPath = photo.org_path;
                }
                UIImageView *thumbnail = [[UIImageView alloc] init];
                //UIImage *img = [dataColl downloadImageFrom:photo.file_name currentPath:photo.org_path photoID:photo.id asyncToImage:thumbnail];
                UIImage *img = [downloader addtoList:photo.file_name Source:photo.org_path saveTo:photo.id placeToView:thumbnail];
                [thumbnail setImage:img];
                
                if(IPAD){
                    [thumbnail setFrame:CGRectMake(nextX, 0, 230, 147)];
                }else{
                    [thumbnail setFrame:CGRectMake(nextX, 0, 142, 99)];
                }
                
                [thumbnail setContentMode:UIViewContentModeScaleToFill];
                [thumbnail setAccessibilityLabel:photo.alt_text];
                [thumbnailView addSubview:thumbnail];
                [thumbnail release];
                if(IPAD){
                    nextX += 230;
                }else{
                    nextX += 142;
                }
            }
            [downloader startDownloadImage];
        }else{
            UIImage *img = [UIImage imageNamed:@"default_image.png"];
            UIImageView *thumbnail = [[UIImageView alloc] initWithImage:img];
            if(IPAD){
                [thumbnail setFrame:CGRectMake(nextX, 0, 230, 147)];
            }else{
                [thumbnail setFrame:CGRectMake(nextX, 0, 142, 99)];
            }
            [thumbnail setContentMode:UIViewContentModeScaleToFill];
            [thumbnailView addSubview:thumbnail];
            [thumbnail release];
        }
        if(IPAD){
            thumbnailView.contentSize = CGSizeMake(nextX, 147);
        }else{
            thumbnailView.contentSize = CGSizeMake(nextX, 99);
        }
        
        //[dataColl release];
        NSURL *baseUrl = [NSURL URLWithString:[msg ReadSetting:@"domain"]];
        NSString *htmlCode = [[NSString alloc] initWithFormat:@"<html><style>body{font-size: %d px; }</style><body> %@ </body></html>", currentFontSize+14, [spotDetail.content kv_decodeHTMLCharacterEntities]];
        //NSLog(@"%@", htmlCode);
        [mainContentView loadHTMLString:htmlCode baseURL:baseUrl];
        [htmlCode release];
        
        NSString *transportHtmlCode = [[NSString alloc] initWithFormat:@"<html><style>body{font-size: %d px}</style><body> %@ </body></html>", currentFontSize+14, [spotDetail.transport kv_decodeHTMLCharacterEntities]];
        [transportContentView loadHTMLString:transportHtmlCode baseURL:baseUrl];
        [transportHtmlCode release];
        
        NSString *infoHtmlCode = [[NSString alloc] initWithFormat:@"<html><style>body{font-size: %d px}</style><body> %@ </body></html>", currentFontSize+14, [spotDetail.info kv_decodeHTMLCharacterEntities]];
        [infoContentView loadHTMLString:infoHtmlCode baseURL:baseUrl];
        [infoHtmlCode release];
    }
    [spotDataHelper release];
    [photoDataHelper release];
    
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [scrollDown setAccessibilityLabel:[msg GetString:@"a_scroll_down"]];
    [scrollUp setAccessibilityLabel:[msg GetString:@"a_scroll_up"]];
    [contentBtn setAccessibilityLabel:[msg GetString:@"a_content"]];
    [transportBtn setAccessibilityLabel:[msg GetString:@"a_transport"]];
    [infoBtn setAccessibilityLabel:[msg GetString:@"a_info"]];
    [mapBtn setAccessibilityLabel:[msg GetString:@"a_go_map"]];
    [fbBtn setAccessibilityLabel:[msg GetString:@"a_facebook"]];
    [opinionBtn setAccessibilityLabel:[msg GetString:@"a_spot_opinion"]];
    [voteBtn setAccessibilityHint:[msg GetString:@"a_click_vote"]];
}

-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
            
        }
    }
}
-(IBAction)ChangeLanguage:(id)sender{
    [msg ChangeLanguage];
    [self loadData];
}

-(IBAction)ChangeFont:(id)sender{
    [msg ChangeFont];
    [self loadData];
}

-(IBAction)BackHome:(id)sender{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)changeContent:(id)sender{
    UIButton *clickedBtn = sender;
    [contentBtn setHighlighted:NO];
    [transportBtn setHighlighted:NO];
    [infoBtn setHighlighted:NO];
    [mainContentView setHidden:YES];
    [transportContentView setHidden:YES];
    [infoContentView setHidden:YES];
    if(clickedBtn.tag == 1){
        [transportContentView setHidden:NO];
        focusView = transportContentView;
    }else if(clickedBtn.tag == 2){
        [infoContentView setHidden:NO];
        focusView = infoContentView;
    }else{
        [mainContentView setHidden:NO];
        focusView = mainContentView;
    }
    [self performSelector:@selector(doHighlight:) withObject:sender afterDelay:0];
}

- (void)doHighlight:(UIButton*)btn {
    [btn setHighlighted:YES];
}

-(void) setStarBy:(int)rate{
    if(rate>0){
        [star1 setHighlighted:YES];
        if(rate>1){
            [star2 setHighlighted:YES];
            if(rate > 2){
                [star3 setHighlighted:YES];
                if(rate > 3){
                    [star4 setHighlighted:YES];
                    if(rate > 4){
                        [star5 setHighlighted:YES];
                    }
                }
            }
        }
    }
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

-(IBAction)startScrollTo:(id)sender{
    UIButton *clickedBtn = sender;
    if(clickedBtn.tag == 0){
        holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveUp) userInfo:nil repeats:YES];
    }else{
        holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(moveDown) userInfo:nil repeats:YES];
    }
    [holdTimer retain];
}
-(IBAction)stopScrollTo:(id)sender{
    [holdTimer invalidate];
    [holdTimer release];
    holdTimer = nil;
}

-(void) moveDown{
    CGFloat step = 20.0f;
    CGFloat offset = focusView.scrollView.contentOffset.y;
    CGFloat nextPostion;
    CGFloat height = focusView.scrollView.contentSize.height - focusView.scrollView.bounds.size.height;
    if(offset+step > height){
        nextPostion = height;
    }else{
        nextPostion = offset+step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [focusView.scrollView setContentOffset:targetPostion animated:YES];
}
-(void) moveUp{
    CGFloat step = 20.0f;
    CGFloat offset = focusView.scrollView.contentOffset.y;
    CGFloat nextPostion;
    if(offset-step < 0){
        nextPostion = 0;
    }else{
        nextPostion = offset-step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [focusView.scrollView setContentOffset:targetPostion animated:YES];
}

-(IBAction)VoteRate:(id)sender{
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus == NotReachable){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"network_alert_title"] message:[msg GetString:@"no_network"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles:nil];
        [alert show];
        [alert release];
    }else{
        CoreDataHelper *ratedDataHelper = [[CoreDataHelper alloc] init];
        ratedDataHelper.entityName = @"Rated";
        ratedDataHelper.defaultSortAttribute = @"id";
        [ratedDataHelper setupCoreData];
        NSPredicate *ratedQuery = [NSPredicate predicateWithFormat:@"record_id = %d", self.spotID];
        
        [ratedDataHelper fetchItemsMatching:ratedQuery sortingBy:@"id"];
        if([ratedDataHelper.fetchedResultsController.fetchedObjects count]>0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"rated_title"] message:[msg GetString:@"rated_msg"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles:nil];
            [alert show];
            [alert release];
        }else{
            actionSheet = [[UIActionSheet alloc] initWithTitle:[msg GetString:@"your_rating"] delegate:self cancelButtonTitle:[msg GetString:@"cancel"] destructiveButtonTitle:nil otherButtonTitles:@"0", @"1", @"2", @"3", @"4", @"5", nil];
            
            [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

            [actionSheet showInView:self.view];
            [actionSheet release];
        }
        [ratedDataHelper release];
    }

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 6) return;
    BOOL result = [self postToServer:buttonIndex];
    if(result){
        CoreDataHelper *ratedDataHelper = [[CoreDataHelper alloc] init];
        ratedDataHelper.entityName = @"Rated";
        ratedDataHelper.defaultSortAttribute = @"id";
        [ratedDataHelper setupCoreData];
        Rated *rated = (Rated *)[ratedDataHelper newObject];
        rated.record_id = [NSNumber numberWithInt:self.spotID];
        rated.id = [NSNumber numberWithInt:self.spotID];
        [ratedDataHelper save];
        [ratedDataHelper release];
        DataCollection *datacollection = [[DataCollection alloc] init];
        NSDictionary *result = [datacollection getRateBy:self.spotID];
        rankPeopleNumber.text = [NSString stringWithFormat:[msg GetString:@"rank_people"], [result objectForKey:@"total_rated"]];
        [voteBtn setAccessibilityValue:[NSString stringWithFormat:[msg GetString:@"a_current_mark"], [result objectForKey:@"total_rated"]]];
        [self setStarBy:[[result objectForKey:@"rate"] intValue]];
        [datacollection release];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[msg GetString:@"rated_title"] message:[msg GetString:@"rated_thank"] delegate:nil cancelButtonTitle:[msg GetString:@"ok"] otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (NSString *)GetUUID
{
    NSString *uuid = nil;
    CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
    if (theUUID) {
        uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
        [uuid autorelease];
        CFRelease(theUUID);
    }
    return uuid;
}

-(BOOL)postToServer:(NSInteger) rate{
    NSString *udid;
    
    if([[msg ReadSetting:@"uuid"] isEqualToString:@"0"]){
        udid = [self GetUUID];
        [msg SaveSettingTo:@"uuid" withValue:udid];
    }else{
        udid = [msg ReadSetting:@"uuid"];
    }
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@", [msg ReadSetting:@"domain"], [msg ReadSetting:@"rating_feed"]];
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [urlString release];
    NSMutableData *body = [NSMutableData data];
    
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%d", self.spotID] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"rate\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%ld", (long)rate] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_os\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"ios" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    

    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"device_id\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[udid dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    //return and test
    NSError *error = nil;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    
    if(error){
        [returnString release];
        return NO;
    }else{
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *output = [parser objectWithString:returnString];
        BOOL result = [[output objectForKey:@"success"] intValue] == 1;
        [parser release];
        [returnString release];
        return result;
    }
    return NO;
}

-(IBAction)GotoOptinion:(id)sender{
    SpotOpinionViewController *view = [[SpotOpinionViewController alloc] initWithNibName:[msg GetLayoutType:@"SpotOpinionViewController"] bundle:nil];
    view.spotID = self.spotID;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(IBAction)GotoMap{
    if([[msg ReadSetting:@"map_type"] isEqualToString:@"0"]){
        if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"5.1")){
            MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
            view.spotID = self.spotID;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }else{
            GoogleMapViewController *view = [[GoogleMapViewController alloc] initWithNibName:[msg GetLayoutType:@"GoogleMapViewController"] bundle:nil];
            view.spotID = self.spotID;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }else{
        if(SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(@"4.3")){
            MapViewController *view = [[MapViewController alloc] initWithNibName:[msg GetLayoutType:@"MapViewController"] bundle:nil];
            view.spotID = self.spotID;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }else{
            BaiduMapViewController *view = [[BaiduMapViewController alloc] initWithNibName:[msg GetLayoutType:@"BaiduMapViewController"] bundle:nil];
            view.spotID = self.spotID;
            [self.navigationController pushViewController:view animated:YES];
            [view release];
        }
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(IBAction)shareToFacebook{
    NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     spotDetail.title, @"name",
     //@"", @"caption",
     spotDetail.short_description, @"description",
     [NSString stringWithFormat:@"%@%@",[msg GetString:@"hkfhy_spot"], spotDetail.record_id], @"link",
     [NSString stringWithFormat:@"%@%@", [msg ReadSetting:@"domain"], photoOrgPath], @"picture",
     nil];
    
    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             } else {
                 // Handle the publish feed callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // User clicked the Share button
                 }
             }
         }
     }];
}

-(void) dealloc{
    [homeBtn release];
    [languageChangeBtn release];
    [fontSizeChangeBtn release];
    [pageTitle release];
    [thumbnailView release];
    [rankTitle release];
    [rankPeopleNumber release];
    [star1 release];
    [star2 release];
    [star3 release];
    [star4 release];
    [star5 release];
    [mainContentView release];
    [transportContentView release];
    [infoContentView release];
    [contentBtn release];
    [transportBtn release];
    [infoBtn release];
    [photoOrgPath release];
    [internetReach release];
    [spotDetail release];
    [msg release];
    [super dealloc];
}

@end

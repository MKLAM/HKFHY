//
//  IntroViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月24日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "IntroViewController.h"
#import "MessageProcessor.h"
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "Page.h"
#import "NSString+HTML.h"

@implementation IntroViewController

@synthesize whole_bg, intro_bg, webView, languageChangeBtn, fontSizeChangeBtn, scrollDownBtn, scrollUpBtn, homeBtn;

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
    // Do any additional setup after loading the view from its nib.
    [self setLayout];
    [self loadData];
}

-(void) loadData{
    MessageProcessor *msg = [[MessageProcessor alloc] init];
    NSString *language = [msg ReadSetting:@"language"];
    
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", language]] forState:UIControlStateNormal];
    int currentFontSize = [[msg ReadSetting:@"font_size"] integerValue];
    
    CoreDataHelper *pageDataHelper = [[CoreDataHelper alloc] init];
    pageDataHelper.entityName = @"Page";
    pageDataHelper.defaultSortAttribute = @"seq";
    [pageDataHelper setupCoreData];
    
    [pageDataHelper fetchItemsMatching:language forAttribute:@"lang" sortingBy:@"id"];
    Page *page = [pageDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
    NSURL *baseUrl = [NSURL URLWithString:[msg ReadSetting:@"domain"]];
    NSString *htmlCode = [NSString stringWithFormat:@"<html><style>body{font-size: %d px}</style><body> %@ </body></html>", currentFontSize+14, [page.content kv_decodeHTMLCharacterEntities]];
    [webView loadHTMLString:htmlCode baseURL:baseUrl];
    
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    [scrollDownBtn setAccessibilityLabel:[msg GetString:@"a_scroll_down"]];
    [scrollUpBtn setAccessibilityLabel:[msg GetString:@"a_scroll_up"]];
    
    [pageDataHelper release];
    [msg release];
}
-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
           
        }
    }
}
-(IBAction)ChangeLanguage:(id)sender{
    MessageProcessor *msg = [[MessageProcessor alloc] init];
    [msg ChangeLanguage];
    [self loadData];
    [msg release];
}

-(IBAction)ChangeFont:(id)sender{
    MessageProcessor *msg = [[MessageProcessor alloc] init];
    [msg ChangeFont];
    [self loadData];
    [msg release];
}

-(IBAction)BackHome:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)startScrollTo:(id)sender{
    UIButton *clickedBtn = sender;
    if(clickedBtn.tag == 0){
        holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(moveUp) userInfo:nil repeats:YES];
    }else{
        holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(moveDown) userInfo:nil repeats:YES];
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
    CGFloat offset = webView.scrollView.contentOffset.y;
    CGFloat nextPostion;
    CGFloat height = webView.scrollView.contentSize.height - webView.scrollView.bounds.size.height;
    if(offset+step > height){
        nextPostion = height;
    }else{
        nextPostion = offset+step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [webView.scrollView setContentOffset:targetPostion animated:YES];
}
-(void) moveUp{
    CGFloat step = 20.0f;
    CGFloat offset = webView.scrollView.contentOffset.y;
    CGFloat nextPostion;
    if(offset-step < 0){
        nextPostion = 0;
    }else{
        nextPostion = offset-step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [webView.scrollView setContentOffset:targetPostion animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) dealloc{
    [super dealloc];
    [holdTimer release];
}

@end

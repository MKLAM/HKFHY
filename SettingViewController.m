//
//  SettingViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月1日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "SettingViewController.h"


@implementation SettingViewController

@synthesize homeBtn, languageLbl, languageSegment, mapLbl, mapSegment, sizeLbl, sizeSegment;

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
    msg = [[MessageProcessor alloc] init];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadData{
    NSString *language = [msg ReadSetting:@"language"];
    NSString *fontSize = [msg ReadSetting:@"font_size"];
    [mapLbl setText:[msg GetString:@"map_lbl"]];
    [languageLbl setText:[msg GetString:@"lang_lbl"]];
    [sizeLbl setText:[msg GetString:@"size_lbl"]];
    [mapSegment setTitle:[msg GetString:@"map_google"] forSegmentAtIndex:0];
    [mapSegment setTitle:[msg GetString:@"map_baidu"] forSegmentAtIndex:1];
    [mapSegment setSelectedSegmentIndex:[[msg ReadSetting:@"map_type"] integerValue]];
    if([language isEqualToString:@"en"]){
        [languageSegment setSelectedSegmentIndex:1];
    }else{
        [languageSegment setSelectedSegmentIndex:0];
    }
    [sizeSegment setSelectedSegmentIndex:[fontSize integerValue]-1];
    
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [mapSegment setAccessibilityLabel:[msg GetString:@"map_lbl"]];
    [languageSegment setAccessibilityLabel:[msg GetString:@"lang_lbl"]];
    [sizeSegment setAccessibilityLabel:[msg GetString:@"size_lbl"]];
    
}
-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
           
        }
    }
}
-(IBAction)ChangeLanguage:(id)sender{
    if([sender selectedSegmentIndex] == 0){
        [msg SaveSettingTo:@"language" withValue:@"zh_Hant"];
    }else{
        [msg SaveSettingTo:@"language" withValue:@"en"];
    }
    [self loadData];
}

-(IBAction)ChangeFont:(id)sender{
    [msg SaveSettingTo:@"font_size" withValue:[NSString stringWithFormat:@"%ld", (long)[sender selectedSegmentIndex]+1]];
}

-(IBAction)ChangeMap:(id)sender{
    [msg SaveSettingTo:@"map_type" withValue:[NSString stringWithFormat:@"%ld", (long)[sender selectedSegmentIndex]]];
}

-(IBAction)BackHome:(id)sender{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) dealloc{
    [msg release];
    [super dealloc];
}

@end

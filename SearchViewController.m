//
//  SearchViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月1日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "SearchViewController.h"

@implementation SearchViewController

@synthesize homeBtn, languageChangeBtn, fontSizeChangeBtn, keywordField, submitBtn, scrollDown,scrollUp, resultTableView;

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
    dataColl = [[DataCollection alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [keywordField setDelegate:self];
    [self.view addGestureRecognizer:tap];
    [tap release];
    [self setLayout];
    resultTableView.dataSource = self;
    resultTableView.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([resultList count] == 0){
        UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"loading"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
        
        [loadingView show];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
            if([self.keyword length]>0){
                [self getTableData];
                [keywordField setText:self.keyword];
            }
            [loadingView dismissWithClickedButtonIndex:0 animated:YES];
        });
    }
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

-(void)dismissKeyboard {
    [keywordField resignFirstResponder];
}

-(void) loadData{
    NSString *language = [msg ReadSetting:@"language"];
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", language]] forState:UIControlStateNormal];
    [keywordField setPlaceholder:[msg GetString:@"search_placeholder"]];
    
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    [scrollDown setAccessibilityLabel:[msg GetString:@"a_scroll_down"]];
    [scrollUp setAccessibilityLabel:[msg GetString:@"a_scroll_up"]];
}

-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {
            
        }
    }
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    keywordField.leftView = paddingView;
    keywordField.leftViewMode = UITextFieldViewModeAlways;
    [paddingView release];
}

-(IBAction)ChangeLanguage:(id)sender{
    [msg ChangeLanguage];
    [self loadData];
    [self getTableData];
}

-(IBAction)ChangeFont:(id)sender{
    [msg ChangeFont];
    [self loadData];
}

-(IBAction)BackHome:(id)sender{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getTableData{
    NSString *currentLanguage = [msg ReadSetting:@"language"];
    
    CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND (title CONTAINS[cd] %@) ", currentLanguage, self.keyword];
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    resultList = (NSMutableArray*) spotDataHelper.fetchedResultsController.fetchedObjects;
    [spotDataHelper release];
    [resultTableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([keywordField.text length]>0){
        self.keyword = keywordField.text;
        [self getTableData];
    }
    // We do not want UITextField to insert line-breaks.
    return NO;
}

-(IBAction)submitSearch{
    if([keywordField.text length]>0){
        self.keyword = keywordField.text;
        [self getTableData];
        [resultTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(IBAction)scrollDown:(id)sender{
    CGFloat step = 112.0f;
    CGFloat offset = resultTableView.contentOffset.y;
    CGFloat nextPostion;
    CGFloat height = resultTableView.contentSize.height - resultTableView.bounds.size.height;
    if(height<0){
        height = 0;
    }
    if(offset+step > height){
        nextPostion = height;
    }else{
        nextPostion = offset+step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [resultTableView setContentOffset:targetPostion animated:YES];
}

-(IBAction)scrollUp:(id)sender{
    CGFloat step = 112.0f;
    CGFloat offset = resultTableView.contentOffset.y;
    CGFloat nextPostion;
    if(offset-step < 0){
        nextPostion = 0;
    }else{
        nextPostion = offset-step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [resultTableView setContentOffset:targetPostion animated:YES];
}

//Table View
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112.0;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [resultList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"searchResultCell";
    SearchResultCell *cell = (SearchResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        NSArray *bundleObjects = [[NSBundle mainBundle] loadNibNamed:[msg GetLayoutType:@"SearchResultCell"] owner:nil options:nil];
        cell = [bundleObjects objectAtIndex:0];
    }
    Spot *spot = [resultList objectAtIndex:[indexPath row]];
	cell.title.text = spot.title;
    cell.shortDesc.text = spot.short_description;
    
    CoreDataHelper *photoDataHelper = [[CoreDataHelper alloc] init];
    photoDataHelper.entityName = @"Photo";
    photoDataHelper.defaultSortAttribute = @"id";
    [photoDataHelper setupCoreData];
    NSPredicate *photoQuery = [NSPredicate predicateWithFormat:@"parent_id = %@ AND lang = %@", spot.record_id, [msg ReadSetting:@"language"]];
    [photoDataHelper fetchItemsMatching:photoQuery sortingBy:@"id" asc:YES];
    UIImage *thumbnail;
    ImageDownloader *downloader = [[[ImageDownloader alloc] init] autorelease];
    if([photoDataHelper.fetchedResultsController.fetchedObjects count]>0){
        Photo *photo = [photoDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
        //thumbnail = [UIImage imageWithContentsOfFile:photo.file_name];
        //UIImage *img = [dataColl downloadImageFrom:photo.file_name currentPath:photo.org_path photoID:photo.id asyncToImage:cell.thumbnail];
        //[thumbnail setImage:img];
        UIImage *img  = [downloader addtoList:photo.file_name Source:photo.org_path saveTo:photo.id placeToView:cell.thumbnail];
        cell.thumbnail.image = img;
    }else{
        thumbnail = [UIImage imageNamed:@"default_image.png"];
        cell.thumbnail.image = thumbnail;
    }
    [downloader startDownloadImage];
    [photoDataHelper release];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Spot *spot = [resultList objectAtIndex:[indexPath row]];
    SpotViewController *view = [[SpotViewController alloc] initWithNibName:[msg GetLayoutType:@"SpotViewController"] bundle:nil];
    view.spotID = [spot.record_id intValue];
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)] autorelease];
    view.backgroundColor = [UIColor whiteColor];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    /* Section header is in 0th index... */
    NSString *keyword = self.keyword;
    NSString *string = [NSString stringWithFormat:[msg GetString:@"search_count"], (unsigned long)[resultList count],keyword];
    [label setText:string];
    [view addSubview:label];
    [label release];
    
    return view;
}

-(void) dealloc{
    [resultList release];
    [msg release];
    [dataColl release];
    [super dealloc];
}

@end

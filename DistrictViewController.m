//
//  DistrictViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月24日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "DistrictViewController.h"
#import "HomeViewController.h"
#import "MessageProcessor.h"
#import "CoreDataHelper.h"
#import "District.h"
#import "Spot.h"
#import "Spot_type.h"
#import "Photo.h"
#import "SpotViewController.h"

@implementation DistrictViewController

@synthesize mainView, tableBg, languageChangeBtn, fontSizeChangeBtn, homeBtn, HKBtn, KLNBtn, NTBtn, IslandBtn, imageList, topArrow, downArrow, leftArrow, rightArrow, districtSelectbox, spotTypeSelectbox, SpotTableView;

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
    districtSelectboxSelectedRow = 0;
    spotTypeSelectboxSelectedRow = 0;
    level2DistrictID = 0;
    spotTypeID = 0;
    districtList = [[NSMutableArray alloc] init];
    spotTypeList = [[NSMutableArray alloc] init];
    [self setLayout];
    SpotTableView.dataSource = self;
    SpotTableView.delegate = self;
    msg = [[MessageProcessor alloc] init];
    districtDataHelper = [[CoreDataHelper alloc] init];
    districtDataHelper.entityName = @"District";
    districtDataHelper.defaultSortAttribute = @"seq";
    [districtDataHelper setupCoreData];
    
    spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    photoDataHelper = [[CoreDataHelper alloc] init];
    photoDataHelper.entityName = @"Photo";
    photoDataHelper.defaultSortAttribute = @"id";
    [photoDataHelper setupCoreData];
    
    spotTypeDataHelper = [[CoreDataHelper alloc] init];
    spotTypeDataHelper.entityName = @"Spot_type";
    spotTypeDataHelper.defaultSortAttribute = @"seq";
    [spotTypeDataHelper setupCoreData];

    
    [languageChangeBtn setAccessibilityLabel:[msg GetString:@"a_lang_btn"]];
    [fontSizeChangeBtn setAccessibilityLabel:[msg GetString:@"a_font"]];
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [downArrow setAccessibilityLabel:[msg GetString:@"a_scroll_down"]];
    [topArrow setAccessibilityLabel:[msg GetString:@"a_scroll_up"]];
    [leftArrow setAccessibilityLabel:[msg GetString:@"a_prev_page"]];
    [rightArrow setAccessibilityLabel:[msg GetString:@"a_next_page"]];
    [districtSelectbox setAccessibilityLabel:[msg GetString:@"a_choose_district"]];
    [spotTypeSelectbox setAccessibilityLabel:[msg GetString:@"a_choose_type"]];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([districtList count] == 0){
        UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"loading"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
        
        [loadingView show];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
            [SpotTableView reloadData];
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

-(void) loadData{
    NSString *currentLanguage = [msg ReadSetting:@"language"];
    [languageChangeBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_lang_btn.png", currentLanguage]] forState:UIControlStateNormal];
    
    //Init Tab Button
    NSPredicate *query = [NSPredicate predicateWithFormat:@"parent_id = %d AND lang = %@", 0, currentLanguage];
    
    [districtDataHelper fetchItemsMatching:query sortingBy:@"seq"];
    District *hk = [districtDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
    District *kln = [districtDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:1];
    District *nt = [districtDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:2];
    District *island = [districtDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:3];
    
    [HKBtn setTitle:hk.short_title forState:UIControlStateNormal];
    [KLNBtn setTitle:kln.short_title forState:UIControlStateNormal];
    [NTBtn setTitle:nt.short_title forState:UIControlStateNormal];
    [IslandBtn setTitle:island.short_title forState:UIControlStateNormal];
    if(self.districtID == 1){
        [HKBtn setSelected:YES];
    }else if(self.districtID == 2){
        [KLNBtn setSelected:YES];
    }else if(self.districtID == 3){
        [NTBtn setSelected:YES];
    }else if(self.districtID == 4){
        [IslandBtn setSelected:YES];
    }
    //End Init Tab Button
    
    //Init photo List
    NSPredicate *allSpotInDistrictQuery = [NSPredicate predicateWithFormat:@"top_id = %d AND lang = %@", self.districtID, currentLanguage];
    [spotDataHelper fetchItemsMatching:allSpotInDistrictQuery sortingBy:@"seq"];
    CGFloat nextX = 0;
    int number = 1;
    int img_count = 3;
    if(IPAD){
        img_count = 7;
    }
    //DataCollection *dataColl = [[DataCollection alloc] init];
    ImageDownloader *downloader = [[[ImageDownloader alloc] init] autorelease];
    for(Spot *spot in spotDataHelper.fetchedResultsController.fetchedObjects){
        NSPredicate *photoQuery = [NSPredicate predicateWithFormat:@"parent_id = %@ AND lang = %@", spot.record_id, currentLanguage];
        [photoDataHelper fetchItemsMatching:photoQuery sortingBy:@"id" asc:YES];
        UIImage *thumbnail;
        UIButton *tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if([photoDataHelper.fetchedResultsController.fetchedObjects count]>0){
            Photo *photo = [photoDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
            //thumbnail = [dataColl downloadImageFrom:photo.file_name currentPath:photo.org_path photoID:photo.id asyncToImageBtn:tempBtn];
            thumbnail = [downloader addtoList:photo.file_name Source:photo.org_path saveTo:photo.id placeToView:tempBtn];
            
        }else{
            thumbnail = [UIImage imageNamed:@"default_image.png"];
        }
        [tempBtn setAccessibilityLabel:spot.title];
        [tempBtn setImage:thumbnail forState:UIControlStateNormal];
        [tempBtn setFrame:CGRectMake(nextX, 0, 93, 80)];
        if(number % img_count != 0){
            nextX+=95;
        }else{
            nextX+=93;
        }
        number++;
        [tempBtn setTag:[spot.record_id intValue]];
        [tempBtn.imageView setContentMode:UIViewContentModeScaleToFill];
        [tempBtn addTarget:self action:@selector(EnterDetail:) forControlEvents:UIControlEventTouchUpInside];
        [tempBtn setAccessibilityLabel:spot.title];
        [imageList addSubview:tempBtn];
    }
    imageList.contentSize = CGSizeMake(nextX+((img_count-(number-1)%img_count)*93), 80);
    [downloader startDownloadButton];
    //[dataColl release];
    //End Init Photo List
    
    //Init district data
    NSPredicate *DistrictQuery = [NSPredicate predicateWithFormat:@"parent_id = %d AND lang = %@", self.districtID, currentLanguage];
    
    [districtList removeAllObjects];
    District *allDistrict = (District *)[districtDataHelper newObject];
    allDistrict.id = 0;
    allDistrict.record_id = 0;
    allDistrict.title = [msg GetString:@"district_all"];
    [districtList addObject:allDistrict];
    [allDistrict release];
    [districtDataHelper fetchItemsMatching:DistrictQuery sortingBy:@"seq"];
    [districtList addObjectsFromArray:districtDataHelper.fetchedResultsController.fetchedObjects];
    
    if([districtList count]>0){
        if(level2DistrictID==0){
            District *selectedDistrict = [districtList objectAtIndex:0];
            level2DistrictID = [selectedDistrict.record_id intValue];
            [districtSelectbox setTitle:selectedDistrict.title forState:UIControlStateNormal];
        }else{
            for(District *selectedDistrict in districtList){
                if([selectedDistrict.record_id intValue] == level2DistrictID){
                    level2DistrictID = [selectedDistrict.record_id intValue];
                    [districtSelectbox setTitle:selectedDistrict.title forState:UIControlStateNormal];
                }
            }
        }
        
    }
    //End init district data
    
    //Init spot type data
    NSPredicate *spotTypeQuery = [NSPredicate predicateWithFormat:@"lang = %@", currentLanguage];
    
    [spotTypeList removeAllObjects];
    Spot_type *allType = (Spot_type *)[spotDataHelper newObject];
    allType.id = 0;
    allType.record_id = 0;
    allType.title = [msg GetString:@"type_all"];
    [spotTypeList addObject:allType];
    [allType release];
    [spotTypeDataHelper fetchItemsMatching:spotTypeQuery sortingBy:@"seq"];
    //spotTypeList = (NSMutableArray *)spotTypeDataHelper.fetchedResultsController.fetchedObjects;
    [spotTypeList addObjectsFromArray:spotTypeDataHelper.fetchedResultsController.fetchedObjects];
    if([spotTypeList count]>0){
        if(spotTypeID==0){
            Spot_type *selectedSpotType = [spotTypeList objectAtIndex:0];
            spotTypeID = [selectedSpotType.record_id intValue];
            [spotTypeSelectbox setTitle:selectedSpotType.title forState:UIControlStateNormal];
        }else{
            for(Spot_type *selectedSpotType in spotTypeList){
                if([selectedSpotType.record_id intValue] == spotTypeID){
                    spotTypeID = [selectedSpotType.record_id intValue];
                    [spotTypeSelectbox setTitle:selectedSpotType.title forState:UIControlStateNormal];
                }
            }
        }
    }
    //End init spot type data
    
    [self getTableData];
}
-(void) setLayout{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenRect.size.height > 480.0f) {

        }
    }
}

-(void)getTableData{
    NSString *currentLanguage = [msg ReadSetting:@"language"];
    
    NSPredicate *spotQuery;
    if(level2DistrictID != 0 && spotTypeID != 0){
        spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND district_id = %d AND type_id = %d", currentLanguage, level2DistrictID, spotTypeID];
    }else if(level2DistrictID != 0 && spotTypeID == 0){
        spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND district_id = %d ", currentLanguage, level2DistrictID];
    }else if(level2DistrictID == 0 && spotTypeID != 0){
        spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND top_id = %d AND type_id = %d", currentLanguage, self.districtID, spotTypeID];
    }else{
        spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ AND top_id = %d", currentLanguage, self.districtID];
    }
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    spotList = (NSMutableArray*) spotDataHelper.fetchedResultsController.fetchedObjects;
}

-(IBAction)ChangeLanguage:(id)sender{
    [msg ChangeLanguage];
    UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"loading"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    [loadingView show];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
        [SpotTableView reloadData];
        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
    });

}

-(IBAction)ChangeFont:(id)sender{
    [msg ChangeFont];
    [self loadData];
}

-(IBAction)BackHome:(id)sender{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)EnterDetail:(id)sender{
    UIButton *clickedBtn = sender;
    [self EnterDetailWith:clickedBtn.tag];
}

-(void)EnterDetailWith:(int) spotID{
    SpotViewController *view = [[SpotViewController alloc] initWithNibName:[msg GetLayoutType:@"SpotViewController"] bundle:nil];
    view.spotID = spotID;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(IBAction)NextPage:(id)sender{
    CGFloat step = 285.0f;
    CGFloat offset = imageList.contentOffset.x;
    CGFloat nextPostion;
    CGFloat width = imageList.contentSize.width - imageList.bounds.size.width;
    if(offset+step > width){
        nextPostion = width;
    }else{
        nextPostion = offset+step;
    }
    CGPoint targetPostion = CGPointMake(nextPostion, 0);
    [imageList setContentOffset:targetPostion animated:YES];
}

-(IBAction)PrevPage:(id)sender{
    CGFloat step = 285.0f;
    CGFloat offset = imageList.contentOffset.x;
    CGFloat nextPostion;
    if(offset-step < 0){
        nextPostion = 0;
    }else{
        nextPostion = offset-step;
    }
    CGPoint targetPostion = CGPointMake(nextPostion, 0);
    [imageList setContentOffset:targetPostion animated:YES];

}

-(IBAction)scrollDown:(id)sender{
    CGFloat step = 36.0f;
    CGFloat offset = SpotTableView.contentOffset.y;
    CGFloat nextPostion;
    CGFloat height = SpotTableView.contentSize.height - SpotTableView.bounds.size.height;
    if(height<0){
        height = 0;
    }
    if(offset+step > height){
        nextPostion = height;
    }else{
        nextPostion = offset+step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [SpotTableView setContentOffset:targetPostion animated:YES];
}

-(IBAction)scrollUp:(id)sender{
    CGFloat step = 36.0f;
    CGFloat offset = SpotTableView.contentOffset.y;
    CGFloat nextPostion;
    if(offset-step < 0){
        nextPostion = 0;
    }else{
        nextPostion = offset-step;
    }
    CGPoint targetPostion = CGPointMake(0, nextPostion);
    [SpotTableView setContentOffset:targetPostion animated:YES];
}

-(IBAction)ChangeDistrict:(id)sender{
    
    UIButton *clickedBtn = sender;
    if(self.districtID != clickedBtn.tag){
        /*self.districtID = clickedBtn.tag;
        [HKBtn setSelected:NO];
        [KLNBtn setSelected:NO];
        [NTBtn setSelected:NO];
        [IslandBtn setSelected:NO];
        level2DistrictID = 0;
        spotTypeID = 0;
        districtSelectboxSelectedRow = 0;
        spotTypeSelectboxSelectedRow = 0;
        currentSelectType = 0;
        NSArray *viewsToRemove = [imageList subviews];
        for (UIView *v in viewsToRemove) {
            [v removeFromSuperview];
        }
        [self loadData];
        [SpotTableView reloadData];*/
        DistrictViewController *view = [[DistrictViewController alloc] initWithNibName:[msg GetLayoutType:@"DistrictViewController"] bundle:nil];
        view.districtID = clickedBtn.tag;
        [self.navigationController pushViewController:view animated:YES];
        [view release];

    }
}

-(IBAction)selectBoxDropDown:(id)sender{
    UIButton *clickedBtn = sender;
    int selected;
    if(clickedBtn.tag == 0){
        currentSelectData = [[districtList retain] autorelease];
        selected = districtSelectboxSelectedRow;
    }else{
        currentSelectData = [[spotTypeList retain] autorelease];
        selected = spotTypeSelectboxSelectedRow;
    }
    currentSelectType = clickedBtn.tag;
    
    if(IPAD){
        UIPickerView *pickerView = [[UIPickerView alloc] init];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [pickerView selectRow:selected inComponent:0 animated:NO];
        
        CGRect pickerRect = pickerView.bounds;
        pickerView.bounds = pickerRect;
        
        UIViewController* popoverContent = [[UIViewController alloc] init];
        UIView* popoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 216)];
        popoverView.backgroundColor = [UIColor whiteColor];
        
        pickerView.frame = CGRectMake(0, 0, 320, 216);

        //[popoverView addSubview:pickerToolbar];
        [popoverView addSubview:pickerView];
        [pickerView release];
        popoverContent.view = popoverView;
        
        //resize the popover view shown
        //in the current view to the view's size
        popoverContent.contentSizeForViewInPopover = CGSizeMake(320, 200);
        
        //create a popover controller
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        CGRect popoverRect = [self.view convertRect:[clickedBtn frame]
                                           fromView:[clickedBtn superview]];
        
        popoverRect.size.width = MIN(popoverRect.size.width, 100) ;
        popoverRect.origin.x  = popoverRect.origin.x;
        
        [popoverController
         presentPopoverFromRect:popoverRect
         inView:self.view
         permittedArrowDirections:UIPopoverArrowDirectionAny
         animated:YES];
        popoverController.delegate = self;
        
        
        //release the popover content
        [popoverView release];
        [popoverContent release];
    }else{
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 320, 485);
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        [pickerView selectRow:selected inComponent:0 animated:NO];
        
        [actionSheet addSubview:pickerView];
        [pickerView release];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:[msg GetString:@"close"]]];
        closeButton.momentary = YES;
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(dismissActionSheet:) forControlEvents:UIControlEventValueChanged];
        [actionSheet addSubview:closeButton];
        [closeButton release];
        
        [actionSheet showInView:self.view];
        
        [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
        [actionSheet release];
    }
    //[currentSelectData release];
}

-(void)dismissActionSheet:(id)sender {
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    [self getTableData];
    [SpotTableView reloadData];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self getTableData];
    [SpotTableView reloadData];
}

//Data Picker
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(currentSelectType==0){
        District *selectedDistrict = [districtList objectAtIndex:row];
        level2DistrictID = [selectedDistrict.record_id intValue];
        [districtSelectbox setTitle:selectedDistrict.title forState:UIControlStateNormal];
        districtSelectboxSelectedRow = row;
    }else{
        Spot_type *selectedSpotType = [spotTypeList objectAtIndex:row];
        spotTypeID = [selectedSpotType.record_id intValue];
        [spotTypeSelectbox setTitle:selectedSpotType.title forState:UIControlStateNormal];
        spotTypeSelectboxSelectedRow = row;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [currentSelectData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    if(currentSelectType==0){
        District *currentType;
        currentType = [currentSelectData objectAtIndex:row];
        return currentType.title;
    }else{
        Spot_type *currentType;
        currentType = [currentSelectData objectAtIndex:row];
        return currentType.title;
    }
}
//End Data picker

//Table View
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [spotList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SpotCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(130/255.0) blue:(0/255.0) alpha:1];
        cell.selectedBackgroundView = selectionColor;
        [selectionColor release];
    }
    Spot *spot = [spotList objectAtIndex:[indexPath row]];
	cell.textLabel.text = spot.title;
    cell.textLabel.textColor = [UIColor colorWithRed:(58/255.0) green:(58/255.0) blue:(58/255.0) alpha:1];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:17]];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Spot *spot = [spotList objectAtIndex:[indexPath row]];
    [self EnterDetailWith:[spot.record_id intValue]];
}

//End Table View

-(void) dealloc{
    [districtDataHelper release];
    [spotDataHelper release];
    [photoDataHelper release];
    [spotTypeDataHelper release];
    [mainView release];
    [tableBg release];
    [homeBtn release];
    [languageChangeBtn release];
    [fontSizeChangeBtn release];
    [HKBtn release];
    [KLNBtn release];
    [NTBtn release];
    [IslandBtn release];
    [imageList release];
    [leftArrow release];
    [rightArrow release];
    [topArrow release];
    [downArrow release];
    [districtSelectbox release];
    [spotTypeSelectbox release];
    [SpotTableView release];
    [districtList release];
    [spotTypeList release];
    //[currentSelectData release];
    [spotList release];
    [msg release];
    [super dealloc];
}

@end

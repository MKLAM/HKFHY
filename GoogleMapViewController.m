//
//  GoogleMapViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月29日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "GoogleMapViewController.h"


@implementation GoogleMapViewController

@synthesize tolletBtn,parkBtn,busBtn,snapBtn,homeBtn,zoomInBtn,zoomOutBtn, locationBtn;

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
    internetReach = [[Reachability reachabilityForInternetConnection] retain];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    msg = [[MessageProcessor alloc] init];
    tolletList = [[NSMutableDictionary alloc] init];
    parkList = [[NSMutableDictionary alloc] init];
    busList = [[NSMutableDictionary alloc] init];
    snapList = [[NSMutableDictionary alloc] init];
    tolletMarker = [[NSMutableArray alloc] init];
    parkMarker = [[NSMutableArray alloc] init];
    busMarker = [[NSMutableArray alloc] init];
    snapMarker = [[NSMutableArray alloc] init];
    
    [tolletBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_tollet_btn_off_%@", [msg ReadSetting:@"language"]]] forState:UIControlStateNormal];
    [tolletBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"map_tollet_btn_on_%@", [msg ReadSetting:@"language"]]] forState:UIControlStateSelected];
    
    [internetReach startNotifier];
    
    if(self.spotID == 0){
        zoom = [[msg ReadSetting:@"default_zoom"] intValue];
        lat = [[msg ReadSetting:@"default_lat"] doubleValue];
        lng = [[msg ReadSetting:@"default_lng"] doubleValue];
    }else{
        NSString *language = [msg ReadSetting:@"language"];
        
        CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
        spotDataHelper.entityName = @"Spot";
        spotDataHelper.defaultSortAttribute = @"seq";
        [spotDataHelper setupCoreData];
        
        NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@ and record_id = %d", language, self.spotID];
        
        [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
        if([spotDataHelper.fetchedResultsController.fetchedObjects count]>0){
            spotDetail = (Spot *) [spotDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
            zoom = [spotDetail.zoom intValue];
            lat = [spotDetail.center_lat doubleValue];
            lng = [spotDetail.center_lng doubleValue];
        }
        [spotDataHelper release];
    }

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lng zoom:zoom];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGRect mapSize = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, screenHeight - 140);
    if(IPAD){
        mapSize.size.height = screenHeight - 80;
    }
    mapView_ = [GMSMapView mapWithFrame:mapSize camera:camera];
    mapView_.myLocationEnabled = NO;
    mapView_.indoorEnabled = NO;
    mapView_.delegate = self;
    [self.view insertSubview:mapView_ atIndex:0];
    
    if(self.spotID != 0){
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([spotDetail.map_lat doubleValue], [spotDetail.map_lng doubleValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.userData = [NSString stringWithFormat:@"spot_%@", spotDetail.record_id];
        marker.title = spotDetail.title;
        marker.icon = [UIImage imageNamed:@"pin_snap.png"];
        marker.map = mapView_;
    }
    
    
    /*NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus != NotReachable && [[msg ReadSetting:@"location_loaded"] isEqualToString:@"0"]){
        [self startDownload];
    }else{
        [self loadData];
    }*/
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"loading"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    [loadingView show];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadData];
        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
        if(self.has_tollet){
            [tolletBtn setSelected:YES];
            [self showMarkerFrom:tolletMarker];
        }
        if(self.has_park){
            [parkBtn setSelected:YES];
            [self showMarkerFrom:parkMarker];
        }
        if(self.has_bus){
            [busBtn setSelected:YES];
            [self showMarkerFrom:busMarker];
        }
        if(self.has_snap){
            [snapBtn setSelected:YES];
            [self showMarkerFrom:snapMarker];
        }
    });
}

-(void) startDownload{
    UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"download_data"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
    
    [loadingView show];
    dispatch_async(dispatch_get_main_queue(), ^{
        DataCollection *dataCollection = [DataCollection alloc];
        [dataCollection downloadLocation];
        [dataCollection release];
        [msg SaveSettingTo:@"location_loaded" withValue:@"1"];
        [loadingView dismissWithClickedButtonIndex:0 animated:YES];
        [self loadData];
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
    
    CoreDataHelper *locationDataHelper = [[CoreDataHelper alloc] init];
    locationDataHelper.entityName = @"Location";
    locationDataHelper.defaultSortAttribute = @"seq";
    [locationDataHelper setupCoreData];
    
    NSPredicate *locationQuery = [NSPredicate predicateWithFormat:@"lang = %@", language];
    
    [locationDataHelper fetchItemsMatching:locationQuery sortingBy:@"seq"];
    
    for(Location *loc in locationDataHelper.fetchedResultsController.fetchedObjects){
        if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:31]] || [loc.type_id isEqualToNumber:[NSNumber numberWithInt:32]]){
            [tolletList setValue:loc forKey:[NSString stringWithFormat:@"%@", loc.record_id]];
        }
        if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:33]] || [loc.type_id isEqualToNumber:[NSNumber numberWithInt:34]]){
            [parkList setValue:loc forKey:[NSString stringWithFormat:@"%@", loc.record_id]];
        }
        if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:35]]){
            [busList setValue:loc forKey:[NSString stringWithFormat:@"%@", loc.record_id]];
        }
        /*if([loc.type_id isEqualToNumber:[[NSNumber alloc] initWithInt:36]]){
         [snapList setValue:loc forKey:[[NSString alloc] initWithFormat:@"%@", loc.record_id]];
         }*/
    }
    [locationDataHelper release];
    
    CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@", language];
    
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    for(Spot *spot in spotDataHelper.fetchedResultsController.fetchedObjects){
        if(![spot.record_id isEqualToNumber:[NSNumber numberWithInt:self.spotID]])
            [snapList setValue:spot forKey:[NSString stringWithFormat:@"spot_%@", spot.record_id]];
    }
    [spotDataHelper release];
    
    [self GenerateMarkerFrom:tolletList toArray:tolletMarker];
    [self GenerateMarkerFrom:parkList toArray:parkMarker];
    [self GenerateMarkerFrom:busList toArray:busMarker];
    [self GenerateMarkerFrom:snapList toArray:snapMarker];
    
    [homeBtn setAccessibilityLabel:[msg GetString:@"a_home"]];
    [locationBtn setAccessibilityLabel:[msg GetString:@"a_location"]];
    [zoomInBtn setAccessibilityLabel:[msg GetString:@"a_zoom_in"]];
    [zoomOutBtn setAccessibilityLabel:[msg GetString:@"a_zoom_out"]];
    [tolletBtn setAccessibilityLabel:[msg GetString:@"a_tollet_map"]];
    [parkBtn setAccessibilityLabel:[msg GetString:@"a_park_map"]];
    [busBtn setAccessibilityLabel:[msg GetString:@"a_bus_map"]];
    [snapBtn setAccessibilityLabel:[msg GetString:@"a_spot_map"]];
}

-(IBAction)BackHome{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) MapZoomClick:(id)sender{
    UIButton *clickedBtn = sender;
    if(clickedBtn.tag == 0){
        [mapView_ animateWithCameraUpdate:[GMSCameraUpdate zoomIn]];
    }else{
        [mapView_ animateWithCameraUpdate:[GMSCameraUpdate zoomOut]];
    }
}

-(IBAction)ToggleLocation:(id)sender{
    UIButton *clickedBtn = sender;
    if([clickedBtn isSelected]){
        mapView_.myLocationEnabled = NO;
        [locationManager stopUpdatingLocation];
        [clickedBtn setSelected:NO];
    }else{
        mapView_.myLocationEnabled = YES;
        [locationManager startUpdatingLocation];
        [clickedBtn setSelected:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.coordinate.latitude != oldLocation.coordinate.latitude || newLocation.coordinate.longitude != oldLocation.coordinate.longitude) {
        GMSCameraPosition *sydney = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                                longitude:newLocation.coordinate.longitude
                                                                     zoom:mapView_.camera.zoom];
        [mapView_ setCamera:sydney];
    }
    [locationManager stopUpdatingLocation];
}

-(void) GenerateMarkerFrom:(id) Datalist toArray:(id)Holder{
    NSMutableDictionary *data = Datalist;
    for(NSString *key in data){
        CLLocationCoordinate2D position;
        GMSMarker *marker;
        if([[data objectForKey:key] isKindOfClass:[Location class]]){
            Location *loc = [data objectForKey:key];
            position = CLLocationCoordinate2DMake([loc.map_lat doubleValue], [loc.map_lng doubleValue]);
            marker = [GMSMarker markerWithPosition:position];
            marker.userData = [NSString stringWithFormat:@"%@", loc.record_id];
            marker.title = loc.title;
            if([loc.open_time length] > 0){
                marker.snippet = [NSString stringWithFormat:@"%@ : %@ \n %@", [msg GetString:@"openning_time"], loc.open_time, loc.content];
            }else{
                marker.snippet = loc.content;
            }
            if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:31]]){
                marker.icon = [UIImage imageNamed:@"pin_tollet.png"];
            }else if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:32]]){
                marker.icon = [UIImage imageNamed:[NSString stringWithFormat:@"pin_disable_tollet_%@.png", [msg ReadSetting:@"language"]]];
            }else if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:33]]){
                marker.icon = [UIImage imageNamed:@"pin_park.png"];
            }else if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:34]]){
                marker.icon = [UIImage imageNamed:@"pin_disable_park.png"];
            }else if([loc.type_id isEqualToNumber:[NSNumber numberWithInt:35]]){
                marker.icon = [UIImage imageNamed:@"pin_bus.png"];
            }
        }else{
            Spot *loc = [data objectForKey:key];
            position = CLLocationCoordinate2DMake([loc.map_lat doubleValue], [loc.map_lng doubleValue]);
            marker = [GMSMarker markerWithPosition:position];
            marker.userData = [NSString stringWithFormat:@"spot_%@", loc.record_id];
            marker.title = loc.title;
            marker.icon = [UIImage imageNamed:@"pin_snap.png"];
        }
        //marker.map = nil;

        [(NSMutableArray *) Holder addObject:marker];
        //[marker release];
    }
}

-(void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    if([marker.snippet length] != 0) return;
    NSString *tempID = [marker.userData stringByReplacingOccurrencesOfString:@"spot_" withString:@""];
    SpotViewController *view = [[SpotViewController alloc] initWithNibName:[msg GetLayoutType:@"SpotViewController"] bundle:nil];
    view.spotID = [tempID intValue];
    [self.navigationController pushViewController:view animated:YES];
    [view release];

}

-(void) showMarkerFrom:(id) Holder{
    for(GMSMarker *marker in (NSMutableArray *) Holder){
        if((marker.position.latitude - lat <= 0.006 &&
            marker.position.latitude - lat >= -0.006)
           &&(marker.position.longitude - lng <= 0.006 &&
              marker.position.longitude - lng >= -0.006)){
               marker.map = mapView_;
           }else{
               marker.map = nil;
           }
    }
}

-(void) removeMarkerFrom:(id) Holder{
    for(GMSMarker *marker in (NSMutableArray *) Holder){
        marker.map = nil;
    }
}

-(IBAction)markerTaggle:(id)sender{
    UIButton *clickedBtn = sender;
    id holder = nil;
    switch(clickedBtn.tag){
        case 0:holder = tolletMarker;
            break;
        case 1: holder = parkMarker;
            break;
        case 2: holder = busMarker;
            break;
        case 3: holder = snapMarker;
            break;
    }
    if(clickedBtn.isSelected){
        [clickedBtn setSelected:NO];
        switch(clickedBtn.tag){
            case 0:
                self.has_tollet = NO;
                break;
            case 1:
                self.has_park = NO;
                break;
            case 2:
                self.has_bus = NO;
                break;
            case 3:
                self.has_snap = NO;
                break;
        }
        [self removeMarkerFrom:holder];
    }else{
        [clickedBtn setSelected:YES];
        switch(clickedBtn.tag){
            case 0:
                self.has_tollet = YES;
                break;
            case 1:
                self.has_park = YES;
                break;
            case 2:
                self.has_bus = YES;
                break;
            case 3:
                self.has_snap = YES;
                break;
        }
        [self showMarkerFrom:holder];
    }
}

-(void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    if(lat - position.targetAsCoordinate.latitude >= 0.0006 || lat - position.targetAsCoordinate.latitude <= -0.0006
       || lng - position.targetAsCoordinate.longitude >= 0.0006 || lng - position.targetAsCoordinate.longitude  <= -0.0006){
        if(self.has_tollet){
            [self showMarkerFrom:tolletMarker];
        }
        if(self.has_park){
            [self showMarkerFrom:parkMarker];
        }
        if(self.has_bus){
            [self showMarkerFrom:busMarker];
        }
        if(self.has_snap){
            [self showMarkerFrom:snapMarker];
        }
    }
    lat = position.targetAsCoordinate.latitude;
    lng = position.targetAsCoordinate.longitude;
    [msg SaveSettingTo:@"default_lat" withValue:[NSString stringWithFormat:@"%.20f", position.targetAsCoordinate.latitude]];
    [msg SaveSettingTo:@"default_lng" withValue:[NSString stringWithFormat:@"%.20f", position.targetAsCoordinate.longitude]];
    [msg SaveSettingTo:@"default_zoom" withValue:[NSString stringWithFormat:@"%f", position.zoom]];
}

-(void)dealloc{
    [spotDetail release];
    [tolletList release];
    [tolletMarker release];
    [parkList release];
    [parkMarker release];
    [busList release];
    [busMarker release];
    [snapList release];
    [snapMarker release];
    [msg release];
    [internetReach release];
    [locationManager release];
    [super dealloc];
}
@end

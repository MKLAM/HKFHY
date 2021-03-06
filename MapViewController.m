//
//  MapViewController.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月29日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController

@synthesize tolletBtn,parkBtn,busBtn,snapBtn,homeBtn,zoomInBtn,zoomOutBtn, locationBtn, OrgMapView_;

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
    
    OrgMapView_.delegate = self;
    
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
            
            MapViewAnnotation* annotation = [[MapViewAnnotation alloc]init];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [spotDetail.map_lat doubleValue];
            coordinate.longitude = [spotDetail.map_lng doubleValue];
            annotation.coordinate = coordinate;
            annotation.refID = @"spot";
            annotation.title = spotDetail.title;
            [OrgMapView_ addAnnotation:annotation];
            [annotation release];
        }
        [spotDataHelper release];
    }
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = lat;
    coordinate.longitude = lng;
    [OrgMapView_ setCenterCoordinate:coordinate zoomLevel:zoom animated:NO];
    
    /*if(self.has_tollet){
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
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
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
    }
    [locationDataHelper release];
    
    CoreDataHelper *spotDataHelper = [[CoreDataHelper alloc] init];
    spotDataHelper.entityName = @"Spot";
    spotDataHelper.defaultSortAttribute = @"seq";
    [spotDataHelper setupCoreData];
    
    NSPredicate *spotQuery = [NSPredicate predicateWithFormat:@"lang = %@", language];
    
    [spotDataHelper fetchItemsMatching:spotQuery sortingBy:@"seq"];
    for(Spot *spot in spotDataHelper.fetchedResultsController.fetchedObjects){
        if(![spot.record_id isEqualToNumber:[NSNumber numberWithInt:self.spotID]]){
            [snapList setValue:spot forKey:[NSString stringWithFormat:@"spot_%@", spot.record_id]];
        }
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

-(IBAction)BackHome{
    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) MapZoomClick:(id)sender{
    UIButton *clickedBtn = sender;
    if(clickedBtn.tag == 0){
        if(zoom +1 > 18){
            zoom = 18;
        }else{
            zoom+=1;
        }
    }else{
        if(zoom-1 < 0){
            zoom = 0;
        }else{
            zoom -= 1;
        }
    }
    [OrgMapView_ setCenterCoordinate:OrgMapView_.centerCoordinate zoomLevel:zoom animated:YES];
}

-(IBAction)ToggleLocation:(id)sender{
    UIButton *clickedBtn = sender;
    if([clickedBtn isSelected]){
        OrgMapView_.userTrackingMode = MKUserTrackingModeNone;
        OrgMapView_.showsUserLocation = NO;
        [clickedBtn setSelected:NO];
    }else{
        OrgMapView_.showsUserLocation = NO;
        OrgMapView_.userTrackingMode = MKUserTrackingModeFollow;
        OrgMapView_.showsUserLocation = YES;
        [clickedBtn setSelected:YES];
    }
}

-(void) GenerateMarkerFrom:(id) Datalist toArray:(id)Holder{
    NSMutableDictionary *data = Datalist;
    for(NSString *key in data){
        MapViewAnnotation* annotation = [[MapViewAnnotation alloc]init];
        CLLocationCoordinate2D coordinate;
        if([[data objectForKey:key] isKindOfClass:[Location class]]){
            Location *loc = [data objectForKey:key];
            coordinate.latitude = [loc.map_lat doubleValue];
            coordinate.longitude = [loc.map_lng doubleValue];
            annotation.refID = [NSString stringWithFormat:@"%@", loc.record_id];
            annotation.title = loc.title;
            if([loc.open_time length] > 0){
                annotation.subtitle = [NSString stringWithFormat:@"%@ : %@ \n %@", [msg GetString:@"openning_time"], loc.open_time, loc.content];
            }else{
                annotation.subtitle = loc.content;
            }
        }else{
            Spot *loc = [data objectForKey:key];
            coordinate.latitude = [loc.map_lat doubleValue];
            coordinate.longitude = [loc.map_lng doubleValue];
            annotation.refID = [NSString stringWithFormat:@"spot_%@", loc.record_id];
            annotation.title = loc.title;
        }
        annotation.coordinate = coordinate;
        
        //[OrgMapView_ addAnnotation:annotation];
        [(NSMutableArray *) Holder addObject:annotation];
        [annotation release];
    }
}

-(void) showMarkerFrom:(id) Holder{
    for(MapViewAnnotation *annotation in (NSMutableArray *) Holder){
        if((annotation.coordinate.latitude - OrgMapView_.centerCoordinate.latitude <= 0.006 &&
           annotation.coordinate.latitude - OrgMapView_.centerCoordinate.latitude >= -0.006)
           &&(annotation.coordinate.longitude - OrgMapView_.centerCoordinate.longitude <= 0.006 &&
              annotation.coordinate.longitude - OrgMapView_.centerCoordinate.longitude >= -0.006)){
            [OrgMapView_ addAnnotation:annotation];
        }else{
            [OrgMapView_ removeAnnotation:annotation];
        }
    }
}
-(void) removeMarkerFrom:(id) Holder{
    for(MapViewAnnotation *annotation in (NSMutableArray *) Holder){
        [OrgMapView_ removeAnnotation:annotation];
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
        //[self GenerateMarkerFrom:dataList toArray:holder];
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


-(MKPinAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
        MapViewAnnotation *temp = annotation;
        MKPinAnnotationView *newAnnotation = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"] autorelease];
        if([tolletList objectForKey:temp.refID]){
            Location *location = [tolletList objectForKey:temp.refID];
            if([location.type_id isEqualToNumber:[NSNumber numberWithInt:31]]){
                newAnnotation.image = [UIImage imageNamed:@"pin_tollet.png"];
            }else{
                newAnnotation.image = [UIImage imageNamed:[NSString stringWithFormat:@"pin_disable_tollet_%@.png", [msg ReadSetting:@"language"]]];
            }
            //[location release];
        }else if([parkList objectForKey:temp.refID]){
            Location *location = [parkList objectForKey:temp.refID];
            if([location.type_id isEqualToNumber:[NSNumber numberWithInt:33]]){
                newAnnotation.image = [UIImage imageNamed:@"pin_park.png"];
            }else{
                newAnnotation.image = [UIImage imageNamed:@"pin_disable_park.png"];
            }
            //[location release];
            
        }else if([busList objectForKey:temp.refID]){
            //location = [busList objectForKey:temp.refID];
            newAnnotation.image = [UIImage imageNamed:@"pin_bus.png"];
        }else if([snapList objectForKey:[NSString stringWithFormat:@"%@", temp.refID]]){
            //location = [snapList objectForKey:temp.refID];
            Spot *spot = [snapList objectForKey:[NSString stringWithFormat:@"%@", temp.refID]];
            newAnnotation.image = [UIImage imageNamed:@"pin_snap.png"];
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightButton.tag = [spot.record_id intValue];
            [rightButton setTitle:temp.title forState:UIControlStateNormal];
            [rightButton addTarget:self action:@selector(toSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
            newAnnotation.rightCalloutAccessoryView = rightButton;
        }else{
            newAnnotation.image = [UIImage imageNamed:@"pin_snap.png"];
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            rightButton.tag = self.spotID;
            [rightButton setTitle:temp.title forState:UIControlStateNormal];
            [rightButton addTarget:self action:@selector(toSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
            newAnnotation.rightCalloutAccessoryView = rightButton;
        }
        
        
        newAnnotation.animatesDrop = NO;
        newAnnotation.canShowCallout = YES;
        newAnnotation.calloutOffset = CGPointMake(0,-10);
        newAnnotation.draggable = NO;//拖动
        
        return newAnnotation;
    }
    return nil;
}
-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if(lat - mapView.centerCoordinate.latitude >= 0.0006 || lat - mapView.centerCoordinate.latitude <= -0.0006
       || lng - mapView.centerCoordinate.longitude >= 0.0006 || lng - mapView.centerCoordinate.longitude  <= -0.0006){
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
    lat = mapView.centerCoordinate.latitude;
    lng = mapView.centerCoordinate.longitude;
    [msg SaveSettingTo:@"default_lat" withValue:[NSString stringWithFormat:@"%.20f", mapView.centerCoordinate.latitude]];
    [msg SaveSettingTo:@"default_lng" withValue:[NSString stringWithFormat:@"%.20f", mapView.centerCoordinate.longitude]];
    [msg SaveSettingTo:@"default_zoom" withValue:[NSString stringWithFormat:@"%f", [mapView getZoomLevel]]];
}

-(void) toSpotDetail:(id) sender{
    UIButton *clicked = sender;
    SpotViewController *view = [[SpotViewController alloc] initWithNibName:[msg GetLayoutType:@"SpotViewController"] bundle:nil];
    view.spotID = clicked.tag;
    [self.navigationController pushViewController:view animated:YES];
    [view release];
}

-(void) dealloc{
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
    [super dealloc];
}


@end

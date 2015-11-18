//
//  MapViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月29日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MessageProcessor.h"
#import "Spot.h"
#import "Location_type.h"
#import "Location.h"
#import "CoreDataHelper.h"
#import "MKMapView+ZoomLevel.h"
#import "MapViewAnnotation.h"
#import "SpotViewController.h"
#import "DataCollection.h"

@interface MapViewController : UIViewController<MKMapViewDelegate,UIAlertViewDelegate>{
    MessageProcessor *msg;
    Reachability *internetReach;
    
    double lat;
    double lng;
    int zoom;
    
    Spot *spotDetail;
    
    NSMutableDictionary *tolletList;
    NSMutableDictionary *parkList;
    NSMutableDictionary *busList;
    NSMutableDictionary *snapList;
    
    NSMutableArray *tolletMarker;
    NSMutableArray *parkMarker;
    NSMutableArray *busMarker;
    NSMutableArray *snapMarker;
}

@property(nonatomic) BOOL has_tollet;
@property(nonatomic) BOOL has_park;
@property(nonatomic) BOOL has_bus;
@property(nonatomic) BOOL has_snap;
@property(nonatomic) int spotID;

@property(nonatomic, retain) IBOutlet MKMapView* OrgMapView_;
@property(nonatomic, retain) IBOutlet UIButton *tolletBtn;
@property(nonatomic, retain) IBOutlet UIButton *parkBtn;
@property(nonatomic, retain) IBOutlet UIButton *busBtn;
@property(nonatomic, retain) IBOutlet UIButton *snapBtn;
@property(nonatomic, retain) IBOutlet UIButton *homeBtn;
@property(nonatomic, retain) IBOutlet UIButton *locationBtn;
@property(nonatomic, retain) IBOutlet UIButton *zoomInBtn;
@property(nonatomic, retain) IBOutlet UIButton *zoomOutBtn;

-(IBAction)BackHome;
-(IBAction) MapZoomClick:(id)sender;
-(IBAction)ToggleLocation:(id)sender;
-(void) loadData;
-(void) GenerateMarkerFrom:(id) Datalist toArray:(id)Holder;
-(void) showMarkerFrom:(id) Holder;
-(void) removeMarkerFrom:(id) Holder;
-(IBAction)markerTaggle:(id)sender;
-(void) toSpotDetail:(id) sender;
-(void) startDownload;

@end

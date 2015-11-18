//
//  MKMapView+ZoomLevel.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月4日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
- (double)getZoomLevel;
@end

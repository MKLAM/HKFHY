//
//  Spot.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月4日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Spot : NSManagedObject

@property (nonatomic, retain) NSNumber * center_lat;
@property (nonatomic, retain) NSNumber * center_lng;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * district_id;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * map_lat;
@property (nonatomic, retain) NSNumber * map_lng;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * record_id;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSString * short_description;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * top_id;
@property (nonatomic, retain) NSNumber * total_rated;
@property (nonatomic, retain) NSString * transport;
@property (nonatomic, retain) NSNumber * type_id;
@property (nonatomic, retain) NSNumber * zoom;
@property (nonatomic, retain) NSNumber * baidu_map_x;
@property (nonatomic, retain) NSNumber * baidu_map_y;
@property (nonatomic, retain) NSNumber * baidu_center_x;
@property (nonatomic, retain) NSNumber * baidu_center_y;

@end

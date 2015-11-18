//
//  Photo.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月5日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * alt_text;
@property (nonatomic, retain) NSString * file_name;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * parent_id;
@property (nonatomic, retain) NSString * org_path;

@end

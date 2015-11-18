//
//  Page.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月23日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Page : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * record_id;
@property (nonatomic, retain) NSNumber * parent_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSString * lang;

@end

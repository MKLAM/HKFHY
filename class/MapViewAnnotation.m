//
//  MapViewAnnotation.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月4日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "MapViewAnnotation.h"

@implementation MapViewAnnotation

@synthesize coordinate,title,subtitle;
-(void)dealloc{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end

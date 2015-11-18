//
//  DataCollection.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月19日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "JSON.h"
#import "MessageProcessor.h"
#import <CoreData/CoreData.h>
#import "CoreDataHelper.h"
#import "Spot.h"
#import "District.h"
#import "Spot_type.h"
#import "Location.h"
#import "Location_type.h"
#import "Photo.h"
#import "Page.h"

@interface DataCollection : NSObject{
    MessageProcessor *msg;
    SBJsonParser *parser;
    CoreDataHelper *spotDataHelper;
    CoreDataHelper *districtDataHelper;
    CoreDataHelper *spotTypeDataHelper;
    CoreDataHelper *locationDataHelper;
    CoreDataHelper *locationTypeDataHelper;
    CoreDataHelper *pageDataHelper;
    CoreDataHelper *photoDataHelper;
}

-(NSString*) checkVersion;
-(void) downloadPatch;
-(void) downloadLocation;
-(NSString*) downloadImageFrom:(NSString*) path;
-(void) updateImageList;
-(void) deleteOutDateDate;
-(void) deleteOutDateLocation;
-(NSDictionary*) getRateBy:(int) spotID;
-(NSNumber*) stringToNumber:(id) string;


-(UIImage *) downloadImageFrom:(NSString *)path currentPath:(NSString *) orgPath photoID:(NSNumber *)ID asyncToImage:(UIImageView *)imageView;
-(UIImage *) downloadImageFrom:(NSString *)path currentPath:(NSString *) orgPath photoID:(NSNumber *)ID asyncToImageBtn:(UIButton *)imageView;
-(NSString *) downloadImageFrom:(NSString *)path photoID:(NSNumber *)ID;


@end

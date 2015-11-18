//
//  DataCollection.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月19日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "DataCollection.h"

@implementation DataCollection

- (id)init
{
    self = [super init];
    if (self) {
        msg = [[MessageProcessor alloc] init];
        parser = [[SBJsonParser alloc] init];
        
        spotDataHelper = [[CoreDataHelper alloc] init];
        spotDataHelper.entityName = @"Spot";
        spotDataHelper.defaultSortAttribute = @"seq";
        [spotDataHelper setupCoreData];
        
        districtDataHelper = [[CoreDataHelper alloc] init];
        districtDataHelper.entityName = @"District";
        districtDataHelper.defaultSortAttribute = @"seq";
        [districtDataHelper setupCoreData];
        
        spotTypeDataHelper = [[CoreDataHelper alloc] init];
        spotTypeDataHelper.entityName = @"Spot_type";
        spotTypeDataHelper.defaultSortAttribute = @"seq";
        [spotTypeDataHelper setupCoreData];
        
        locationDataHelper = [[CoreDataHelper alloc] init];
        locationDataHelper.entityName = @"Location";
        locationDataHelper.defaultSortAttribute = @"seq";
        [locationDataHelper setupCoreData];
         
        locationTypeDataHelper = [[CoreDataHelper alloc] init];
        locationTypeDataHelper.entityName = @"Location_type";
        locationTypeDataHelper.defaultSortAttribute = @"seq";
        [locationTypeDataHelper setupCoreData];
        
        pageDataHelper = [[CoreDataHelper alloc] init];
        pageDataHelper.entityName = @"Page";
        pageDataHelper.defaultSortAttribute = @"seq";
        [pageDataHelper setupCoreData];
        
        photoDataHelper = [[CoreDataHelper alloc] init];
        photoDataHelper.entityName = @"Photo";
        photoDataHelper.defaultSortAttribute = @"id";
        [photoDataHelper setupCoreData];
    }
    return self;
}

- (void)dealloc
{
    [msg release];
    [parser release];
    [spotDataHelper release];
    [districtDataHelper release];
    [spotTypeDataHelper release];
    [locationDataHelper release];
    [locationTypeDataHelper release];
    [pageDataHelper release];
    [photoDataHelper release];
    [super dealloc];
}

-(NSString*) checkVersion{
    NSString *path = [NSString stringWithFormat:@"%@%@", [msg ReadSetting:@"domain"], [msg ReadSetting:@"get_version"]];
    NSURLResponse * response;
    NSError * error;
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSData *result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *data = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSDictionary *output = [parser objectWithString:data];

    NSString *version = [output objectForKey:@"data_version"];
    
    [data release];
    [url release];
    return version;
}

-(void) downloadPatch{
    [self deleteOutDateDate];
    
    NSString *path = [NSString stringWithFormat:@"%@%@?without=location,location_type", [msg ReadSetting:@"domain"], [msg ReadSetting:@"get_data"]];
    NSURLResponse * response;
    NSError * error;
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [url release];
    NSData *result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *data = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    //NSMutableDictionary *output = [parser objectWithString:data];
    NSDictionary *output = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:nil];
    [data release];
    int photoId = 1;
    NSMutableArray *photoList = [[NSMutableArray alloc] init];
    
    for (NSString* key in output) {//key lang
        NSDictionary *lang = [output objectForKey:key];
        NSArray *spot_list = [lang objectForKey:@"spot"];
        NSArray *district_list = [lang objectForKey:@"district"];
        NSArray *spot_type_list = [lang objectForKey:@"spot_type"];
        /*NSMutableArray *location_list = [lang objectForKey:@"location"];
        NSMutableArray *location_type_list = [lang objectForKey:@"location_type"];*/
        NSArray *page_list = [lang objectForKey:@"page"];
        
        NSString *language = nil;
        if([key isEqualToString:@"zh-hant"]){
            language = @"zh_Hant";
        }else{
            language = @"en";
        }
        
        NSMutableDictionary *districtParent = [[NSMutableDictionary alloc] init];

        for(id district_list_data in district_list){
            NSDictionary *data = district_list_data;
            District *district = [(District *) [districtDataHelper newObject] autorelease];
            district.id = [self stringToNumber:[data objectForKey:@"id"]];
            district.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            district.parent_id = [self stringToNumber:[data objectForKey:@"parent_id"]];
            district.title = [data objectForKey:@"title"];
            district.short_title = [data objectForKey:@"short_title"];
            district.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            district.lang = language;
            
            
            if(district.parent_id!=0){
                [districtParent setValue:[data objectForKey:@"parent_id"] forKey:[data objectForKey:@"record_id"]];
            }
            
            [districtDataHelper save];
        }
        
        for(id spot_type_list_data in spot_type_list){
            NSDictionary *data = spot_type_list_data;
            Spot_type *spotType = [(Spot_type *) [spotTypeDataHelper newObject] autorelease];
            spotType.id = [self stringToNumber:[data objectForKey:@"id"]];
            spotType.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            spotType.title = [data objectForKey:@"title"];
            spotType.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            spotType.lang = language;
            [spotTypeDataHelper save];
        }
        
        for(id spot_list_data in spot_list){
            NSDictionary *data = spot_list_data;
            Spot *spot = [(Spot *) [spotDataHelper newObject] autorelease];
            spot.id = [self stringToNumber:[data objectForKey:@"id"]];
            spot.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            spot.type_id = [self stringToNumber:[data objectForKey:@"type_id"]];
            spot.district_id = [self stringToNumber:[data objectForKey:@"district_id"]];
            spot.title = [data objectForKey:@"title"];
            spot.short_description = [data objectForKey:@"short_description"];
            spot.content = [data objectForKey:@"content"];
            spot.transport = [data objectForKey:@"transport"];
            spot.info = [data objectForKey:@"info"];
            spot.rate = [data objectForKey:@"rate"];
            spot.total_rated = [data objectForKey:@"total_rated"];
            spot.map_lat = [self stringToNumber:[data objectForKey:@"map_lat"]];
            spot.map_lng = [self stringToNumber:[data objectForKey:@"map_lng"]];
            spot.center_lat = [self stringToNumber:[data objectForKey:@"center_lat"]];
            spot.center_lng = [self stringToNumber:[data objectForKey:@"center_lng"]];
            spot.baidu_map_x = [self stringToNumber:[data objectForKey:@"baidu_map_x"]];
            spot.baidu_map_y = [self stringToNumber:[data objectForKey:@"baidu_map_y"]];
            spot.baidu_center_x = [self stringToNumber:[data objectForKey:@"baidu_center_x"]];
            spot.baidu_center_y = [self stringToNumber:[data objectForKey:@"baidu_center_y"]];
            spot.zoom = [self stringToNumber:[data objectForKey:@"zoom"]];
            spot.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            spot.lang = language;
            spot.top_id = [self stringToNumber:[districtParent objectForKey:[data objectForKey:@"district_id"]]];
            [spotDataHelper save];
            
            NSMutableDictionary *getThumbnail = [data objectForKey:@"photos"];
            NSMutableArray *tempPhoto = [getThumbnail objectForKey:@"thumbnail"];
            
            for(id photo_data in tempPhoto ){
                NSDictionary *dataFromPhotoData = photo_data;
                if(![[dataFromPhotoData objectForKey:@"path"] isEqualToString:@"null"]){
                    photoId++;
                    NSString *ImagePathFromData = [dataFromPhotoData objectForKey:@"path"];
                    NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithObjectsAndKeys:ImagePathFromData, @"path", [dataFromPhotoData objectForKey:@"alt_text"], @"alt_text", language, @"lang", [data objectForKey:@"record_id"],@"parent_id",[NSString stringWithFormat:@"%d", photoId],@"id", nil];
                    [photoList addObject:temp];
                    [temp release];
                }
            }
        }
        
        /*for(id location_list_data in location_list){
            NSMutableDictionary *data = location_list_data;
            Location *location = (Location *) [locationDataHelper newObject];
            location.id = [self stringToNumber:[data objectForKey:@"id"]];
            location.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            location.type_id = [self stringToNumber:[data objectForKey:@"type_id"]];
            location.title = [data objectForKey:@"title"];
            location.open_time = [data objectForKey:@"open_time"];
            location.content = [data objectForKey:@"content"];
            location.map_lat = [self stringToNumber:[data objectForKey:@"map_lat"]];
            location.map_lng = [self stringToNumber:[data objectForKey:@"map_lng"]];
            location.baidu_map_x = [self stringToNumber:[data objectForKey:@"baidu_map_x"]];
            location.baidu_map_y = [self stringToNumber:[data objectForKey:@"baidu_map_y"]];
            location.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            location.lang = language;
            [locationDataHelper save];
        }*/
        
        /*for(id location_type_list_data in location_type_list){
            NSMutableDictionary *data = location_type_list_data;
            Location_type *locationType = (Location_type *) [locationTypeDataHelper newObject];
            locationType.id = [self stringToNumber:[data objectForKey:@"id"]];
            locationType.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            locationType.type_id = [self stringToNumber:[data objectForKey:@"type_id"]];
            locationType.title = [data objectForKey:@"title"];
            locationType.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            locationType.lang = language;
            [locationTypeDataHelper save];
        }*/
        
        for(id page_list_data in page_list){
            NSDictionary *data = page_list_data;
            Page *page = [(Page *) [pageDataHelper newObject] autorelease];
            page.id = [self stringToNumber:[data objectForKey:@"id"]];
            page.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
            page.parent_id = [self stringToNumber:[data objectForKey:@"parent_id"]];
            page.seq = [self stringToNumber:[data objectForKey:@"seq"]];
            page.title = [data objectForKey:@"title"];
            page.content = [data objectForKey:@"content"];
            page.lang = language;
            [pageDataHelper save];
        }
        
        [districtParent release];
    }
    
    for(id photoDataFromPhotoList in photoList){
        NSMutableDictionary *data = photoDataFromPhotoList;
        Photo *photo = [(Photo *) [photoDataHelper newObject] autorelease];
        photo.id = [self stringToNumber:[data objectForKey:@"id"]];
        //photo.file_name = [self downloadImageFrom:[data objectForKey:@"path"]];
        photo.file_name = @"no";
        photo.org_path = [data objectForKey:@"path"];
        if(![[data objectForKey:@"alt_text"] isEqual:[NSNull null]]){
            photo.alt_text = [data objectForKey:@"alt_text"];
        }
        photo.parent_id = [self stringToNumber:[data objectForKey:@"parent_id"]];
        photo.lang = [data objectForKey:@"lang"];
        [photoDataHelper save];
    }
    [photoList release];
}

-(void) downloadLocation{
    
    [self deleteOutDateLocation];
    
    NSString *path = [NSString stringWithFormat:@"%@%@?without=spot,district,page,spot_type", [msg ReadSetting:@"domain"], [msg ReadSetting:@"get_data"]];
    NSURLResponse * response;
    NSError * error;
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [url release];
    NSData *result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *data = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    //NSMutableDictionary *output = [parser objectWithString:data];
    NSDictionary *output = [NSJSONSerialization JSONObjectWithData:result options:kNilOptions error:nil];
    [data release];
    
    for (NSString* key in output) {//key lang
        NSDictionary *lang = [output objectForKey:key];
        NSArray *location_list = [lang objectForKey:@"location"];
        NSArray *location_type_list = [lang objectForKey:@"location_type"];
        
        NSString *language = nil;
        if([key isEqualToString:@"zh-hant"]){
            language = @"zh_Hant";
        }else{
            language = @"en";
        }
                
        for(id location_list_data in location_list){
             NSDictionary *data = location_list_data;
             Location *location = [(Location *) [locationDataHelper newObject] autorelease];
             location.id = [self stringToNumber:[data objectForKey:@"id"]];
             location.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
             location.type_id = [self stringToNumber:[data objectForKey:@"type_id"]];
             location.title = [data objectForKey:@"title"];
             location.open_time = [data objectForKey:@"open_time"];
             location.content = [data objectForKey:@"content_plain_text"];
             location.map_lat = [self stringToNumber:[data objectForKey:@"map_lat"]];
             location.map_lng = [self stringToNumber:[data objectForKey:@"map_lng"]];
             location.baidu_map_x = [self stringToNumber:[data objectForKey:@"baidu_map_x"]];
             location.baidu_map_y = [self stringToNumber:[data objectForKey:@"baidu_map_y"]];
             location.seq = [self stringToNumber:[data objectForKey:@"seq"]];
             location.lang = language;
             [locationDataHelper save];
         }
        
        for(id location_type_list_data in location_type_list){
             NSDictionary *data = location_type_list_data;
             Location_type *locationType = [(Location_type *) [locationTypeDataHelper newObject] autorelease];
             locationType.id = [self stringToNumber:[data objectForKey:@"id"]];
             locationType.record_id = [self stringToNumber:[data objectForKey:@"record_id"]];
             locationType.type_id = [self stringToNumber:[data objectForKey:@"type_id"]];
             locationType.title = [data objectForKey:@"title"];
             locationType.seq = [self stringToNumber:[data objectForKey:@"seq"]];
             locationType.lang = language;
             [locationTypeDataHelper save];
         }

    }
    //NSLog(@"Start download Image");
    //[self updateImageList];
}


-(NSString*) downloadImageFrom:(NSString*) path{
    NSString *ImageUrl = [NSString stringWithFormat:@"%@/img.php?width=360&height=240&bg=fff&file=%@", [msg ReadSetting:@"domain"], path];
    
    //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImageUrl]]];
    
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *splitedPath = [ImageUrl componentsSeparatedByString:@"/"];
    NSString *filename = [splitedPath lastObject];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageUrl]];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir,filename];
    [data writeToFile:pngFilePath atomically:YES];
    
    /*NSArray *splitedPath = [ImageUrl componentsSeparatedByString:@"/"];
    NSString *filename = [splitedPath lastObject];
    NSArray *filenameWithoutExt = [filename componentsSeparatedByString:@"."];
    filename = [filenameWithoutExt objectAtIndex:0];*/
	// If you go to the folder below, you will find those pictures
	//NSLog(@"%@",docDir);
    
	//NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir,filename];
	//NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	//[data1 writeToFile:pngFilePath atomically:YES];
    
    return pngFilePath;
    //return @"no";
}

-(void) updateImageList{
    
    for(Photo *photo in photoDataHelper.fetchedResultsController.fetchedObjects){
        photo.file_name = [self downloadImageFrom:photo.org_path];
        [photoDataHelper save];
    }
}

-(UIImage *) downloadImageFrom:(NSString *)path currentPath:(NSString *) orgPath photoID:(NSNumber *)ID asyncToImage:(UIImageView *)imageView{
    
    if([path isEqualToString:@"no"]){
        Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
        
        NetworkStatus netStatus = [internetReach currentReachabilityStatus];
        if(netStatus != NotReachable){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *newPath = [self downloadImageFrom:orgPath photoID:ID];
                [imageView setImage:[UIImage imageWithContentsOfFile:newPath]];
            });
        }
        [internetReach release];
        return [UIImage imageNamed:@"default_image.png"];
    }else{
        return [UIImage imageWithContentsOfFile:path];
    }
    
}

-(UIImage *) downloadImageFrom:(NSString *)path currentPath:(NSString *) orgPath photoID:(NSNumber *)ID asyncToImageBtn:(UIButton *)imageView{
    if([path isEqualToString:@"no"]){
        Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
        
        NetworkStatus netStatus = [internetReach currentReachabilityStatus];
        if(netStatus != NotReachable){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *newPath = [self downloadImageFrom:orgPath photoID:ID];
                [imageView setImage:[UIImage imageWithContentsOfFile:newPath] forState:UIControlStateNormal];
            });
        }
        [internetReach release];
        return [UIImage imageNamed:@"default_image.png"];
    }else{
        return [UIImage imageWithContentsOfFile:path];
    }
}

-(NSString *) downloadImageFrom:(NSString *)path photoID:(NSNumber *)ID{
    NSString *currentLanguage = [msg ReadSetting:@"language"];
    
    NSPredicate *photoQuery = [NSPredicate predicateWithFormat:@"id = %@ AND lang = %@", ID, currentLanguage];
    [photoDataHelper fetchItemsMatching:photoQuery sortingBy:@"id" asc:YES];
    Photo *photo = [photoDataHelper.fetchedResultsController.fetchedObjects objectAtIndex:0];
    
    /*NSString *ImageUrl = [NSString stringWithFormat:@"%@/img.php?width=460&height=292&bg=fff&file=%@", [msg ReadSetting:@"domain"], path];
    
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:ImageUrl]]];
    
	NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSArray *splitedPath = [ImageUrl componentsSeparatedByString:@"/"];
    NSString *filename = [splitedPath lastObject];
    NSArray *filenameWithoutExt = [filename componentsSeparatedByString:@"."];
    filename = [filenameWithoutExt objectAtIndex:0];
	// If you go to the folder below, you will find those pictures
	//NSLog(@"%@",docDir);
    
	NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir,filename];
	NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
	[data1 writeToFile:pngFilePath atomically:YES];*/
    NSString *ImageUrl = [NSString stringWithFormat:@"%@/img.php?width=360&height=240&bg=fff&file=%@", [msg ReadSetting:@"domain"], path];
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *splitedPath = [ImageUrl componentsSeparatedByString:@"/"];
    NSString *filename = [splitedPath lastObject];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageUrl]];
    NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@.png",docDir,filename];
    [data writeToFile:pngFilePath atomically:YES];
    
    photo.file_name = pngFilePath;
    [photoDataHelper save];
    //[image release];
    return pngFilePath;
}

-(void) deleteOutDateDate{
    
    if([spotDataHelper hasStore])
        [spotDataHelper clearData];
    if([districtDataHelper hasStore])
        [districtDataHelper clearData];
    if([spotTypeDataHelper hasStore])
        [spotTypeDataHelper clearData];
    /*if([locationDataHelper hasStore])
        [locationDataHelper clearData];
    if([locationTypeDataHelper hasStore])
        [locationTypeDataHelper clearData];*/
    if([pageDataHelper hasStore])
        [pageDataHelper clearData];
    
    if([photoDataHelper hasStore]){
        NSFileManager *fileManager = [NSFileManager defaultManager];
    
        [photoDataHelper fetchData];
    
        for(Photo *photo in photoDataHelper.fetchedResultsController.fetchedObjects){
            [fileManager removeItemAtPath:photo.file_name error:nil];
        }
        
        [photoDataHelper clearData];
    }
}

-(void) deleteOutDateLocation{
    
    
    if([locationDataHelper hasStore])
        [locationDataHelper clearData];
    if([locationTypeDataHelper hasStore])
        [locationTypeDataHelper clearData];
    
}

-(NSDictionary*) getRateBy:(int) spotID{
    NSString *path = [NSString stringWithFormat:@"%@%@?id=%d", [msg ReadSetting:@"domain"], [msg ReadSetting:@"get_rate"], spotID];
    NSURLResponse * response;
    NSError * error;
    NSURL *url = [[NSURL alloc] initWithString:path];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSData *result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
    
    NSString *data = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    NSDictionary *output = [parser objectWithString:data];
    
    [url release];
    [data release];
    return output;
}

-(NSNumber*) stringToNumber:(id) string{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    NSNumber * myNumber = [formatter numberFromString:string];
    [formatter release];
    return myNumber;
}

@end

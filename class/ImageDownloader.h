//
//  ImageDownloader.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年11月2日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "MessageProcessor.h"
#import "DataCollection.h"
#import "MessageProcessor.h"


@interface ImageDownloader : NSObject<UIAlertViewDelegate>{
    NSMutableArray *pathArray;
    NSMutableArray *orgPathArray;
    NSMutableArray *imgIDArray;
    NSMutableArray *imagePlaceArray;
    MessageProcessor *msg;
}

-(UIImage *) addtoList:(NSString *)path Source:(NSString *)orgPath saveTo:(NSNumber *) imgID placeToView:(id)imagePlace;

-(void) startDownloadImage;
-(void) startDownloadButton;

@end

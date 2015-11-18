//
//  ImageDownloader.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年11月2日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

- (id)init
{
    self = [super init];
    if (self) {
        pathArray = [[NSMutableArray alloc] init];
        orgPathArray = [[NSMutableArray alloc] init];
        imgIDArray = [[NSMutableArray alloc] init];
        imagePlaceArray = [[NSMutableArray alloc] init];
        msg = [[MessageProcessor alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [pathArray release];
    [orgPathArray release];
    [imgIDArray release];
    [imagePlaceArray release];
    [msg release];
    [super dealloc];
}

-(UIImage *) addtoList:(NSString *)path Source:(NSString *)orgPath saveTo:(NSNumber *) imgID placeToView:(id)imagePlace{
    if([path isEqualToString:@"no"]){
        [pathArray addObject:path];
        [orgPathArray addObject:orgPath];
        [imgIDArray addObject:imgID];
        [imagePlaceArray addObject:imagePlace];
        return [UIImage imageNamed:@"default_image.png"];
    }else{
        
        return [UIImage imageWithContentsOfFile:path];
    }
}

-(void) startDownloadImage{
    /*Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus != NotReachable){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            int length = [pathArray count];
            DataCollection *dataColl = [[DataCollection alloc] init];
            for(int i = 0; i < length; i++){
                if([[pathArray objectAtIndex:i] isEqualToString:@"no"]){
                    NSString *newPath = [dataColl downloadImageFrom:[orgPathArray objectAtIndex:i] photoID:[imgIDArray objectAtIndex:i]];
                    UIImageView *imageView = (UIImageView *) [imagePlaceArray objectAtIndex:i];
                    [imageView setImage:[UIImage imageWithContentsOfFile:newPath]];
                }
            }
            [dataColl release];
        });
    }
    [internetReach release];*/
    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus != NotReachable){
        int length = [pathArray count];
        if(length > 0){
            UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"download_data"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
            
            [loadingView show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    DataCollection *dataColl = [[DataCollection alloc] init];
                    
                    for(int i = 0; i < length; i++){
                        if([[pathArray objectAtIndex:i] isEqualToString:@"no"]){
                            NSString *newPath = [dataColl downloadImageFrom:[orgPathArray objectAtIndex:i] photoID:[imgIDArray objectAtIndex:i]];
                            UIImageView *imageView = (UIImageView *) [imagePlaceArray objectAtIndex:i];
                            [imageView setImage:[UIImage imageWithContentsOfFile:newPath]];
                        }
                    }
                    [dataColl release];
                    [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                });
            });
        }
    }
    [internetReach release];
}
-(void) startDownloadButton{
    Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
    [internetReach startNotifier];
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(netStatus != NotReachable){
        int length = [pathArray count];
        if(length > 0){
            UIAlertView *loadingView = [[[UIAlertView alloc] initWithTitle:[msg GetString:@"download_data"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil] autorelease];
            
            [loadingView show];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    DataCollection *dataColl = [[DataCollection alloc] init];
                    
                    for(int i = 0; i < length; i++){
                        if([[pathArray objectAtIndex:i] isEqualToString:@"no"]){
                            NSString *newPath = [dataColl downloadImageFrom:[orgPathArray objectAtIndex:i] photoID:[imgIDArray objectAtIndex:i]];
                            UIButton *imageView = (UIButton *) [imagePlaceArray objectAtIndex:i];
                            [imageView setImage:[UIImage imageWithContentsOfFile:newPath] forState:UIControlStateNormal];
                        }
                    }
                    [dataColl release];
                    [loadingView dismissWithClickedButtonIndex:0 animated:YES];
                });
            });
        }
    }
    [internetReach release];
}

-(void) willPresentAlertView:(UIAlertView *)alertView{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alertView.bounds.size.width / 2, alertView.bounds.size.height - 50);
    [indicator startAnimating];
    [alertView addSubview:indicator];
    [indicator release];
}

@end

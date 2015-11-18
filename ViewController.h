//
//  ViewController.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月17日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "HomeViewController.h"
#import "ConfigFinder.h"

@interface ViewController : UIViewController<UIAlertViewDelegate>{
    Reachability *internetReach;
    UIAlertView *loadingView;
    MessageProcessor *msg;
}

@property(nonatomic, retain) IBOutlet UIImageView *lanuchImage;

-(void) startDownload;
-(void) lanuchChecking;


@end

//
//  AppDelegate.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月17日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;



@end

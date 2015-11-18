//
//  MessageProcessor.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月20日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigFinder.h"

@interface MessageProcessor : NSObject{
    
}

-(void) createUserFile;
-(NSString*) ReadSetting:(NSString*) key;
-(void) SaveSettingTo:(NSString*) key withValue:(NSString*) value;
-(NSString*) GetString:(NSString*) key;
-(void) ChangeLanguage;
-(void) ChangeFont;
-(NSString*) GetLayoutType:(NSString*) xibName;

@end

//
//  MessageProcessor.m
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年8月20日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import "MessageProcessor.h"

@implementation MessageProcessor


-(void) createUserFile{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *plistPath=[plistPath1 stringByAppendingPathComponent:@"Setting.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: plistPath]) {
        NSString *orgPath = [[NSBundle mainBundle] pathForResource:@"Setting" ofType:@"plist"];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:orgPath];
        [data writeToFile:plistPath atomically:YES];
        [data release];
    }
}

-(NSString*) ReadSetting:(NSString*) key{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *plistPath=[plistPath1 stringByAppendingPathComponent:@"Setting.plist"];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSString *result = [data objectForKey:key];
    return result;
}

-(void) SaveSettingTo:(NSString*) key withValue:(NSString*) value{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath1 = [paths objectAtIndex:0];
    NSString *plistPath=[plistPath1 stringByAppendingPathComponent:@"Setting.plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    [data setObject:value forKey:key];
    
    NSString *filename=[plistPath1 stringByAppendingPathComponent:@"Setting.plist"];
    [data writeToFile:filename atomically:YES];
    [data release];
}

-(NSString*) GetString:(NSString*) key{
    NSString *langFile = [self ReadSetting:@"language"];
    NSString *orgPath = [[NSBundle mainBundle] pathForResource:langFile ofType:@"plist"];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:orgPath];
    NSString *result = [data objectForKey:key];
    return result;
}

-(void) ChangeLanguage{
    NSString *currentLanguage = [self ReadSetting:@"language"];
    if([currentLanguage isEqualToString:@"en"]){
        [self SaveSettingTo:@"language" withValue:@"zh_Hant"];
    }else{
        [self SaveSettingTo:@"language" withValue:@"en"];
    }

}
-(void) ChangeFont{
    int currentFontSize = [[self ReadSetting:@"font_size"] integerValue];
    if(currentFontSize + 1 > 6){
        currentFontSize = 1;
    }else{
        currentFontSize+=1;
    }
    [self SaveSettingTo:@"font_size" withValue:[NSString stringWithFormat:@"%d", currentFontSize]];
}

-(NSString*) GetLayoutType:(NSString*) xibName{
    if(IPAD){
        return [NSString stringWithFormat:@"%@_iPad", xibName];
    }else{
        return xibName;
    }
}

@end

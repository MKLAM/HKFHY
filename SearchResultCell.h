//
//  SearchResultCell.h
//  HKFHY
//
//  Created by Tsang Tsz Kit on 13年9月2日.
//  Copyright (c) 2013年 James Tsang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property(nonatomic, retain) IBOutlet UIImageView *thumbnail;
@property(nonatomic, retain) IBOutlet UILabel *title;
@property(nonatomic, retain) IBOutlet UILabel *shortDesc;

@end

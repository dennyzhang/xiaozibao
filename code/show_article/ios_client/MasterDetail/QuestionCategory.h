//
//  QuestionCategory.h
//  MasterDetail
//
//  Created by mac on 14-4-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionCategory : NSObject
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSMutableArray *questions;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UILabel* titleLabel;
@property (nonatomic, assign) BOOL isloaded;

- (void)initialize:(UITableView*)tableView_t
        titleLabel:(UILabel*)titleLabel_t;
@end

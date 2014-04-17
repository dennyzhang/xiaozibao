//
//  QuestionCategory.m
//  MasterDetail
//
//  Created by mac on 14-4-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "QuestionCategory.h"

@implementation QuestionCategory

@synthesize category, questions, tableView, titleLabel, isloaded;

- (void)initialize:(UITableView*)tableView_t
        titleLabel:(UILabel*)titleLabel_t
{
  self.questions = [[NSMutableArray alloc] init];
  self.tableView = tableView_t;
  self.titleLabel = titleLabel_t;
  self.category = self.titleLabel.text; 
}

// TODO: memory leak
@end
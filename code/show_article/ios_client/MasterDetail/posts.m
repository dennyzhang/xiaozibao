//
// posts.m
// MasterDetail
//
// Created by mac on 13-7-22.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "Posts.h"

@implementation Posts
@synthesize postid, title, summary, category, content;

- (id)init
{
  self = [super init];
  if(self) {
    // Initialization code here
    postid=@"";
    title=@"";
    summary=@"";
    category=@"";
    content=@"";
  }
  return self;
}

@end

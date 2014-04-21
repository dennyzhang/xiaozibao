//
//  posts postsSqlite.h
//  MasterDetail
//
//  Created by mac on 13-7-21.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "/usr/include/sqlite3.h"
#import "/usr/local/opt/sqlite/include/sqlite3.h"
#import "MyGlobal.h"
#import "Posts.h"

#define DB_SEPERATOR @"someseperator"
@interface PostsSqlite : NSObject {
    sqlite3 *postsDB;
}

+ (bool)initDB;

+ (NSMutableArray*)getPostsBySql:(NSString *)querySQL;

+ (Posts*)getPost:(NSString *)postId;

+ (bool)savePost:(NSString *)postId
         summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
           source:(NSString *)source
         content:(NSString *)content
        metadata:(NSString*)metadata;

+ (bool)updatePost:(NSString *)postId
         summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
           source:(NSString *)source
         content:(NSString *)content
        metadata:(NSString*)metadata;

+ (bool)cleanCache;

+ (void)getDefaultPosts:(NSString *)category
          objects:(NSMutableArray *) objects
      hideReadPosts:(BOOL) hideReadPosts;

+ (bool)loadRecommendPosts:(NSString *)category
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview;

+ (bool)loadSavedPosts:(NSMutableArray *) objects;

+ (bool)addPostReadCount:(NSString *)postId
                   category:(NSString *)category;

+ (bool)updatePostBoolField:(NSString *)postId
                  boolValue:(BOOL)boolValue
                  fieldName:(NSString*)fieldName
                   category:(NSString *)category;

+ (bool)updatePostMetadata:(NSString *)postId
                  metadata:(NSString*)metadata
                  category:(NSString *)category;
@end

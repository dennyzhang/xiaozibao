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
#import "Posts.h"
#import "constants.h"

#define DB_SEPERATOR @"someseperator"
@interface PostsSqlite : NSObject {
    sqlite3 *postsDB;
}

+ (bool)initDB: (sqlite3 *)postsDB
        dbPath:(NSString *) dbPath;

+ (Posts*)getPost: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
           postId:(NSString *)postId;

+ (bool)savePost: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
         summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
           source:(NSString *)source
         content:(NSString *)content
        metadata:(NSString*)metdata;

+ (bool)cleanCache: (sqlite3 *)postsDB
            dbPath:(NSString *)dbPath;

+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            category:(NSString *)category
          objects:(NSMutableArray *) objects
    hideReadPosts:(BOOL) hideReadPosts
        tableview:(UITableView *)tableview;

+ (bool)addPostReadCount: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                   category:(NSString *)category;

+ (bool)updatePostBoolField: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                  boolValue:(BOOL)boolValue
                  fieldName:(NSString*)fieldName
                   category:(NSString *)category;

@end

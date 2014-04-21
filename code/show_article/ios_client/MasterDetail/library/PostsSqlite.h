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

+ (bool)initDB: (sqlite3 *)postsDB
        dbPath:(NSString *) dbPath;

+ (NSMutableArray*)getPostsBySql: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
           querySQL:(NSString *)querySQL;

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
        metadata:(NSString*)metadata;

+ (bool)cleanCache: (sqlite3 *)postsDB
            dbPath:(NSString *)dbPath;

+ (void)getDefaultPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            category:(NSString *)category
          objects:(NSMutableArray *) objects
      hideReadPosts:(BOOL) hideReadPosts;

+ (bool)loadRecommendPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            category:(NSString *)category
          objects:(NSMutableArray *) objects
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

+ (bool)updatePostMetadata:(sqlite3 *)postsDB
                    dbPath:(NSString *) dbPath
                    postId:(NSString *)postId
                  metadata:(NSString*)metadata
                  category:(NSString *)category;

+ (sqlite3 *)openSqlite:(NSString*) dbPath;
@end

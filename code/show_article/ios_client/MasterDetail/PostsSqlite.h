//
//  posts postsSqlite.h
//  MasterDetail
//
//  Created by mac on 13-7-21.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "/usr/include/sqlite3.h"
//#import "/usr/local/opt/sqlite/include/sqlite3.h"
#import "/opt/local/include/sqlite3.h"
#import "Posts.h"

@interface PostsSqlite : NSObject {
    sqlite3 *postsDB;
}
@property (nonatomic, retain) NSString* postDB;

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
         content:(NSString *)content;

+ (bool)mark: (sqlite3 *)postDB
      dbPath:(NSString *)dbPath
      postId:(NSString *)postId
        mark:(BOOL)mark;


+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            topic:(NSString *)topic
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview;

+ (bool)addPostReadCount: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                   topic:(NSString *)topic;
@end

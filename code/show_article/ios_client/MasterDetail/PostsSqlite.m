//
// posts postsSqlite.m
// MasterDetail
//
// Created by mac on 13-7-21.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "PostsSqlite.h"

@implementation PostsSqlite

+ (bool)initDB: (sqlite3 *)postsDB
        dbPath:(NSString *) dbPath
{
  bool ret = NO;

  char *errMsg;
  const char *dbpath = [dbPath UTF8String];
  NSLog(@"initDB");
  const char *sql_stmt = "CREATE TABLE IF NOT EXISTS POSTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, POSTID TEXT, CATEGORY TEXT, TITLE TEXT, CONTENT TEXT)";
  //const char *sql_stmt = "drop table posts";
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      if (sqlite3_exec(postsDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
          ret = NO;
          NSLog(@"err for initDB");
          NSLog(@"%s", errMsg);
        }

      ret = YES;
    }
  return ret;
}

+ (bool)isExists: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
{
  const char *dbpath = [dbPath UTF8String];
  sqlite3_stmt *statement;
  NSString *querySQL = [NSString stringWithFormat: @"SELECT POSTID FROM POSTS WHERE POSTID=\"%@\"", postId];
  const char *query_stmt = [querySQL UTF8String];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
          if (sqlite3_step(statement) == SQLITE_ROW)
            {
              NSLog([NSString stringWithFormat: @"Post exists. id:%@.", postId]);
              return YES;
            }
        }
      sqlite3_finalize(statement);
      sqlite3_close(postsDB);
    }
  return NO;
}

+ (bool)savePost: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
        category:(NSString *)category
           title:(NSString *)title
         content:(NSString *)content
{
  bool ret;
  const char *dbpath = [dbPath UTF8String];
  NSLog([NSString stringWithFormat: @"savePost. id:%@, title:%@", postId, title]);
  sqlite3_stmt *statement;
  NSString *insertSQL = [NSString stringWithFormat:
                                    @"INSERT INTO POSTS (POSTID, CATEGORY, TITLE, CONTENT) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",
                                  postId, category, title, content];
  const char *insert_stmt = [insertSQL UTF8String];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      sqlite3_prepare_v2(postsDB, insert_stmt, -1, &statement, NULL);

      if (sqlite3_step(statement) != SQLITE_DONE)
        ret = NO;
      else
        ret = YES;
    }
  else {
    ret = NO;
  }

  sqlite3_finalize(statement);
  sqlite3_close(postsDB);
  return ret;
}

// TODO: refine later
+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview
{
  const char *dbpath = [dbPath UTF8String];
  sqlite3_stmt *statement;
  NSString *querySQL = @"SELECT content FROM POSTS order by id desc limit 10";
  const char *query_stmt = [querySQL UTF8String];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
          while (sqlite3_step(statement) == SQLITE_ROW)
            {
              NSLog(@"load posts here");
              NSString *content = [[NSString alloc] initWithUTF8String:
                                                      (const char *) sqlite3_column_text(statement, 0)];
              [objects insertObject:content atIndex:0];
              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
              [tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
      sqlite3_finalize(statement);
      sqlite3_close(postsDB);
    }
  return NO;
}

@end

//
// posts postsSqlite.m
// MasterDetail
//
// Created by mac on 13-7-21.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "PostsSqlite.h"

@implementation PostsSqlite
NSLock *lock;

+ (bool)initDB
{
    bool ret = NO;
    char *errMsg;

    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    NSLog(@"initDB");
    const char *sql_stmt = "CREATE TABLE IF NOT EXISTS POSTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, POSTID TEXT UNIQUE, SUMMARY TEXT, CATEGORY TEXT, TITLE TEXT, CONTENT TEXT, METADATA TEXT, SOURCE TEXT, READCOUNT INT DEFAULT 0, ISFAVORITE INT DEFAULT 0, ISVOTEUP INT DEFAULT 0, ISVOTEDOWN INT DEFAULT 0)";
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
    sqlite3_close(postsDB);
    return ret;
}

+ (bool)cleanCache
{
    bool ret;

    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    sqlite3_stmt *statement = NULL;
    NSString *deleteSQL = @"DELETE FROM POSTS WHERE isfavorite=0;";
    NSLog(@"cleanCache deleteSQL:%@", deleteSQL);
    const char *delete_stmt = [deleteSQL UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, delete_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            ret = NO;
        }
        else
            ret = YES;
    }
    else {
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}

+ (NSMutableArray*)getPostsBySql:(NSString *)querySQL
{
    NSMutableArray* posts = [[NSMutableArray alloc] init];

    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    sqlite3_stmt *statement;
    //NSLog(@"getPostsBySql querySQL: %@", querySQL);
    const char *query_stmt = [querySQL UTF8String];
    [lock lock];

    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                Posts* post = [[Posts alloc] init];
                NSString* postid = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString* summary = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString* category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSString* title = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                NSString* content = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                content = [content stringByReplacingOccurrencesOfString:DB_SEPERATOR withString:@"\""];
                NSString* source = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSNumber *readcount = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 6)];
                NSNumber *isfavorite = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 7)];
                NSNumber *isvoteup = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 8)];
                NSNumber *isvotedown = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 9)];
                NSString* metadata = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)];
                
                [post setPostid:postid];
                [post setSummary:summary];
                [post setCategory:category];
                [post setTitle:title];
                [post setContent:content];
                [post setSource:source];
                [post setReadcount:readcount];
                [post setIsfavorite:[isfavorite intValue]];
                [post setIsvoteup:[isvoteup intValue]];
                [post setIsvotedown:[isvotedown intValue]];
                [post set_metadata:metadata];
                
                [posts addObject:post];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(postsDB);
    }

    [lock unlock];
    return posts;

}

+ (bool)savePost:(NSString *)postId
         summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
           source:(NSString *)source
         content:(NSString *)content
        metadata:(NSString*)metadata
{
    bool ret;
    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    NSLog(@"savePost. id:%@, metadata:%@, title:%@", postId, metadata, title);
    sqlite3_stmt *statement = NULL;
    content = [content stringByReplacingOccurrencesOfString: @"\"" withString:DB_SEPERATOR];
    NSString *insertSQL = [NSString
                           stringWithFormat:
                           @"INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                            postId, category, summary, title, source, content, metadata];
    const char *insert_stmt = [insertSQL UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSString* errmsg = [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)];
            if ([errmsg isEqualToString:@"column POSTID is not unique"]) {
              ret = YES;
            }
            else {
              NSLog(@"error: %@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
              NSLog(@"insertSQL:%@",insertSQL);
              ret = NO;
            }
        }
        else
            ret = YES;
    }
    else {
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}


+ (Posts*)getPost:(NSString *)postId
{
    Posts* post = nil;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE POSTID=\"%@\"", postId];
    NSMutableArray* posts = [PostsSqlite getPostsBySql:querySQL];
    if ([posts count] == 1) {
      post = posts[0];
    }
    return post;
}

+ (void)getDefaultPosts:(NSString *)category
          objects:(NSMutableArray *) objects
    hideReadPosts:(BOOL) hideReadPosts
{
    NSLog(@"loadposts, category:%@, hideReadPosts:%d",category, hideReadPosts);
    NSString *querySQL;
    if ([category isEqualToString:SAVED_QUESTIONS]) {
      querySQL = @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE isfavorite=1 ORDER BY ID DESC LIMIT 10";
    }
    else {
      if (hideReadPosts == TRUE) {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" and READCOUNT=0 ORDER BY ID DESC LIMIT 10", category];
      }
      else {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" ORDER BY ID DESC LIMIT 10", category];
      }
    }
    NSLog(@"sql: %@", querySQL);
    NSMutableArray* posts = [PostsSqlite getPostsBySql:querySQL];

    for(int i=[posts count] - 1; i>=0; i--) {
      [objects insertObject:posts[i] atIndex:0];                
    }
}

+ (bool)loadRecommendPosts:(NSString *)category
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview
{
    bool ret = NO;
    NSString *querySQL;
    querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" ORDER BY ISFAVORITE DESC, READCOUNT DESC, ISVOTEUP DESC, ISVOTEDOWN ASC, ID DESC LIMIT 10", category];

    NSLog(@"sql: %@", querySQL);

    NSMutableArray* posts = [PostsSqlite getPostsBySql:querySQL];
    for(int i=[posts count] - 1; i>=0; i--) {
      [objects insertObject:posts[i] atIndex:0];
                
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      [tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      ret = YES;
    }
    return ret;
}

+ (bool)addPostReadCount:(NSString *)postId
                   category:(NSString *)category
{
    bool ret;
    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    NSLog(@"addPostReadCount. id:%@, category:%@", postId, category);
    sqlite3_stmt *statement = NULL;
    NSString *updateSql = [NSString
                           stringWithFormat:
                           @"UPDATE POSTS SET readcount=readcount+1 WHERE postid=\"%@\" and category=\"%@\"",
                           postId, category];
    const char *sql_stmt = [updateSql UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, sql_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            ret = NO;
        }
        else
            ret = YES;
    }
    else {
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}

+ (bool)updatePostMetadata:(NSString *)postId
                  metadata:(NSString*)metadata
                  category:(NSString *)category
{
    bool ret;
    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    sqlite3_stmt *statement = NULL;
    NSString *updateSql = [NSString
                           stringWithFormat:
                           @"UPDATE POSTS SET METADATA=\"%@\" WHERE postid=\"%@\" and category=\"%@\"",
                            metadata, postId, category];
    const char *sql_stmt = [updateSql UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, sql_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            ret = NO;
        }
        else
            ret = YES;
    }
    else {
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}

+ (bool)updatePostBoolField:(NSString *)postId
                  boolValue:(BOOL)boolValue
                  fieldName:(NSString*)fieldName
                   category:(NSString *)category
{
    bool ret;
    sqlite3* postsDB = NULL;
    const char *dbpath = [[MyGlobal singleton].dbPath UTF8String];

    NSLog(@"updatePostBoolField. id:%@, category:%@", postId, category);
    sqlite3_stmt *statement = NULL;
    NSString *updateSql = [NSString
                           stringWithFormat:
                           @"UPDATE POSTS SET %@=%d WHERE postid=\"%@\" and category=\"%@\"",
                            fieldName, boolValue, postId, category];
    const char *sql_stmt = [updateSql UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, sql_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            ret = NO;
        }
        else
            ret = YES;
    }
    else {
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}
@end
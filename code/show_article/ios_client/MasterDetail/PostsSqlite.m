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

+ (bool)initDB: (sqlite3 *)postsDB
        dbPath:(NSString *) dbPath
{
    bool ret = NO;
    
    char *errMsg;
    const char *dbpath = [dbPath UTF8String];
    NSLog(@"initDB");
    //drop table posts;
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

+ (bool)cleanCache: (sqlite3 *)postsDB
            dbPath:(NSString *)dbPath
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement = NULL;
    NSString *deleteSQL = @"DELETE FROM POSTS WHERE isfavorite=0;";
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

+ (Posts*)getPost: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
           postId:(NSString *)postId
{
    Posts* post = nil;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE POSTID=\"%@\"", postId];
    const char *query_stmt = [querySQL UTF8String];
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                post = [[Posts alloc] init];
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
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(postsDB);
    }
    [lock unlock];
    return post;
}

+ (bool)savePost: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
         summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
           source:(NSString *)source
         content:(NSString *)content
        metadata:(NSString*)metadata
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
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
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            NSLog(@"insertSQL:%@",insertSQL);
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

// TODO: refine later
+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            category:(NSString *)category
          objects:(NSMutableArray *) objects
    hideReadPosts:(BOOL) hideReadPosts
        tableview:(UITableView *)tableview
{
    NSLog(@"loadposts, category:%@, hideReadPosts:%d",category, hideReadPosts);
    bool ret = NO;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL;
    if ([category isEqualToString:SAVED_QUESTIONS]) {
      querySQL = @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE isfavorite=1 ORDER BY ID DESC LIMIT 10";
    }
    else {
      if (hideReadPosts == true) {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" and READCOUNT=0 ORDER BY ID DESC LIMIT 10", category];
      }
      else {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" ORDER BY ID DESC LIMIT 10", category];
      }
    }
    NSLog(@"sql: %@", querySQL);
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
                
                [objects insertObject:post atIndex:0];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                ret = YES;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(postsDB);
    }
    [lock unlock];
    return ret;
}

// TODO: refine later
+ (bool)loadRecommendPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            category:(NSString *)category
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview
{
    bool ret = NO;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL;
    querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISFAVORITE, ISVOTEUP, ISVOTEDOWN, METADATA FROM POSTS WHERE CATEGORY =\"%@\" ORDER BY ISFAVORITE DESC, READCOUNT DESC, ISVOTEUP DESC, ISVOTEDOWN ASC, ID DESC LIMIT 10", category];

    NSLog(@"sql: %@", querySQL);
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
                
                [objects insertObject:post atIndex:0];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                ret = YES;
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(postsDB);
    }
    [lock unlock];
    return ret;
}

+ (bool)addPostReadCount: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                   category:(NSString *)category
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
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

+ (bool)updatePostBoolField: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                  boolValue:(BOOL)boolValue
                  fieldName:(NSString*)fieldName
                   category:(NSString *)category
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
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

+ (NSString *)getDBPath
{
    NSArray* dirPaths;
    NSString* docsDir;
    NSString* dbPath;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    dbPath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"posts.db"]];  
    return dbPath;
}

+ (sqlite3 *)openSqlite:(NSString*) dbPath
{
    sqlite3* postsDB;

    //if ([filemgr fileExistsAtPath: dbPath ] == NO)
    if ([PostsSqlite initDB:postsDB dbPath:dbPath] == NO) {
        NSLog(@"Error: Failed to open/create database");
    }
    return postsDB;
}
@end

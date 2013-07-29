//
//  Sqlite.h
//  ORM
//
//  Created by Jan Lindemann on 05/06/13.
//  Copyright (c) 2013 Jan Lindemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Sqlite : NSObject{
    NSString *databaseName;
    NSString *databasePath;
    sqlite3  *dbConnection;
}
- (id)init:(NSString*)database;
- (void)createTable:(NSString*)model columns:(NSMutableArray*)columns;
- (void)insertThread:(NSMutableDictionary*)data;
- (id)find:(NSString*)model object:(id)object condition:(NSString*)condition;
- (id)listIds:(NSString*)model condition:(NSString*)condition;
- (void)deleteObj:(NSString*)model condition:(NSString*)condition;
- (void)closeConnection;
@end

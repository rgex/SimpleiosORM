//
//  ORM.h
//  ORM
//
//  Created by Jan Lindemann on 03/06/13.
//  Copyright (c) 2013 Jan Lindemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Sqlite.h"

@interface ORM : NSObject{
    Sqlite* sqlite;
    NSString* databaseType;
}

- (BOOL)connect:(NSString*)dbType connectionInfos:(NSMutableDictionary*)connectionInfos;
- (void)insert:(id)object;
- (id)find:(id)object condition:(NSString*)condition;
- (NSMutableArray*)listIds:(NSString*)model condition:(NSString*)condition;
- (void)deleteObj:(NSString*)model condition:(NSString*)condition;
@end

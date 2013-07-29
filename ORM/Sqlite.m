//
//  Sqlite.m
//  ORM
//
//  Created by Jan Lindemann on 05/06/13.
//  Copyright (c) 2013 Jan Lindemann. All rights reserved.
//

#import "Sqlite.h"

@implementation Sqlite
- (id)init:(NSString*)database{
    if (self = [super init]) {
        databaseName=database;
        // Obtenir le chemins complet de la base de donées
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
        
        
        if (sqlite3_open([databasePath UTF8String], &dbConnection) != SQLITE_OK) {
            
            NSLog(@"sqlite : impossible d'ouvrir le fichier ");
            return nil;
        }
    }
    return self;
}

- (void)createTable:(NSString*)model columns:(NSMutableArray*)columns{
    /*
     Create table query example :
     
     CREATE TABLE `orm`.`orm` (
     `orm_id` INT( 11 ) NOT NULL AUTO_INCREMENT PRIMARY KEY ,
     `dsdsd` INT( 11 ) NOT NULL ,
     `sdfsdf` VARCHAR( 250 ) NOT NULL
     ) ENGINE = MYISAM ;
     */
    NSString* query=[NSString stringWithFormat:@"CREATE TABLE `%@` ( `ormId` INTEGER NOT NULL PRIMARY KEY , ",model];
    
    NSInteger i=0;
    for(NSMutableDictionary* column in columns){
        if(![[column valueForKey:@"name"] isEqualToString:@"ormId"]&&![[column valueForKey:@"name"] isEqualToString:@"_ormId"]) //on ignore le champs ormId
        {
            NSString* virgule=@"";
            if([columns count]!=i+1) //si ce n'est pas la dernière colonne on ajoute une virgule à la fin
                virgule=@",";
            else
                virgule=@""; //si c'est la denière colonne on insure pas de virgule à la fin
            
            if([[column valueForKey:@"type"] isEqualToString:@"NSInteger"])
            {
                query=[query stringByAppendingString:[NSString stringWithFormat:@"`%@` INT( 20 ) NOT NULL %@ ",[column valueForKey:@"name"],virgule]];
            }
            if([[column valueForKey:@"type"] isEqualToString:@"NSString"])
            {
                query=[query stringByAppendingString:[NSString stringWithFormat:@"`%@` VARCHAR( 250 ) NOT NULL %@ ",[column valueForKey:@"name"],virgule]];
            }
            
        }
        i++;
    }
    query=[query stringByAppendingString:@");"];
    NSLog(@"sqlite query : %@ \n",query);

    
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_exec(dbConnection,[query UTF8String], nil, &statement, NULL) != SQLITE_OK) {
        NSLog(@"error : %s",sqlite3_errmsg(dbConnection));
    } else {
        NSLog(@"Sqlite table created");
    }
}

- (void)insertThread:(NSMutableDictionary*)data{
    
    NSString* model=[data valueForKey:@"model"];
    NSMutableArray* columns=[data valueForKey:@"columns"];
    
    //au cas où la table n'existerait pas on essaye de la créer
    [self createTable:model columns:columns];
    
    /*
     Insert example query
     INSERT INTO `orm`.`model1` (
     `orm_id` ,
     `str1` ,
     `str2` ,
     `int1`
     )
     VALUES (
     NULL,
     '1',
     '2',
     '3'
     );
     */
    
    NSString* query=[NSString stringWithFormat:@"INSERT INTO `%@` (",model];
    
    
    //première partie de la requête (liste des champs)
    
    NSInteger i=0;
    for(NSMutableDictionary* column in columns){
        
        NSString* virgule=@"";
        if([columns count]!=i+1) //si ce n'est pas la dernière colonne on ajoute une virgule à la fin
            virgule=@",";
        else
            virgule=@""; //si c'est la denière colonne on insure pas de virgule à la fin
        
        if([[column valueForKey:@"type"] isEqualToString:@"NSInteger"])
        {
            query=[query stringByAppendingString:[NSString stringWithFormat:@"`%@` %@",[column valueForKey:@"name"],virgule]];
        }
        if([[column valueForKey:@"type"] isEqualToString:@"NSString"])
        {
            query=[query stringByAppendingString:[NSString stringWithFormat:@"`%@` %@",[column valueForKey:@"name"],virgule]];
        }
        
        
        i++;
    }
    NSLog(@"final count %i",[columns count]);
    
    query=[query stringByAppendingString:[NSString stringWithFormat:@" )VALUES ( "]];
    
    //Deuxième partie de la requête (valeur des champs)
    i=0;
    for(NSMutableDictionary* column in columns){
        if(![[column valueForKey:@"name"] isEqualToString:@"ormId"]&&![[column valueForKey:@"name"] isEqualToString:@"_ormId"]) //on ignore le champs ormId
        {
            NSString* virgule=@"";
            if([columns count]!=i+1) //si ce n'est pas la dernière colonne on ajoute une virgule à la fin
                virgule=@",";
            else
                virgule=@""; //si c'est la denière colonne on insure pas de virgule à la fin
            
            if([[column valueForKey:@"type"] isEqualToString:@"NSInteger"])
            {
                query=[query stringByAppendingString:[NSString stringWithFormat:@"'%@' %@",[column valueForKey:@"value"],virgule]];
            }
            if([[column valueForKey:@"type"] isEqualToString:@"NSString"])
            {
                query=[query stringByAppendingString:[NSString stringWithFormat:@"'%@' %@",[column valueForKey:@"value"],virgule]];
            }
            
        }
        else
        { //pour le champ ormId on met NULL
            query=[query stringByAppendingString:[NSString stringWithFormat:@"NULL,"]];
        }
        i++;
    }
    
    
    query=[query stringByAppendingString:@");"];
    NSLog(@"Sqlite query : %@ \n",query);
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_exec(dbConnection,[query UTF8String], nil, &statement, NULL) != SQLITE_OK) 
    {
        NSLog(@"error : %s",sqlite3_errmsg(dbConnection));
    }
    else
    {
        NSLog(@"valeurs insérés");
    }
}

- (id)find:(NSString*)model object:(id)object condition:(NSString*)condition{
    sqlite3_stmt *statement = nil;

    if([condition length]==0) //si condition est vide
        condition=@"1=1";
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIMIT 0,1",model,condition];
    NSLog(@"select query : %@\n",query);
    
    if (sqlite3_prepare_v2(dbConnection,[query UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Sqlite error : %s", sqlite3_errmsg(dbConnection));
    } else {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            for (int i=0; i<sqlite3_column_count(statement); i++) {
                //int colType = sqlite3_column_type(statement, i);
                const char* colName = sqlite3_column_name(statement, i);
                const unsigned char *col = sqlite3_column_text(statement, i);
                
                
                [object setValue:[NSString stringWithFormat:@"%s",col] forKey:[NSString stringWithFormat:@"%s",colName]];
            }
        }
        return object;
    }
    
    return nil;
}

- (id)listIds:(NSString*)model condition:(NSString*)condition{ //retourne une liste d'ids
    sqlite3_stmt *statement = nil;
    NSMutableArray *liste=[[NSMutableArray alloc] init];
    if([condition length]==0) //si condition est vide
        condition=@"1=1";
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ ",model,condition];
    NSLog(@"select query : %@\n",query);
    
    if (sqlite3_prepare_v2(dbConnection,[query UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Sqlite error : %s", sqlite3_errmsg(dbConnection));
    } else {
        int i=0;
        while (sqlite3_step(statement) == SQLITE_ROW) {

                const unsigned char *col = sqlite3_column_text(statement, 0); //l'id

                [liste insertObject:[NSString stringWithFormat:@"%s",col] atIndex:i];

                i++;
            
        }
        return liste;
    }
    
    return nil;
}

- (void)closeConnection{
    sqlite3_close(dbConnection);
}

- (void)deleteObj:(NSString*)model condition:(NSString*)condition{
    NSString* query=[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",model,condition];
    NSLog(@"sqlite query : %@ \n",query);
    
    
    
    sqlite3_stmt *statement = nil;
    if (sqlite3_exec(dbConnection,[query UTF8String], nil, &statement, NULL) != SQLITE_OK) {
        NSLog(@"error : %s",sqlite3_errmsg(dbConnection));
    } else {
        NSLog(@"Sqlite Data deleted");
    }
}
@end


//
//  ORM.m
//  ORM
//
//  Created by Jan Lindemann on 03/06/13.
//  Copyright (c) 2013 Jan Lindemann. All rights reserved.
//

#import "ORM.h"

@implementation ORM

- (BOOL)connect:(NSString*)dbType connectionInfos:(NSMutableDictionary*)connectionInfos{
    databaseType=dbType;
    if([dbType isEqualToString:@"sqlite"]){
        sqlite=[[Sqlite alloc] init:[connectionInfos valueForKey:@"dbname"]];
        if(sqlite) //si sqlite n'est pas nil
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    NSLog(@"Echec : type de base de données inconnue");
    return false; //si le type de base de données n'est pas répertorié
}
/*
- (BOOL)insert:(id)object{
    [NSThread detachNewThreadSelector:@selector(insertThread) toTarget:self withObject:nil];
    return true;
}*/

- (void)insert:(id)object{
    //on parse l'objet et l'on récupère ses properties

    unsigned int count = 0;
    Ivar* ivars = class_copyIvarList([object class], &count);    
    
    
    NSMutableArray* propertyNames = [NSMutableArray array];
    NSString* model=(NSString*)[object class];
    for (unsigned int i = 0; i < count; ++i) {
        Ivar property = ivars[i];
        const char * name = ivar_getName(property);
        const char * propertyType = ivar_getTypeEncoding(property);
        
        NSMutableDictionary* propertyName = [[NSMutableDictionary alloc] init];
        if(strstr(propertyType, "@\"NSString\"") != 0){
            //Si NSString
            [propertyName setValue:@"NSString" forKey:@"type"];
            [propertyName setValue:[NSString stringWithUTF8String:name] forKey:@"name"];
            [propertyName setValue:[(NSObject*)object valueForKey:[NSString stringWithUTF8String:name]] forKey:@"value"];
            
            NSLog(@"property is NSString");
            
        }else if(strcmp(propertyType,"q") == 0 || strcmp(propertyType,"i") == 0){
            //Si NSInteger
            [propertyName setValue:@"NSInteger" forKey:@"type"];
            [propertyName setValue:[NSString stringWithUTF8String:name] forKey:@"name"];
            [propertyName setValue:[(NSObject*)object valueForKey:[NSString stringWithUTF8String:name]] forKey:@"value"];
            
            NSLog(@"property is NSInteger");
            
        }
        else{
            NSLog(@"property have unknow type %s ",propertyType);
        }
        [propertyNames addObject:propertyName];
        //NSLog(@"Name: %@", propertyName);

    }
    free(ivars);
    
    NSLog(@"Names: %@", propertyNames);
    
    
    NSMutableDictionary* data=[[NSMutableDictionary alloc] init];
    [data setValue:model forKey:@"model"];
    [data setValue:propertyNames forKey:@"columns"];
    
    //on insère les données sur un autre thread pour ne pas bloquer l'ORM
    if([databaseType isEqualToString:@"sqlite"]) //si la base est de type sqlite
        [NSThread detachNewThreadSelector:@selector(insertThread:) toTarget:sqlite withObject:data];
    
}


- (id)find:(id)object condition:(NSString*)condition{
    NSString* model=(NSString*)[object class];
    if([databaseType isEqualToString:@"sqlite"]) //si la base est de type sqlite
        return [sqlite find:model object:object condition:condition];
    return nil;
}

- (NSMutableArray*)listIds:(NSString*)model condition:(NSString*)condition{

    if([databaseType isEqualToString:@"mysql"]) //si la base est de type mysql
        //return [mysql listIds:model object:object condition:condition];
        return nil;
    if([databaseType isEqualToString:@"sqlite"]){ //si la base est de type sqlite
        return [sqlite listIds:model condition:condition];
    }
    return nil;
}

- (void)deleteObj:(NSString*)model condition:(NSString*)condition{
    
    //if([databaseType isEqualToString:@"mysql"]) //si la base est de type mysql
      //  return nil;
    if([databaseType isEqualToString:@"sqlite"]){ //si la base est de type sqlite
        [sqlite deleteObj:model condition:condition];
    }
}

@end

Fonctionnement
===============
L'ORM permet de persister et charger des objets dans une base de donnée Sqlite.
/!\ La libraire ne fonctionne que avec ARC
Structure de l'objet

L'orm persiste à la fois les variables déclarés dans l'interface et en property.
/!\ Pour fonctionner il faut que l'objet que l'on souhaite persister déclare dans l'interface une variable "ormId" de type NSInteger (voir exemple)

Prototypes
===============
Voici les prototypes de la librairie :
```objc
- (BOOL)connect:(NSString*)dbType connectionInfos:(NSMutableDictionary*)connectionInfos;
- (void)insert:(id)object;
- (id)find:(id)object condition:(NSString*)condition;
```
La methode `connect` permet d'ouvrir une connexion vers la base de donnée.
- dbType est un NSString qui correspond au type de la base de donnée il doit ête égal à @"sqlite" pour une base Sqlite
- connectionInfos est un Dictionnaire qui contient les informations nécéssaire à la connection de la base. (Voir exemples)

La methode `insert` permet de persister un objet (l'insertion se fait de manière asynchrone et donc non bloquante).
- object est l'objet que l'on souhaite persister

La methode `find` permet de récupérer un objet.
- object est un objet du type que l'on souhaite récupérer et dont les ivars vont être écrasés par les valeurs de la base de données
- condition est un NSString avec les conditions qui permettent de trouver un objet. Ces conditions doivent être écrites en SQL
Exemple de conditions : @" ormId = 1", @" _nom = 'jean'" etc....
/!\ dans la condition de recherche une property doit s'appeller par "_nomDeLaProperty" et non "nomDeLaProperty" (il faut ajouter un underscore devant son nom)

ci-dessous quelques exemples d'utilisations
Exemples
===============
Pour les exemple l'on utilisera un objet test dont le header correspond à :
```objc
#import <Foundation/Foundation.h>

@interface TestObject : NSObject{
    NSInteger ormId;
}

@property (nonatomic) NSString* str1;
@property (nonatomic) NSString* str2;
@property (nonatomic) NSInteger int1;

@end
```
L'exemple suivant permet de persister un objet sur une base de donnée Sqlite
```objc
ORM* orm=[[ORM alloc] init];
connectionInfos=[[NSMutableDictionary alloc] init];

[connectionInfos setValue:@"testDB"  forKey:@"dbname"];
    
NSLog(@"connectionInfos : %@",connectionInfos);
if([orm connect:@"sqlite" connectionInfos:connectionInfos]){
    NSLog(@"Sqlite Connexion OK");
        
    TestObject* testObject = [[TestObject alloc] init];
    [testObject setStr1:@"valeur1"];
    [testObject setStr2:@"valeur2"];
    [testObject setInt1:11];
     
    [orm insert:testObject];
}
```
Cet exemple permet de récupérer un objet depuis une base de donnée Sqlite
```objc
ORM* orm=[[ORM alloc] init];
connectionInfos=[[NSMutableDictionary alloc] init];
[connectionInfos setValue:@"testDB"  forKey:@"dbname"];
    
NSLog(@"connectionInfos : %@",connectionInfos);
if([orm connect:@"sqlite" connectionInfos:connectionInfos]){ 
    NSLog(@"Connexion OK");
        
    TestObject* testObject = [[TestObject alloc] init];
        
    testObject = [orm find:testObject condition:nil]; //l'objet a été chargé
    //juste pour tester
    NSLog(@"int1 val : %ld",(long)[testObject int1]);
}
else
{
    NSLog(@"Connexion Echec");
}
```

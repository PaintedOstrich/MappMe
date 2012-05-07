//
//  Person.m
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#import "DebugLog.h"
@implementation Person {
    //Maps locType to a set of places.
    NSMutableDictionary* _locTypePlacesMapping;
}

@synthesize uid;
@synthesize name, sectionNumber;
@synthesize profileUrl;
@synthesize largeProfileUrl;
@synthesize mutualFriends;


-(NSString*) buildProfileUrl:(BOOL)large
{
    NSString* urlStr;
    if (large) {
        urlStr = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", self.uid];
    }
    else{
        urlStr = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", self.uid];
    }
    return urlStr;
}


-(id)initPerson:(NSString*)personId withName:(NSString*)fullName
{
    if(self = [super init]){
        self.name= fullName;
        self.uid = personId;
       self.profileUrl = [self buildProfileUrl:NO];
       self.largeProfileUrl = [self buildProfileUrl:YES];
        _locTypePlacesMapping = [[NSMutableDictionary alloc] initWithCapacity:6]; 
        self.mutualFriends = [[NSArray alloc]init];
    }
    return self;
}

-(void)addPlace:(Place*)place withType:(int)locType
{
    NSString* key = [NSString stringWithFormat:@"%d", locType];
    NSMutableSet* set = [_locTypePlacesMapping objectForKey:key];
    
    if (set == nil) {
        set = [[NSMutableSet alloc] initWithCapacity:5];
        [_locTypePlacesMapping setValue:set forKey:key];
    }
    [set addObject:place];
}

-(NSDictionary*) getPlacesMapping
{
    NSMutableDictionary* toR = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSEnumerator *enumerator = [_locTypePlacesMapping keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        NSMutableSet *tmp = [_locTypePlacesMapping objectForKey:key];
        [toR setValue:[tmp allObjects] forKey:key];
    }
    return toR;
}
//This is for TOSTRING method
- (NSString *)description{
    NSMutableString *person = [[NSMutableString alloc] initWithString:@"\n"];
    [person appendFormat:@"%@\n",self.name];
    [person appendFormat:@"\n\t uid: %@",self.uid];
    [person appendFormat:@"\n\t %@",_locTypePlacesMapping];
    [person appendFormat:@"\n\t Mutual Friends (%i) \n %@",[mutualFriends count], mutualFriends];
    return (NSString *)person;    
}

- (NSString*) getFirstName
{
    if (self.name != nil) {
        NSArray *chunks = [self.name componentsSeparatedByString: @" "];
        return [chunks objectAtIndex:0];   
    }
    return @"";
}

@end
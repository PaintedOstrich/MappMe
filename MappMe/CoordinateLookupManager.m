//
//  CoordinateLookupManager.m
//  MappMe
//
//  Created by Parker Spielman on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*This Object Uses Class Methods to Behave as a Singleton*/
/*It continues to permutate supplementary info until the location query is found*/

#import "CoordinateLookupManager.h"
#import "DebugLog.h"
#import "AFHTTPRequestOperation.h"
#import "CoordPairsHelper.h"

static CoordinateLookupManager *coordinateLookupManager = nil;

@implementation CoordinateLookupManager {
    NSOperationQueue *queue;
}


#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if (coordinateLookupManager == nil) {
            coordinateLookupManager = [[self alloc] init];
        }
    }
    return coordinateLookupManager;
}


-(id)init{
    if (self = [super init]) {
      queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

#pragma Location look up methods

/*
 * This method returns formatted query url to Google map
 */
- (NSURL *)buildUrl:(NSString *)lookup
{
    NSString *escapedLookup = [lookup stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv", escapedLookup];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

-(CoordPairsHelper*) parseResponse:(NSString*)responseStr 
{

    //TODO add more robust response by understanding error code from Google Map
    NSArray *listItems = [responseStr componentsSeparatedByString:@","];
    CoordPairsHelper* location;
    if([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"]) {
        NSString *latitude = [listItems objectAtIndex:2];
        NSString *longitude = [listItems objectAtIndex:3];
        location = [[CoordPairsHelper alloc] initWithLat:latitude andLong:longitude];
        return location;
    }
    return nil;
    
}

//successCB:(void (^)())successCB failureCB:(void (^)(NSError *error))failureCB
- (void)lookupLocation:(NSString*)locationStr  {
    NSURL *url = [self buildUrl:locationStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
        CoordPairsHelper* location = [self parseResponse:operation.responseString];
        if (location !=nil) {
            
        } else {
            
        }
     } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
         NSLog(@"Failed: %@", error.localizedDescription);
     }];
    
    //operation.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    [queue addOperation:operation];
}


#pragma mark - public class Methods
- (CoordPairsHelper *)manageCoordLookupForPlace:(NSString *)lookupString{
    return [[CoordPairsHelper alloc]initWithLat:@"500" andLong:@"600"];
}
/*returns coordinate pair from google, nil if none found*/
-(CoordPairsHelper *)manageCoordLookupForEdu:(NSString *)placeName withSupInfo:(NSDictionary*)supInfo andTypeString:(NSString *)schoolType{
    NSString * lookup = placeName;
    //Try just school name
    if(placeName == NULL){
        return nil;
    }
    
    //DebugLog(@"trying map lookup : %@ , type: %@, city: %@",placeName,schoolType,[supInfo objectForKey: @"city"]);
    [self lookupLocation:lookup];
//    if(returnCoords!= nil){
//        //return returnCoords;
//        //*****Returning here found to give bad results, add location type name for first lookup
//    }
//    //Try name with attached tag, ex. "High School", since Horace Mann does not have "High School" in name, map api cannot find it
//    if ([placeName rangeOfString:schoolType].location == NSNotFound){
//        //DebugLog(@"string does not contain type : %@", schoolType);
//        //lookup = [NSString stringWithFormat:@"%@ %@",placeName,schoolType];
//        //returnCoords = [self lookupString:lookup];
//    } 
//    //Try adding city and state info
//    if ([supInfo objectForKey:@"city"]){
//        lookup=[NSString stringWithFormat:@"%@, %@",lookup,[supInfo objectForKey:@"city"]];
//    }
//    if ([supInfo objectForKey:@"state"]){lookup=[NSString stringWithFormat:@"%@,%@",lookup,[supInfo objectForKey:@"state"]];
//    }
//    if ([supInfo objectForKey:@"state"]){lookup=[NSString stringWithFormat:@"%@,%@",lookup,[supInfo objectForKey:@"country"]];
//    }
//    returnCoords = [self lookupString:lookup];
//    if(returnCoords!= nil){
//        return returnCoords;
//    }
//    
//    
//    //Try 4
//    //remove place name and just use city
//    lookup= @"";
//    if ([supInfo objectForKey:@"city"]){lookup=[NSString stringWithFormat:@"%@",[supInfo objectForKey:@"city"]];}
//    if ([supInfo objectForKey:@"state"]){lookup=[NSString stringWithFormat:@"%@,%@",lookup,[supInfo objectForKey:@"state"]];}
//    if ([supInfo objectForKey:@"state"]){lookup=[NSString stringWithFormat:@"%@,%@",lookup,[supInfo objectForKey:@"country"]];}
//    
//    returnCoords = [self lookupString:lookup];
//    if(returnCoords!= nil){
//        return returnCoords;
//    }
//    
//    /* If no coord found, return nil*/
//    DebugLog(@"Did Not Find:  %@", placeName);
    return nil;
}


@end

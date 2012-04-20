
#import "CoordinateLookupManager.h"
#import "DebugLog.h"
#import "AFHTTPRequestOperation.h"
#import "CoordPairsHelper.h"
#import "Place.h"

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

- (void)lookupLocation:(Place*) place
{
    if ([place.name isEqualToString:@"No Name"]) {
        //TODO should not happen. figure out why.
    } else {
        NSURL *url = [self buildUrl:place.name];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
            CoordPairsHelper* location = [self parseResponse:operation.responseString];
            if (location !=nil) {
                [place addLat:location.latAsString andLong:location.longAsString];
            } else {
                //NSlog(@"Did not find");
            }
        } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
            NSLog(@"Failed: %@", error.localizedDescription);
        }];
        [queue addOperation:operation];

    }
}

@end


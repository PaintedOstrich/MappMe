
#import "CoordinateLookupManager.h"
#import "DebugLog.h"
#import "AFHTTPRequestOperation.h"
#import "CoordPairsHelper.h"
#import "Place.h"

static CoordinateLookupManager *coordinateLookupManager = nil;


//200	G_GEO_SUCCESS	 No errors occurred; the address was successfully parsed and its geocode was returned.
//500	G_GEO_SERVER_ERROR	 A geocoding or directions request could not be successfully processed, yet the exact reason for the failure is unknown.
//601	G_GEO_MISSING_QUERY	 An empty address was specified in the HTTP q parameter.
//602	G_GEO_UNKNOWN_ADDRESS	 No corresponding geographic location could be found for the specified address, possibly because the address is relatively new, or because it may be incorrect.
//603	G_GEO_UNAVAILABLE_ADDRESS	 The geocode for the given address or the route for the given directions query cannot be returned due to legal or contractual reasons.
//610	G_GEO_BAD_KEY	 The given key is either invalid or does not match the domain for which it was given.
//620	G_GEO_TOO_MANY_QUERIES	 The given key has gone over the requests limit in the 24 hour period or has submitted too many requests in too short a period of time. If you're sending multiple requests in parallel or in a tight loop, use a timer or pause in your code to make sure you don't send the requests too quickly.

typedef enum MapStatusCode {
SUCCESS = 200,
SERVER_ERROR = 500,
MISSING_QUERY = 601,
UNKNOWN_ADDRESS = 602,
UNAVAILABLE_ADDRESS = 603,
BAD_KEY = 610,
TOO_MANY_QUERIES = 620,
} MapStatusCode;

@implementation CoordinateLookupManager {
    NSOperationQueue *queue;
    BOOL operationsStarted;
}

@synthesize delegate = _delegate;


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
      //Initially allow no out going reqeust.
      [queue setMaxConcurrentOperationCount:0];
        operationsStarted = FALSE;
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

-(CoordPairsHelper*) parseResponse:(NSString*)responseStr forPlace:(Place*)place
{

    //TODO add more robust response by understanding error code from Google Map
    NSArray *listItems = [responseStr componentsSeparatedByString:@","];
    CoordPairsHelper* location;
    
    MapStatusCode status = [[listItems objectAtIndex:0] intValue];
    if(status == SUCCESS) {
        NSString *latitude = [listItems objectAtIndex:2];
        NSString *longitude = [listItems objectAtIndex:3];
        location = [[CoordPairsHelper alloc] initWithLat:latitude andLong:longitude andStatusCode:status];
        //DebugLog(@"%@ is found successfully", [place getFullAddress]);
        return location;
    } else if(status == UNKNOWN_ADDRESS) {
        DebugLog(@"%@ is an unknown address", [place getFullAddress]);
    } else if (status == UNAVAILABLE_ADDRESS) {
        DebugLog(@"%@ is an unavailable address", [place getFullAddress]);
    } else if (status == SERVER_ERROR) {
        DebugLog(@"%@ caused server error", [place getFullAddress]);
    } else if (status == MISSING_QUERY) {
        DebugLog(@"%@ caused missing query", [place getFullAddress]);
    } else if (status == BAD_KEY) {
        DebugLog(@"%@ caused bad key", [place getFullAddress]);
    } else if (status == TOO_MANY_QUERIES) {
        DebugLog(@"query limit reached (may be too fast)");
    } else {
        DebugLog(@"unknown status code:%d is caused by this lookup:%@", status, [place getFullAddress]);
    }
    location = [[CoordPairsHelper alloc] initWithLat:0 andLong:0 andStatusCode:status];
    return location;
    
}

- (void)lookupLocation:(Place*) place
{
    if ([place.name isEqualToString:@"No Name"]) {
        // DebugLog(@"A place with id:%@ is initialized without a name, Huh???", place.uid);
    } else {
        NSURL *url = [self buildUrl:place.name];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation , id responseObject) {
            CoordPairsHelper* location = [self parseResponse:operation.responseString forPlace:place];
            if (location.status == SUCCESS) {
                [place addLat:location.latAsString andLong:location.longAsString];
            } else if (location.status == TOO_MANY_QUERIES){
                //Keep retrying this request.
                [self lookupLocation:place];
            }
            [self checkFinishConditions];
        } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
            NSLog(@"Failed: %@", error.localizedDescription);
            [self checkFinishConditions];
        }];
        [queue addOperation:operation];
        
        if ([queue operationCount] > 3 && !operationsStarted) {
            //Only start operations now to make sure the didFinishOperations
            //method is not invoked too early.
            [queue setMaxConcurrentOperationCount:2];
            operationsStarted = TRUE;
            DebugLog(@"This should only be called once");
        }

    }
}

-(void) checkFinishConditions
{
    if ([queue operationCount] == 0) {
        DebugLog(@"All Operations finished!!");
        [_delegate allOperationFinished];
    }
}

-(void) cancelAllOperations
{
    [queue cancelAllOperations];
}

@end


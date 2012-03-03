//
//  Timer.m
//  FaceBookMapper
//
//  Created by Parker Spielman on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"


@implementation Timer


//@synthesize start,end;
-(id)init
{
    if (self = [super init])
    {
        start = [[NSDate alloc]init];
        stopped = FALSE;
    }
    return self;
}
-(void)endTimer{
     end =  [[NSDate alloc]init];
     stopped = TRUE;
}
//Timer continues to reun 
-(int)endTimerAndGetTotalTime{
    if (!stopped){
        [self endTimer];
    }
    int t = [end timeIntervalSinceDate:start];
    return t;
}
-(int)getCurrentTimeInterval{
    NSDate* now = [[NSDate alloc]init];
    int t = [now timeIntervalSinceDate:start];
    return t;
}


//NSDate *loadTime= [[NSDate alloc]init];
//int seconds = [now timeIntervalSinceDate:loadTime];
//NSLog(@"Total Load Time in Seconds: %i", seconds);
@end


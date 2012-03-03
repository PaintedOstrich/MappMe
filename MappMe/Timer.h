//
//  Timer.h
//  FaceBookMapper
//
//  Created by Parker Spielman on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject{
    @private
    NSDate* start;
    NSDate* end;
    BOOL stopped;
    
}
//@property (nonatomic) BOOL stopped;
//@property (nonatomic, assign) NSDate *start;
//@property (nonatomic, assign) NSDate *end;
-(id)init;
-(int)endTimerAndGetTotalTime;
-(int)getCurrentTimeInterval;

@end

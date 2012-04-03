//
//  DataProgressUpdater.h
//  MappMe
//
//  Created by Parker Spielman on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTypeEnum.h"

@protocol ProgressUpdaterDelegate
- (void)updateProgressBar:(float)progressAmount;
-(void)finishedLoading;
@end


@interface DataProgressUpdater : NSObject{
    id<ProgressUpdaterDelegate> progressUpdaterDelegate;
}

-(void)incrementSum:(locTypeEnum)locType;
-(void)setTotal:(int)total forType:(locTypeEnum)locType;
-(void)setFinishedTotal:(locTypeEnum)locType;
-(void)endLoader;
//Helper to distinguish current loc and hometown lookup
-(BOOL)hometownSet;

@property (retain) id<ProgressUpdaterDelegate> progressUpdaterDelegate;
@end

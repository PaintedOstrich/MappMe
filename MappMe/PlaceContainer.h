//
//  ObjectIdMapping.h
//  MappMe
//
//  Created by Di Peng on 04/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "AbstractContainer.h"


@interface PlaceContainer : AbstractContainer{
   NSMutableSet* blacklistedPlaces;
}
@property(atomic, retain) NSMutableSet* blacklistedPlaces;

-(Place*)get:(NSString*)town_id;

//Get all the places that has someone use it as their given locType.
//e.g. Get  all places with someone using this place as their home town etc.
-(NSArray*) getPlacesUsedAs:(locTypeEnum)locType;
-(void) loadPlacesFromDisk;
-(void) savePlacesToDisk;
-(NSArray*) getPlacesUsedAs:(locTypeEnum)locType friendsWith:(Person*)mutualFriendsWith;
@end

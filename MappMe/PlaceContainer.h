//
//  ObjectIdMapping.h
//  MappMe
//
//  Created by Parker Spielman on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"
#import "AbstractContainer.h"


@interface PlaceContainer : AbstractContainer{

}
-(Place*)get:(NSString*)town_id;

//Get all the places that has someone use it as their given locType.
//e.g. Get  all places with someone using this place as their home town etc.
-(NSArray*) getPlacesUsedAs:(locTypeEnum)locType;
-(void) savePlacesToDisk;
@end

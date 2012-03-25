//
//  FacebookImageHandler.m
//  MappMe
//
//  Created by Parker Spielman on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookImageHandler.h"

@interface FacebookImageHandler()
-(void)cacheImage:(UIImage*)image;

@end

@implementation FacebookImageHandler{
    NSMutableDictionary *imageForId;
    NSString * tmpUid;
}
-(id)init{
    if(self == [super init]){
        imageForId = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark Threading
-(UIImage*) getProfPicFromId:(NSString *)uid{
    tmpUid = uid;
	//go off to get the profile pic and replace the pic??
	if([imageForId objectForKey:uid]==nil  ){
		NSString *URStr= [[NSString alloc] initWithFormat: @"http://graph.facebook.com/%@/picture?type=square",uid];
		NSURL *url = [NSURL URLWithString:URStr]; // facebook.jpg is the url of profile pic
		UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        //[self performSelectorInBackground:@selector(cachedImage:) withObject:image];
        return image;
//		[self performSelectorOnMainThread:@selector(cachedImage:) withObject:image waitUntilDone:NO];
		
		//[idAndImage setObject:image forKey:friendID];
	}
	else {
		return [imageForId objectForKey:uid];	
    }
}

-(void) donothing {
}

-(void) cacheImage:(UIImage *)image{
	[imageForId setObject:image forKey:tmpUid];
}

@end

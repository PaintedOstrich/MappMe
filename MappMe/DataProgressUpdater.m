//
//  DataProgressUpdater.m
//  MappMe
//
//  Created by Parker Spielman on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataProgressUpdater.h"
#import "DebugLog.h"

/*
 This class sets rules for a progress bar update.
 Each type is given a weight in the init statement
 As each entry is completed by the FacebookDataHandler, it increments the running total of the type by 1/(total Num entries)
 This allows us to display a fairly accurate udpater, which is important to keep users while the app loads, which may take well over a minute if using 3g network. Much faster with wireless
 Note: This update only happens on first launch
 */
@implementation DataProgressUpdater{
    float hometownSum, highSchoolSum, collegeSum, gradSchoolSum, workSum;
    int hometownEntries,highSchoolEntries, collegeEntries,gradSchoolEntries, workEntries;
}

@synthesize progressUpdaterDelegate;

-(id)init{
    if(self = [super init]){
        hometownEntries=0;
        highSchoolEntries=0;
        collegeEntries=0;
        gradSchoolEntries=0;
        hometownSum =0;
        highSchoolSum=0;
        collegeSum=0;
        gradSchoolSum=0;
        workEntries=0;
        workSum=0;
        
    }
    return self;
}
//Function here so it can be wrapped by selector to run in  main thread
-(void)callUpdateProgressProtocol:(NSDecimalNumber*)progress{
    [progressUpdaterDelegate updateProgressBar:[progress floatValue]];
}
-(void)callFinishedLoading{
    [progressUpdaterDelegate finishedLoading];
}
//Debug
-(NSString*)printTotals{
    NSMutableString *values = [[NSMutableString alloc] initWithString:@"Values"];
    [values appendFormat:@"\n\t Hometown(%i)  : %f",hometownEntries,hometownSum];
    [values appendFormat:@"\n\t High School(%i) : %f",highSchoolEntries,highSchoolSum];
    [values appendFormat:@"\n\t College(%i)     : %f",collegeEntries,collegeSum];
    [values appendFormat:@"\n\t Grad School(%i) : %f",gradSchoolEntries,gradSchoolSum];
    
    return values;
    
}
//Computes total for progress bar
-(void)computeTotalAndUpdate{
    //Weights
    float ht =0.2;
    float hs =0.3;
    float co =0.3;
    float gr =0.2;
    float wk =0.0;
    float total = 0.0;
    total += ht * hometownSum;
    total += hs * highSchoolSum;
    total += co * collegeSum;
    total += gr * gradSchoolSum;
    total += wk * workSum;
    //update ui through main thread
    NSDecimalNumber *totalDec = [[NSDecimalNumber alloc] initWithFloat:total];
    //DebugLog(@"amount: %f",total);
    //DebugLog([self printTotals]);
    SEL update = @selector(callUpdateProgressProtocol:);
    [self performSelectorOnMainThread:update withObject:totalDec waitUntilDone:NO];
    if (total >=1) {
        SEL finished = @selector(callFinishedLoading);
       // [self performSelectorOnMainThread:finished withObject:nil waitUntilDone:NO];
    }
}
-(void)endLoader{
    DebugLog(@"manually called finished loading");
    SEL finished = @selector(callFinishedLoading);
    [self performSelectorOnMainThread:finished withObject:nil waitUntilDone:NO];
}
//Helper method to check for zero divisor and output alert!
-(BOOL)notDivideByZero:(locTypeEnum)locType{
    switch(locType){
        case(tHomeTown):
            return hometownEntries !=0;
        case(tHighSchool):
            return highSchoolEntries != 0;
        case(tCollege):
            return collegeEntries !=0;
        case(tGradSchool):
            return gradSchoolEntries !=0;
        case(tWork):
            return workEntries !=0;
        default:
            DebugLog(@"Warning, hitting default for Progress Updater");
    }  
    return FALSE;
}
-(void)incrementSum:(locTypeEnum)locType{
    if ([self notDivideByZero:locType]) {
        switch(locType){
            case(tHomeTown):
                hometownSum+= (float)1/hometownEntries;
//                hometownSum++;
                break;
            case(tHighSchool):
                highSchoolSum += (float)1/highSchoolEntries;
//                highSchoolSum++;
                break;
            case(tCollege):
                collegeSum += (float)1/collegeEntries;
//                collegeSum++;
                break;
            case(tGradSchool):
                gradSchoolSum += (float)1/gradSchoolEntries;
//                gradSchoolSum++;
                break;
            case(tWork):
                workSum += (float)1/workEntries;
//                workSum++;
                break;
            default:
                DebugLog(@"Warning, hitting default for Progress Updater");
                DebugLog(@"for type %@",[LocationTypeEnum getNameFromEnum:locType]);
                break;
        }  
    }else{
        DebugLog(@"WARNING: Divide by zero error");
    }
    //Update progress bar after change in sum
    [self computeTotalAndUpdate];
    
}
-(void)setFinishedTotal:(locTypeEnum)locType{
    switch(locType){
        case(tHomeTown):
            hometownSum=1;
            break;
        case(tHighSchool):
            highSchoolSum = 1;
            break;
        case(tCollege):
            collegeSum = 1;
            break;
        case(tGradSchool):
            gradSchoolSum  = 1;
            break;
        case(tWork):
            workSum = 1;
            break;
        default:
            DebugLog(@"Warning, hitting default for Progress Updater");
            DebugLog(@"for type %@",[LocationTypeEnum getNameFromEnum:locType]);
            break;
    }
    //Update progress bar after change in sum
    [self computeTotalAndUpdate];

}
-(void)setTotal:(int)total forType:(locTypeEnum)locType{
    switch(locType){
        case(tHomeTown):
            hometownEntries=total;
            break;
        case(tHighSchool):
            highSchoolEntries = total;
            break;
        case(tCollege):
            collegeEntries = total;
            break;
        case(tGradSchool):
            gradSchoolEntries = total;
            break;
        case(tWork):
            workEntries = total;
            break;
        default:
            DebugLog(@"Warning, hitting default for Progress Updater");
            DebugLog(@"for type %@",[LocationTypeEnum getNameFromEnum:locType]);
            break;
    }       
}
//Distinguishes city update from current location vs. hometown
-(BOOL)hometownSet{
    return hometownEntries !=0;
}

@end

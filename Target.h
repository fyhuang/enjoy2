//
//  Target.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Target : NSObject {
	BOOL running;
    int inputValue;
}

@property(readwrite) BOOL running;
@property(readwrite) int inputValue;
-(void) trigger;
-(void) untrigger;
-(NSString*) stringify;
+(Target*) unstringify: (NSString*) str withConfigList: (NSArray*) configs;

@end

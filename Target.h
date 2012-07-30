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
    BOOL isContinuous;
    double inputValue;
}

@property(readwrite) BOOL running;
@property(readonly) BOOL isContinuous;
@property(readwrite) double inputValue;
-(void) trigger: (JoystickController *)jc;
-(void) untrigger: (JoystickController *)jc;
-(void) update: (JoystickController *)jc;
-(NSString*) stringify;
+(Target*) unstringify: (NSString*) str withConfigList: (NSArray*) configs;

@end

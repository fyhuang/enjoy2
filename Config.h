//
//  Config.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Target;

@interface Config : NSObject {
	NSString *name;
	NSMutableDictionary *entries;
}

@property(readwrite, copy) NSString* name;
@property(readonly) NSMutableDictionary* entries;

-(void) setTarget:(Target*)target forAction:(id)jsa;
-(Target*) getTargetForAction: (id) jsa;

-(void) saveJSONTo: (NSURL*)filename;
// Load only the name from the JSON file (for loading 1st pass)
-(Config*) loadSkelFromJSON: (NSData*)jsonData;
-(Config*) loadFromJSON: (NSData*)jsonData withConfigList:(NSArray*)configs;

@end

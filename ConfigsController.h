//
//  ConfigsController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Config;
@class TargetController;

@interface ConfigsController : NSObject {
	NSMutableArray* configs;
	IBOutlet NSButton* removeButton;
	IBOutlet NSTableView* tableView;
	IBOutlet TargetController* targetController;
    IBOutlet ApplicationController *appController;
    
	Config* currentConfig;
	Config* neutralConfig; /* last config to be manually selected */
	ProcessSerialNumber attachedApplication;
    
}

-(IBAction) addPressed: (id)sender;
-(IBAction) removePressed: (id)sender;
-(void) activateConfig: (Config*)config forApplication: (ProcessSerialNumber*) psn;

-(void) loadAllFromDir: (NSURL*)dir;
-(NSDictionary*) dumpAll;
-(void) loadAllFrom: (NSDictionary*) dict;

@property(readonly) Config* currentConfig;
@property(readonly) Config* currentNeutralConfig;
@property(readonly) NSArray* configs;
@property(readonly) ProcessSerialNumber* targetApplication;
-(void) save;
-(void) load;

-(void) applicationSwitchedTo: (NSString*) name withPsn: (ProcessSerialNumber) psn;

-(NSURL*) getMappingsDirectory;
-(void) makeMappingsDirectory;
-(NSURL*) getMappingFilenameFor: (Config*) config;

@end

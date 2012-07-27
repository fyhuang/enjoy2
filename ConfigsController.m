//
//  ConfigsController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation ConfigsController

@synthesize configs;

-(id) init {
	if(self = [super init]) {
		configs = [[NSMutableArray alloc] init];
		currentConfig = [[Config alloc] init];
		[currentConfig setName: @"(default)"];
		[currentConfig setProtect: YES];
		[configs addObject: currentConfig];		
	}
	return self;
}

-(void) restoreNeutralConfig {
	if(!neutralConfig)
		return;
	if([configs indexOfObject:neutralConfig] < 0) {// deleted, keep what we have
		neutralConfig = NULL;
		return;
	}
	[self activateConfig: neutralConfig forApplication: NULL];
}

-(void) activateConfig: (Config*)config forApplication: (ProcessSerialNumber*) psn {
	if(currentConfig == config)
		return;

	if(psn) {
		if(!neutralConfig)
			neutralConfig = currentConfig;
		attachedApplication = *psn;
	} else {
		neutralConfig = NULL;
	}
	
	if(currentConfig != NULL) {
		[targetController reset];
	}
	currentConfig = config;
	[removeButton setEnabled: ![config protect]];
	[targetController load];
	[[[NSApplication sharedApplication] delegate] configChanged];
	[tableView selectRow: [configs indexOfObject: config] byExtendingSelection: NO];
}

-(IBAction) addPressed: (id)sender {
	Config* newConfig = [[Config alloc] init];
	[newConfig setName: @"untitled"];
	[configs addObject: newConfig];
	[[[NSApplication sharedApplication] delegate] configsChanged];
	[tableView reloadData];
	[tableView selectRow: ([configs count]-1) byExtendingSelection: NO];
	[tableView editColumn: 0 row:([configs count]-1) withEvent:nil select:YES];
}
-(IBAction) removePressed: (id)sender {
	// save changes first
	[tableView reloadData];
	Config* current_config = [configs objectAtIndex: [tableView selectedRow]];
	if([current_config protect])
		return;
	[configs removeObjectAtIndex: [tableView selectedRow]];
	
	// remove all "switch to configuration" actions
	for(int i=0; i<[configs count]; i++) {
		NSMutableDictionary* entries = [(Config*)[configs objectAtIndex:i] entries];
		for(id key in entries) {
			Target* target = (Target*) [entries objectForKey: key];
			if([target isKindOfClass: [TargetConfig class]] && [(TargetConfig*)target config] == current_config)
				[entries removeObjectForKey: key];
		}
	}
	[[[NSApplication sharedApplication] delegate] configsChanged];
	
	[tableView reloadData];
}

-(void)tableViewSelectionDidChange:(NSNotification*) notify {
	[self activateConfig: (Config*)[configs objectAtIndex:[tableView selectedRow]] forApplication: NULL];
}
	
-(id) tableView: (NSTableView*)view objectValueForTableColumn: (NSTableColumn*) column row: (int) index {
    NSParameterAssert(index >= 0 && index < [configs count]);
	return [[configs objectAtIndex: index] name];
}

-(void) tableView: (NSTableView*) view setObjectValue:obj forTableColumn:(NSTableColumn*) col row: (int)index {
    NSParameterAssert(index >= 0 && index < [configs count]);
	/* ugly hack so stringification doesn't fail */
	NSString* newName = [(NSString*)obj stringByReplacingOccurrencesOfString: @"~" withString: @""];
	[(Config*)[configs objectAtIndex: index] setName: newName];
	[targetController refreshConfigsPreservingSelection:YES];
	[tableView reloadData];
	[[[NSApplication sharedApplication] delegate] configsChanged];
}

-(int)numberOfRowsInTableView: (NSTableView*)table {
	return [configs count];
}

-(BOOL)tableView: (NSTableView*)view shouldEditTableColumn: (NSTableColumn*) column row: (int) index {
	return ![[configs objectAtIndex: index] protect];
}	

-(Config*) currentConfig {
	return currentConfig;
}

-(Config*) currentNeutralConfig {
	if(neutralConfig)
		return neutralConfig;
	return currentConfig;
}

-(void) save {
    [[NSUserDefaults standardUserDefaults] setObject:[self dumpAll] forKey:@"configurations"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
-(void) load {
	[self loadAllFrom: [[NSUserDefaults standardUserDefaults] objectForKey:@"configurations"]];
}

-(NSDictionary*) dumpAll {
	NSMutableDictionary *envelope = [[NSMutableDictionary alloc] init];
	NSMutableArray* ary = [[NSMutableArray alloc] init];
	for(Config* config in configs) {
		NSMutableDictionary* cfgInfo = [[NSMutableDictionary alloc] init];
		[cfgInfo setObject:[config name] forKey:@"name"];
		NSMutableDictionary* cfgEntries = [[NSMutableDictionary alloc] init];
		for(id key in [config entries]) {
			[cfgEntries setObject:[[[config entries]objectForKey:key]stringify] forKey: key];
		}
		[cfgInfo setObject: cfgEntries forKey: @"entries"];
		[ary addObject: cfgInfo];
	}
	[envelope setObject: ary forKey: @"configurationList"];
	[envelope setObject: [NSNumber numberWithInt: [configs indexOfObject: [self currentNeutralConfig] ] ] forKey: @"selectedIndex"];
	return envelope;
}
-(void) loadAllFrom: (NSDictionary*) envelope{
	if(envelope == NULL)
		return;
	NSArray* ary = [envelope objectForKey: @"configurationList"];
	
	NSMutableArray* newConfigs = [[NSMutableArray alloc] init];
	// have to do two passes in case config1 refers to config2 via a TargetConfig
	for(int i=0; i<[ary count]; i++) {
		Config* cfg = [[Config alloc] init];
		[cfg setName: [[ary objectAtIndex:i] objectForKey:@"name"]];		
		[newConfigs addObject: cfg];
	}
	[[configs objectAtIndex:0] setProtect: YES];
	for(int i=0; i<[ary count]; i++) {
		NSDictionary* dict = [[ary objectAtIndex:i] objectForKey:@"entries"];
		for(id key in dict) {
			[[[newConfigs objectAtIndex:i] entries] 
			 setObject: [Target unstringify: [dict objectForKey: key] withConfigList: newConfigs]
			 forKey: key];
		}
	}
	
	configs = newConfigs;
	[tableView reloadData];
	currentConfig = NULL;
	[[[NSApplication sharedApplication] delegate] configsChanged];
	
	int index = [[envelope objectForKey: @"selectedIndex"] intValue];
	[self activateConfig: [configs objectAtIndex:index] forApplication: NULL];
}

-(void) applicationSwitchedTo: (NSString*) name withPsn: (ProcessSerialNumber) psn {
	for(int i=0; i<[configs count]; i++) {
		Config* cfg = [configs objectAtIndex:i];
		if([[cfg name] isEqualToString: name]) {
			[self activateConfig: cfg forApplication: &psn];
			return;
		}
	}
	[self restoreNeutralConfig];
}

-(ProcessSerialNumber*) targetApplication {
	if(neutralConfig)
		return &attachedApplication;
	return NULL;
}

@end

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
        
        // Make (default) config
		currentConfig = [[Config alloc] init];
		[currentConfig setName: @"Default"];
		[configs addObject: currentConfig];		
	}
	return self;
}

-(void) restoreNeutralConfig {
	if(!neutralConfig) {
		return;
    }
	if([configs indexOfObject:neutralConfig] == NSNotFound) { // deleted, keep what we have
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
    //[removeButton setEnabled: YES];
    // TODO: quick hack
    [removeButton setEnabled:([configs count] > 0)];
	[targetController load];
	[appController configChanged];
	[tableView selectRow: [configs indexOfObject: config] byExtendingSelection: NO];
}

-(Config*) mappingWithName:(NSString *)name {
    NSUInteger ix = [configs indexOfObjectPassingTest:^BOOL(id element, NSUInteger idx, BOOL *stop) {
        if ([[(Config*)element name] isEqualToString:name]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if (ix != NSNotFound) {
        return [configs objectAtIndex:ix];
    }
    else {
        NSLog(@"Mapping with name not found: %@\n", name);
        return nil;
    }
}

-(IBAction) addPressed: (id)sender {
	Config* newConfig = [[Config alloc] init];
	[newConfig setName: @"untitled"];
	[configs addObject: newConfig];
	[appController configsListChanged];
	[tableView reloadData];
	[tableView selectRow: ([configs count]-1) byExtendingSelection: NO];
	[tableView editColumn: 0 row:([configs count]-1) withEvent:nil select:YES];
}
-(IBAction) removePressed: (id)sender {
	// save changes first
	[tableView reloadData];
	Config* current_config = [configs objectAtIndex: [tableView selectedRow]];
	[configs removeObjectAtIndex: [tableView selectedRow]];
    
    // TODO: remove config file from disk
	
	// remove all "switch to configuration" actions
	for(int i=0; i<[configs count]; i++) {
		NSMutableDictionary* entries = [(Config*)[configs objectAtIndex:i] entries];
		for(id key in entries) {
			Target* target = (Target*) [entries objectForKey: key];
			if([target isKindOfClass: [TargetConfig class]] && [(TargetConfig*)target config] == current_config)
				[entries removeObjectForKey: key];
		}
	}
	[appController configsListChanged];
	
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
	//NSString* newName = [(NSString*)obj stringByReplacingOccurrencesOfString: @"~" withString: @""];
    
    NSString *newName = (NSString*)obj;
    // Check if name conflicts
    BOOL conflicts = [self mappingWithName:newName] != nil;
    
    if (conflicts) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Please pick a unique name for this mapping"];
        [alert runModal];
        [tableView editColumn: 0 row:index withEvent:nil select:YES];
    }
    else {
        [(Config*)[configs objectAtIndex: index] setName: newName];
        [targetController refreshConfigsPreservingSelection:YES];
        [tableView reloadData];
        [appController configsListChanged];
    }
}

-(int)numberOfRowsInTableView: (NSTableView*)table {
	return [configs count];
}

-(BOOL)tableView: (NSTableView*)view shouldEditTableColumn: (NSTableColumn*) column row: (int) index {
	return YES;
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
    // Save mappings to JSON
    [self makeMappingsDirectory];
    for (Config *mapping in configs) {
        [mapping saveJSONTo:[self getMappingFilenameFor:mapping]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[[self currentNeutralConfig] name] forKey:@"selectedMapping"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    // TODO: synchronize to web
}
-(void) load {
    NSString *selected_mapping_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMapping"];
    if (selected_mapping_name == nil) {
        // Are there old-style configurations?
        id old_configs = [[NSUserDefaults standardUserDefaults] objectForKey:@"configurations"];
        if (old_configs == nil) {
            return;
        }
        
        // Load old configurations from NSUserDefaults
        NSLog(@"Loading configurations from NSUserDefaults (Enjoy2 1.1)\n");
        [self ver11LoadConfigsFrom: old_configs];
    }
    else {
        // Load JSON mappings
        [self loadAllFromDir:[self getMappingsDirectory]];
        
        // Selected mapping
        [appController configsListChanged];
        Config *mapping = [self mappingWithName:selected_mapping_name];
        if (mapping != nil) {
            [self activateConfig:mapping forApplication: NULL];
        }
        else {
            NSLog(@"Selected mapping not found: %@\n", selected_mapping_name);
        }
    }
    
	[tableView reloadData];
}

-(void) loadAllFromDir:(NSURL *)dir {
    NSError *error;
    NSArray *mapping_urls = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dir includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (mapping_urls == nil) {
        NSLog(@"Couldn't load mappings: %@\n", error);
        return;
    }
    
    NSMutableArray *new_mappings = [[NSMutableArray alloc] init];
    // Load in 2 passes, in case mapping1 refers to mapping2 via a TargetMapping (TargetConfig)
    for (NSURL *url in mapping_urls) {
        Config *mapping = [[Config alloc] init];
        
        NSData *json_data = [NSData dataWithContentsOfURL:url];
        // Just load the mapping name
        [mapping loadSkelFromJSON:json_data];
        [new_mappings addObject:mapping];
    }
    
    int ix = 0;
    for (NSURL *url in mapping_urls) {
        Config *mapping = [new_mappings objectAtIndex:ix];
        
        NSData *json_data = [NSData dataWithContentsOfURL:url];
        [mapping loadFromJSON:json_data withConfigList:configs];
        
        ix++;
    }
	
	configs = new_mappings;
	currentConfig = NULL;
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

-(NSURL*) getMappingsDirectory {
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    if ([urls count] == 0) {
        NSLog(@"No URLs returned for NSApplicationSupportDirectory!\n");
        return NULL;
    }
    NSURL *u = [urls objectAtIndex:0];
    
    //NSString *bundle_name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *bundle_name = @"Enjoy2";
    NSURL *as_dir = [u URLByAppendingPathComponent:bundle_name isDirectory:true];
    NSURL *mappings_dir = [as_dir URLByAppendingPathComponent:@"mappings"];
    
    return mappings_dir;
}

-(void) makeMappingsDirectory {
    NSString *path = [[self getMappingsDirectory] path];
    NSError *error;
    
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:&error];
    if (!result) {
        NSLog(@"Couldn't create mappings directory: %@\n", error);
    }
}

-(NSURL*) getMappingFilenameFor:(Config *)config {
    // Returns ".../Application Support/Enjoy2/mappings/[mapping].json"
    NSURL *mappings_dir = [self getMappingsDirectory];
    NSString *filename = [[config name] stringByAppendingString:@".json"];
    NSURL *full_filename = [mappings_dir URLByAppendingPathComponent:filename];
    
    return full_filename;
}

-(ProcessSerialNumber*) targetApplication {
	if(neutralConfig)
		return &attachedApplication;
	return NULL;
}


///////////////////////////////////////
// Legacy loading code from Enjoy2 v1.1

-(void) ver11LoadConfigsFrom: (NSDictionary*) envelope{
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
	for(int i=0; i<[ary count]; i++) {
		NSDictionary* dict = [[ary objectAtIndex:i] objectForKey:@"entries"];
		for(id key in dict) {
			[[[newConfigs objectAtIndex:i] entries]
			 setObject: [Target unstringify: [dict objectForKey: key] withConfigList: newConfigs]
			 forKey: key];
		}
	}
	
	configs = newConfigs;
	currentConfig = NULL;
    
	[tableView reloadData];
	[appController configsListChanged];
	
	int index = [[envelope objectForKey: @"selectedIndex"] intValue];
	[self activateConfig: [configs objectAtIndex:index] forApplication: NULL];
}

@end

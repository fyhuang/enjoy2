//
//  ApplicationController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//
#include <Carbon/Carbon.h>

@implementation ApplicationController

@synthesize jsController, targetController, configsController;

static BOOL active;

pascal OSStatus appSwitch(EventHandlerCallRef handlerChain, EventRef event, void* userData);

void onUncaughtException(NSException *exception) {
    NSLog(@"Uncaught exception: %@", exception.description);
}

-(void) applicationDidFinishLaunching: (NSNotification*) notification {
    // Debug: print exceptions
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
	[jsController setup];
	[drawer open];
	[targetController setEnabled: false];
	[self setActive: NO];
	[configsController load];
    
	EventTypeSpec et;
	et.eventClass = kEventClassApplication;
	et.eventKind = kEventAppFrontSwitched;
	EventHandlerUPP handler = NewEventHandlerUPP(appSwitch);
	InstallApplicationEventHandler(handler, 1, &et, self, NULL);
}

-(void) applicationWillTerminate: (NSNotification *)aNotification {
	[configsController save];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
					 hasVisibleWindows:(BOOL)flag
{	
	[mainWindow makeKeyAndOrderFront:self];
	return YES;
}

pascal OSStatus appSwitch(EventHandlerCallRef handlerChain, EventRef event, void* userData) {
	ApplicationController* self = (ApplicationController*)userData;
	NSDictionary* currentApp = [[NSWorkspace sharedWorkspace] activeApplication];
	ProcessSerialNumber psn;
	psn.lowLongOfPSN = [[currentApp objectForKey:@"NSApplicationProcessSerialNumberLow"] longValue];
	psn.highLongOfPSN = [[currentApp objectForKey:@"NSApplicationProcessSerialNumberHigh"] longValue];
	[self->configsController applicationSwitchedTo: [currentApp objectForKey:@"NSApplicationName"] withPsn: psn];
	return noErr;
}

-(BOOL) active {
	return active;
}

-(void) setActive: (BOOL) newActive {
	[activeButton setLabel: (newActive ? @"Stop" : @"Start")];
	[activeButton setImage: [NSImage imageNamed: (newActive ? @"NSStopProgressFreestandingTemplate" : @"NSGoRightTemplate" )]];
	[activeMenuItem setState: (newActive ? 1 : 0)];
	active = newActive;
}

-(IBAction) toggleActivity: (id)sender {
	[self setActive: ![self active]];
}

-(void) configsListChanged {
    // Update configs list in File menu
	while([dockMenuBase numberOfItems] > 2)
		[dockMenuBase removeItemAtIndex: ([dockMenuBase numberOfItems] - 1)];

	for(Config* config in [configsController configs]) {
		[dockMenuBase addItemWithTitle:[config name] action:@selector(chooseConfig:) keyEquivalent:@""];
	}
	[self configChanged];
}
-(void) configChanged {
	Config* current = [configsController currentConfig];
	NSArray* configs = [configsController configs];
    if ([dockMenuBase numberOfItems] - 2 != [configs count]) {
        NSLog(@"dockMenuBase has wrong number of items!");
    }
	for(int i=0; i<[configs count]; i++) {
		[[dockMenuBase itemAtIndex: (2+i)] setState: (([configs objectAtIndex:i] == current) ? YES : NO)];
    }
}

-(void) chooseConfig: (id) sender {
	[configsController activateConfig: [[configsController configs] objectAtIndex: ([dockMenuBase indexOfItem: sender]-2)] forApplication: NULL];
}
@end

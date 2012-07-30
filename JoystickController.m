//
//  JoystickController.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#import "CoreFoundation/CoreFoundation.h"

@implementation JoystickController

@synthesize joysticks, runningTargets, selectedAction, frontWindowOnly;

-(id) init {
	if(self=[super init]) {
		joysticks = [[NSMutableArray alloc]init];
        runningTargets = [[NSMutableArray alloc]init];
		programmaticallySelecting = NO;
        mouseLoc.x = mouseLoc.y = 0;
	}
	return self;
}

-(void) finalize {
	for(int i=0; i<[joysticks count]; i++) {
		[[joysticks objectAtIndex:i] invalidate];
	}
	IOHIDManagerClose(hidManager, kIOHIDOptionsTypeNone);
	CFRelease(hidManager);
	[super finalize];
}

static NSMutableDictionary* create_criterion( UInt32 inUsagePage, UInt32 inUsage )
{
	NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
	[dict setObject: [NSNumber numberWithInt: inUsagePage] forKey: (NSString*)CFSTR(kIOHIDDeviceUsagePageKey)];
	[dict setObject: [NSNumber numberWithInt: inUsage] forKey: (NSString*)CFSTR(kIOHIDDeviceUsageKey)];
	return dict;
} 

-(void) expandRecursive: (id) handler {
	if([handler base])
		[self expandRecursive: [handler base]];
	[outlineView expandItem: handler];
}

BOOL objInArray(NSMutableArray *array, id object) {
    for (id o in array) {
        if (o == object)
            return true;
    }
    return false;
}

void timer_callback(CFRunLoopTimerRef timer, void *ctx) {
    JoystickController *jc = (JoystickController *)ctx;
    jc->mouseLoc = [NSEvent mouseLocation];
    for (Target *target in [jc runningTargets]) {
        [target update: jc];
    }
}

void input_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDValueRef value) {
	JoystickController* self = (JoystickController*)inContext;
	IOHIDDeviceRef device = IOHIDQueueGetDevice((IOHIDQueueRef) inSender);
	
	Joystick* js = [self findJoystickByRef: device];
	if([[[NSApplication sharedApplication] delegate] active]) {
		// for reals
		JSAction* mainAction = [js actionForEvent: value];
		if(!mainAction)
			return;
		
		[mainAction notifyEvent: value];
		NSArray* subactions = [mainAction subActions];
		if(!subactions)
			subactions = [NSArray arrayWithObject:mainAction];
		for(id subaction in subactions) {
			Target* target = [[self->configsController currentConfig] getTargetForAction:subaction];
			if(!target)
				continue;
			/* target application? doesn't seem to be any need since we are only active when it's in front */
			/* might be required for some strange actions */
            if ([target running] != [subaction active]) {
                if ([subaction active]) {
                    [target trigger: self];
                }
                else {
                    [target untrigger: self];
                }
                [target setRunning: [subaction active]];
            }
            
            if ([mainAction isKindOfClass: [JSActionAnalog class]]) {
                double realValue = [(JSActionAnalog*)mainAction getRealValue: IOHIDValueGetIntegerValue(value)];
                [target setInputValue: realValue];
            
                // Add to list of running targets
                if ([target isContinuous] && [target running]) {
                    if (!objInArray([self runningTargets], target)) {
                        [[self runningTargets] addObject: target];
                    }
                }
            }
		}
	} else if([[NSApplication sharedApplication] isActive] && [[[NSApplication sharedApplication]mainWindow]isVisible]) {
		// joysticks not active, use it to select stuff
		id handler = [js handlerForEvent: value];
		if(!handler)
			return;
	
		[self expandRecursive: handler];
		self->programmaticallySelecting = YES;
		[self->outlineView selectRowIndexes: [NSIndexSet indexSetWithIndex: [self->outlineView rowForItem: handler]] byExtendingSelection: NO];
	}
}

int findAvailableIndex(id list, Joystick* js) {
	BOOL available;
	Joystick* js2;
	for(int index=0;;index++) {
		available = YES;
		for(int i=0; i<[list count]; i++) {
			js2 = [list objectAtIndex: i];
			if([js2 vendorId] == [js vendorId] && [js2 productId] == [js productId] && [js index] == index) {
				available = NO;
				break;
			}
		}
		if(available)
			return index;
	}
}

void add_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
	JoystickController* self = (JoystickController*)inContext;
	
	IOHIDDeviceOpen(device, kIOHIDOptionsTypeNone);
	IOHIDDeviceRegisterInputValueCallback(device, input_callback, (void*) self);
	
	Joystick *js = [[Joystick alloc] initWithDevice: device];
	[js setIndex: findAvailableIndex([self joysticks], js)];
	
	[js populateActions];

	[[self joysticks] addObject: js];
	[self->outlineView reloadData];
}
	
-(Joystick*) findJoystickByRef: (IOHIDDeviceRef) device {
	for(int i=0; i<[joysticks count]; i++)
		if([[joysticks objectAtIndex:i] device] == device)
			return [joysticks objectAtIndex:i];
	return NULL;
}	

void remove_callback(void* inContext, IOReturn inResult, void* inSender, IOHIDDeviceRef device) {
	JoystickController* self = (JoystickController*)inContext;
	
	Joystick* match = [self findJoystickByRef: device];
	if(!match)
		return;
				
	[[self joysticks] removeObject: match];

	[match invalidate];
	[self->outlineView reloadData];
}

-(void) setup {
    hidManager = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone);
	NSArray *criteria = [NSArray arrayWithObjects: 
		 create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_Joystick),
		 create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_GamePad),
         create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_MultiAxisController),
         //create_criterion(kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard),
	nil];
	
	IOHIDManagerSetDeviceMatchingMultiple(hidManager, (CFArrayRef)criteria);
    
	IOHIDManagerScheduleWithRunLoop( hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
	IOReturn tIOReturn = IOHIDManagerOpen( hidManager, kIOHIDOptionsTypeNone );
	(void)tIOReturn;
	
	IOHIDManagerRegisterDeviceMatchingCallback( hidManager, add_callback, (void*)self );
	IOHIDManagerRegisterDeviceRemovalCallback(hidManager, remove_callback, (void*) self);
//	IOHIDManagerRegisterInputValueCallback(hidManager, input_callback, (void*)self);
// register individually so we can find the device more easily
    
    
	
    // Setup timer for continuous targets
    CFRunLoopTimerContext ctx = {
        0, (void*)self, NULL, NULL, NULL
    };
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(kCFAllocatorDefault,
                                                   CFAbsoluteTimeGetCurrent(), 1.0/80.0,
                                                   0, 0, timer_callback, &ctx);
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopDefaultMode);
}

-(id) determineSelectedAction {
	id item = [outlineView itemAtRow: [outlineView selectedRow]];
	if(!item)
		return NULL;
	if([item isKindOfClass: [JSAction class]] && [item subActions] != NULL)
		return NULL;
	if([item isKindOfClass: [Joystick class]])
		return NULL;
	return item;
}

/* outline view */

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if(item == nil)
		return [joysticks count];
	if([item isKindOfClass: [Joystick class]])
		return [[item children] count];
	if([item isKindOfClass: [JSAction class]] && [item subActions] != NULL)
		return [[item subActions] count];
	return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if(item == nil)
		return YES;
	if([item isKindOfClass: [Joystick class]])
		return YES;
	if([item isKindOfClass: [JSAction class]]) 
		return [item subActions]==NULL ? NO : YES;
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	if(item == nil) 
		return [joysticks objectAtIndex: index];

	if([item isKindOfClass: [Joystick class]])
		return [[item children] objectAtIndex: index];
	
	if([item isKindOfClass: [JSAction class]]) 
		return [[item subActions] objectAtIndex:index];

	return NULL;
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item  {
	if(item == nil)
		return @"root";
	return [item name];
}

- (void)outlineViewSelectionDidChange: (NSNotification*) notification {
	[targetController reset];
	selectedAction = [self determineSelectedAction];
	[targetController load];
	if(programmaticallySelecting)
		[targetController focusKey];
	programmaticallySelecting = NO;
}
	
@end

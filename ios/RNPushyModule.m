
#import "RNPushyModule.h"
#import "RCTLog.h"

#import <Pushy/Pushy-Swift.h>

@implementation RNPushyModule

NSString *NOTIFICATION_EVENT = @"NotificationReceived";
NSString *USER_INTERACTION = @"userInteraction";
NSString *INITIAL_NOTIFICATION = @"initialNotification";

Pushy *pushy;
NSDictionary *initialNotification;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCTResponseSenderBlock messageEventHandler;

RCT_EXPORT_MODULE()

// listen()

RCT_EXPORT_METHOD(listen)
{
    RCTLogInfo(@"trying to listen pushy");
}

// register(), return promise with token

RCT_EXPORT_METHOD(register:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"trying to register pushy");
    //Configure: Listen and register device w/ Pushy
    @try {
        pushy = [[Pushy alloc]init:RCTSharedApplication()];
        __block BOOL hasResolved = NO;
        
        [pushy setNotificationHandler:^(NSDictionary *data, void (^completionHandler)(UIBackgroundFetchResult)) {
            NSMutableDictionary *notification = [[NSMutableDictionary alloc] initWithDictionary: data];
            
            // Print notification payload data
            NSLog(@"Received notification: %@", notification);
            
            if (RCTSharedApplication().applicationState == UIApplicationStateActive) {
                [notification setObject:@NO forKey:USER_INTERACTION];
            } else {
                [notification setObject:@YES forKey:USER_INTERACTION];
            }
            
            /* not working when alert is a string
            //Overwrite the title/message values with translations if applicable...
            if (data[@"aps"]) {
                NSDictionary *aps = [data objectForKey:@"aps"];
                if (aps[@"alert"]) {
                    NSDictionary *alert = [aps objectForKey:@"alert"];
                    if (alert[@"title-loc-key"]) {
                        NSString *titleLocKey = [alert valueForKey:@"title-loc-key"];
                        [notification setObject:NSLocalizedString(titleLocKey, @"") forKey:@"title"];
                    }
                    if (alert[@"loc-key"]) {
                        NSString *locKey = [alert valueForKey:@"loc-key"];
                        [notification setObject:NSLocalizedString(locKey, @"") forKey:@"message"];
                    }
                }
            }
             */
            
            [notification setObject:@NO forKey:INITIAL_NOTIFICATION];
            
            [self sendEvent:notification];
            
            // You must call this completion handler when you finish processing
            // the notification (after fetching background data, if applicable)
            completionHandler(UIBackgroundFetchResultNewData);
        }];
        
        [pushy register:^(NSError *error, NSString* deviceToken) {
            if (error != nil) { // Handle registration errors
                NSLog (@"Registration failed: %@", error);
                if (!hasResolved){
                    hasResolved = YES;
                    reject(@"registration_failed", @"Registration failed: ", error);
                }
                return ;
            }
            
            // Print device token to console
            NSLog(@"Pushy device token: %@", deviceToken);
            
            if (!hasResolved){
                hasResolved = YES;
                resolve(deviceToken);
            }
        }];
        
        //This may have been set by a call you put in AppDelegate...
        if (initialNotification) {
            NSLog(@"initialNotification: %@", initialNotification);
            NSMutableDictionary *notification = [initialNotification mutableCopy];
            [notification setObject:@YES forKey:USER_INTERACTION];
            [notification setObject:@YES forKey:INITIAL_NOTIFICATION];
            [self sendEvent:notification];
        }
    } @catch (NSException *exception) {
        reject(@"configure_failed", @"Configure failed: ", [NSError errorWithDomain:@"PUSHY.ME" code:100 userInfo:nil]);
    }
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"NotificationReceived"];
}

- (void) sendEvent:(NSDictionary *)params {
    [self sendEventWithName:NOTIFICATION_EVENT body:params];
}

@end
  

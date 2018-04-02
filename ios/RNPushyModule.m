
#import "RNPushyModule.h"
#import "RCTLog.h"

#import <Pushy/Pushy-Swift.h>

@implementation RNPushyModule

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
    resolve(@"CHACHACHA!!!!");
}

@end
  

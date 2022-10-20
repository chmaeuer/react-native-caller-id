
#import "RNCallerId.h"

#define DATA_KEY @"CALLER_LIST"
#define DATA_GROUP @"group.de.propstack.crm"
#define EXTENSION_ID @"de.propstack.crm.CallDirectoryExt"

@implementation RNCallerId
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup {
    return NO;
}

RCT_EXPORT_MODULE()

-(NSError*) buildErrorFromException: (NSException*) exception withErrorCode: (NSInteger)errorCode {
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setValue:exception.name forKey:@"Name"];
    [info setValue:exception.reason forKey:@"Reason"];
    [info setValue:exception.callStackReturnAddresses forKey:@"CallStack"];
    [info setValue:exception.callStackSymbols forKey:@"CallStackSymbols"];
    [info setValue:exception.userInfo forKey:@"UserInfo"];
    
    NSError *error = [[NSError alloc] initWithDomain:EXTENSION_ID code:errorCode userInfo:info];
    return error;
}

RCT_EXPORT_METHOD(setCallerList: (NSString*) callerList withResolver: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    @try {
        NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:DATA_GROUP];
        [userDefaults setObject:callerList forKey:DATA_KEY];
        [userDefaults synchronize];
        [CXCallDirectoryManager.sharedInstance reloadExtensionWithIdentifier:EXTENSION_ID completionHandler:^(NSError * _Nullable error) {
            if(error) {
                reject(@"setCallerList", @"CALLER_ID Failed to reload extension", error);
            } else {
                resolve(@true);
            }
        }];
    }
    @catch (NSException* e) {
        NSError* error = [self buildErrorFromException:e withErrorCode: 100];
        reject(@"setCallerList", @"CALLER_ID Failed to set caller list", error);
    }
}

RCT_EXPORT_METHOD(getExtensionEnabledStatus: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[CXCallDirectoryManager sharedInstance] getEnabledStatusForExtensionWithIdentifier:EXTENSION_ID completionHandler:^(CXCallDirectoryEnabledStatus enabledStatus, NSError * _Nullable error) {
            if (enabledStatus == 0) {
                reject(@"getExtensionEnabledStatus", @"CALLER_ID Failed to get extension status", error);
                // Code 0 tells you that there's an error. Common is that the identifierString is wrong.
            } else {
                resolve(enabledStatus);
                // Code 1 is deactivated extension
                // Code 2 is activated extension
            }
        }];
        
}

RCT_EXPORT_METHOD(openSettings: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {

    [CXCallDirectoryManager.sharedInstance openSettingsWithCompletionHandler:^(NSError * _Nullable error) {
            
        if(error != nil) {
            reject(@"openSettings", @"Opening settings failed", error);
        }
        else {
            resolve(@true);
        }

    }];

}

- (NSDictionary *)constantsToExport
{
    return @{ @"UNKNOWN": @0,  @"DISABLED": @1, @"ENABLED": @2};
}

@end
  

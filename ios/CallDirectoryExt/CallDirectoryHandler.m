//
//  CallDirectoryHandler.m
//  CallDirectoryExt
//
//  Created by Илья Коваценко on 08.12.2021.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "CallDirectoryHandler.h"

#define DATA_KEY @"CALLER_LIST"
#define APP_GROUP @"group.com.propstack.contact"

@interface Caller : NSObject
@property NSString* name;
@property NSArray<NSNumber*>* numbers;
-(instancetype) initWithDictionary: (NSDictionary*) dictionary;
@end

@implementation Caller
-(instancetype) initWithDictionary: (NSDictionary*) dictionary {
    if (self = [super init]) {
        self.name = dictionary[@"name"];
        self.numbers = dictionary[@"numbers"];
    }
    return self;
}
@end

@interface CallDirectoryHandler () <CXCallDirectoryExtensionContextDelegate>
@end

@implementation CallDirectoryHandler

- (void)beginRequestWithExtensionContext:(CXCallDirectoryExtensionContext *)context {
    context.delegate = self;

    if (context.isIncremental) {
        [context removeAllIdentificationEntries];
    }
    
    [self addAllIdentificationPhoneNumbersToContext:context];
    
    [context completeRequestWithCompletionHandler:nil];
}

- (NSArray*)getCallerList {
    @try {
        NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
        NSArray* callerList = [userDefaults arrayForKey:DATA_KEY];
        NSLog(@"CALLER_ID Get caller list");
        if (callerList) {
            return callerList;
        }
        return [[NSArray alloc] init];
    }
    @catch(NSException* e) {
        NSLog(@"CALLER_ID Failed to get caller list: %@", e.description);
    }
}


- (void)addAllIdentificationPhoneNumbersToContext:(CXCallDirectoryExtensionContext *)context {
    @try {
        NSLog(@"CALLER_ID init indif");
        NSArray* callerList = [self getCallerList];
        NSMutableDictionary<NSNumber*, NSString*>* labelsKeyedByPhoneNumber = [[NSMutableDictionary alloc] init];
        NSUInteger callersCount = [callerList count];
        NSLog(@"CALLER_ID check caller count");
        if(callersCount > 0) {
            for (NSUInteger i = 0; i < callersCount; i += 1) {
                NSLog(@"CALLER_ID into two");
                Caller* caller = [[Caller alloc] initWithDictionary:([callerList objectAtIndex:i])];
                for (NSUInteger j = 0; j < [caller.numbers count]; j++) {
                    NSLog(@"CALLER_ID into three");
                    NSNumber* number = caller.numbers[j];
                    [labelsKeyedByPhoneNumber setValue:caller.name forKey:number];
                }
            }
        }
        NSLog(@"CALLER_ID write start");
        for (NSNumber *phoneNumber in [labelsKeyedByPhoneNumber.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
            NSLog(@"CALLER_ID write one");
            NSString *label = labelsKeyedByPhoneNumber[phoneNumber];
            [context addIdentificationEntryWithNextSequentialPhoneNumber:(CXCallDirectoryPhoneNumber)[phoneNumber unsignedLongLongValue] label:label];
        }
    } @catch (NSException* e) {
        NSLog(@"CALLER_ID Failed to get caller list: %@", e.description);
    }
    
}

#pragma mark - CXCallDirectoryExtensionContextDelegate

- (void)requestFailedForExtensionContext:(nonnull CXCallDirectoryExtensionContext *)extensionContext withError:(nonnull NSError *)error {
    NSLog(@"CALLER_ID Request failed: %@", error.localizedDescription);
}

@end


//
//  UIView+JImageOperation.m
//  JImage
//
//  Created by jams on 2019/4/1.
//  Copyright © 2019 jams. All rights reserved.
//

#import "UIView+JImageOperation.h"
#import "objc/runtime.h"

static char kJImageOperation;
typedef NSMapTable<NSString *, id<JImageOperation>> JOperationDictionay;

@implementation UIView (JImageOperation)

- (JOperationDictionay *)operationDictionary {
    @synchronized (self) {
        JOperationDictionay *operationDict = objc_getAssociatedObject(self, &kJImageOperation);
        if (operationDict) {
            return operationDict;
        }
        operationDict = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
        objc_setAssociatedObject(self, &kJImageOperation, operationDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return operationDict;
    }
}

- (void)setOperation:(id<JImageOperation>)operation forKey:(NSString *)key {
    if (key) {
        [self cancelOperationForKey:key];
        if (operation) {
            JOperationDictionay *operationDict = [self operationDictionary];
            @synchronized (self) {
                [operationDict setObject:operation forKey:key];
            }
        }
    }
}

- (void)cancelOperationForKey:(NSString *)key {
    if (key) {
        JOperationDictionay *operationDict = [self operationDictionary];
        id<JImageOperation> operation;
        @synchronized (self) {
            operation = [operationDict objectForKey:key];
        }
        if (operation && [operation conformsToProtocol:@protocol(JImageOperation)]) {
            [operation cancelOperation];
        }
        @synchronized (self) {
            [operationDict removeObjectForKey:key];
        }
    }
}

- (void)removeOperationForKey:(NSString *)key {
    if (key) {
        JOperationDictionay *operationDict = [self operationDictionary];
        @synchronized (self) {
            [operationDict removeObjectForKey:key];
        }
    }
}


@end

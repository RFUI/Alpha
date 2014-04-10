
#import "RFNetworkActivityIndicatorManager.h"

@interface RFNetworkActivityIndicatorManager ()
@property (strong, nonatomic) NSMutableArray *messageQueue;
@end

@implementation RFNetworkActivityIndicatorManager
RFInitializingRootForNSObject

- (void)onInit {
    self.messageQueue = [NSMutableArray array];
}

- (void)afterInit {
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; displayingMessage = %@; messageQueue = %@>", self.class, self, self.displayingMessage, self.messageQueue];
}

- (void)hideWithGroupIdentifier:(NSString *)identifier {
    if (!identifier) {
        [self.messageQueue removeAllObjects];
        [self hideWithIdentifier:self.displayingMessage.identifier];
        return;
    }

    [self.messageQueue filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@", @keypathClassInstance(RFNetworkActivityIndicatorMessage, groupIdentifier), identifier]];

    if ([identifier isEqualToString:self.displayingMessage.groupIdentifier]) {
        [self hideWithIdentifier:self.displayingMessage.identifier];
    }
}

#pragma mark - Queue Manage
- (void)showMessage:(RFNetworkActivityIndicatorMessage *)message {
    NSParameterAssert(message.identifier);

    if (message.priority >= RFNetworkActivityIndicatorMessagePriorityReset) {
        [self.messageQueue removeAllObjects];
        // Continue
    }

    if (message.priority >= RFNetworkActivityIndicatorMessagePriorityHigh) {
        [self replaceMessage:self.displayingMessage withNewMessage:message];
        return;
    }

    // Needs update queue, just add or replace
    NSUInteger ix = [self.messageQueue indexOfObject:message];
    if (ix != NSNotFound) {
        RFNetworkActivityIndicatorMessage *messageInQueue = [self.messageQueue objectAtIndex:ix];
        if (message.priority >= messageInQueue.priority) {
            // Readd it
            [self.messageQueue removeObject:message];
            [self.messageQueue addObject:message];
        }
        // Else ignore new message.
    }
    else {
        [self.messageQueue addObject:message];
    }

    // If not displaying any, display it
    if (!self.displayingMessage) {
        [self replaceMessage:self.displayingMessage withNewMessage:message];
    }
    _douto(self)
}

- (void)hideWithIdentifier:(NSString *)identifier {
    _dout([NSString stringWithFormat:@"hide with identifier: %@", identifier])

    if (!identifier) {
        [self.messageQueue removeAllObjects];
        [self replaceMessage:self.displayingMessage withNewMessage:[self popNextMessageToDisplay]];
        return;
    }

    RFNetworkActivityIndicatorMessage *toRemove = [RFNetworkActivityIndicatorMessage new];
    toRemove.identifier = identifier;
    [self.messageQueue removeObject:toRemove];

    _douto(self.displayingMessage)
    if ([identifier isEqualToString:self.displayingMessage.identifier]) {
        [self replaceMessage:self.displayingMessage withNewMessage:[self popNextMessageToDisplay]];
    }
}

- (RFNetworkActivityIndicatorMessage *)popNextMessageToDisplay {
    RFNetworkActivityIndicatorMessagePriority ctPriority = NSIntegerMin;
    RFNetworkActivityIndicatorMessage *message;
    for (RFNetworkActivityIndicatorMessage *obj in self.messageQueue) {
        if (obj.priority > ctPriority) {
            ctPriority = obj.priority;
            message = obj;
        }
    }
    if (message) {
        [self.messageQueue removeObject:message];
    }
    return message;
}

#pragma mark - For overwrite
- (void)replaceMessage:(RFNetworkActivityIndicatorMessage *)displayingMessage withNewMessage:(RFNetworkActivityIndicatorMessage *)message {
    _douts(([NSString stringWithFormat:@"replaceMessage, ct = %@, new = %@",displayingMessage, message]))
    if (displayingMessage == message) return;
    _douts(([NSString stringWithFormat:@"set displaying with : %@", message]))
    self.displayingMessage = message;
}

@end

@implementation RFNetworkActivityIndicatorMessage

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; title = %@; message = %@; identifier = %@; priority = %d>", self.class, self, self.title, self.message, self.identifier, self.priority];
}

- (id)init {
    self = [super init];
    if (self) {
        _identifier = @"";
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title message:(NSString *)message status:(RFNetworkActivityIndicatorStatus)status {
    self = [self init];
    if (self) {
        _identifier = identifier;
        _title = title;
        _message = message;
        _status = status;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[RFNetworkActivityIndicatorMessage class]]) return NO;
    return self.hash == [object hash];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

@end
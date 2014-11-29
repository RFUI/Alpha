
#import "RFMessageManager.h"
#import "dout.h"

@interface RFMessageManager ()
@property (strong, nonatomic) NSMutableArray *messageQueue;
@end

@implementation RFMessageManager
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
    _dout_info(@"Hide message with group identifier: %@", identifier)

    if (!identifier) {
        [self.messageQueue removeAllObjects];
        [self hideWithIdentifier:self.displayingMessage.identifier];
        return;
    }

    [self.messageQueue filterUsingPredicate:[NSPredicate predicateWithFormat:@"%K != %@", @keypathClassInstance(RFNetworkActivityIndicatorMessage, groupIdentifier), identifier]];

    if ([identifier isEqualToString:self.displayingMessage.groupIdentifier]) {
        [self hideWithIdentifier:self.displayingMessage.identifier];
    }

    _dout_info(@"After hideWithGroupIdentifier self = %@", self)
}

#pragma mark - Queue Manage
- (void)showMessage:(RFNetworkActivityIndicatorMessage *)message {
    _dout_info(@"Show message: %@", message)
    NSParameterAssert(message.identifier);

    // If not displaying any, display it
    if (!self.displayingMessage) {
        [self replaceMessage:self.displayingMessage withNewMessage:message];
        return;
    }

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
        RFNetworkActivityIndicatorMessage *messageInQueue = (self.messageQueue)[ix];
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
    _dout_info(@"After showMessage, self = %@", self);
}

- (void)hideWithIdentifier:(NSString *)identifier {
    _dout_info(@"Hide message with identifier: %@", identifier)

    if (!identifier) {
        [self.messageQueue removeAllObjects];
        [self replaceMessage:self.displayingMessage withNewMessage:[self popNextMessageToDisplay]];
        return;
    }

    RFNetworkActivityIndicatorMessage *toRemove = [RFNetworkActivityIndicatorMessage new];
    toRemove.identifier = identifier;
    [self.messageQueue removeObject:toRemove];

    if ([identifier isEqualToString:self.displayingMessage.identifier]) {
        [self replaceMessage:self.displayingMessage withNewMessage:[self popNextMessageToDisplay]];
    }
    _dout_info(@"After hideWithIdentifier, self = %@", self);
}

- (RFNetworkActivityIndicatorMessage *)popNextMessageToDisplay {
    RFNetworkActivityIndicatorMessagePriority ctPriority = (RFNetworkActivityIndicatorMessagePriority)NSIntegerMin;
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
    if (displayingMessage == message) return;
    self.displayingMessage = message;
}

@end

@implementation RFNetworkActivityIndicatorMessage

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; title = %@; message = %@; identifier = %@; priority = %d>", self.class, self, self.title, self.message, self.identifier, (int)self.priority];
}

- (instancetype)init {
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
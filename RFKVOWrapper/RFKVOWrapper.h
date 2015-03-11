/*!
    RFKVOWrapper

    Copyright (c) 2015 BB9z
    https://github.com/RFUI/Alpha

    The MIT License (MIT)
    http://www.opensource.org/licenses/mit-license.php

    TEST
 */

/*!
 RFKVOWrapper contains code from HTBKVObservation, the use of which is hereby acknowledged.

 HTBKVObservation https://github.com/thehtb/HTBKVObservation

 Copyright (c) 2012 The High Technology Bureau, Mark Aufflick

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

@interface NSObject (RFKVOWrapper)

/**
 Adds the given block as the callback for when the keyPath changes. 
 
 The observer does not need to be explicitly removed. It will be removed when the observer or observed object is dealloc'd.
 
 @param observer    The object to which callbacks will be delivered. This is passed back into the given block.
 @param keyPath     The key path to observe.
 @param options     The key-value observing options.
 @param queue       The queue in which the callback block should be performed. Passing nil means the block will be performed in whatever queue the observer callback came in on.
 @param block       The block called when the value at the key path changes.

 @return Returns an identifier that can be used to remove the observer.
 */
- (id)RFAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options queue:(NSOperationQueue *)queue block:(void (^)(id observer, NSDictionary *change))block;

/**
 Remove the observer represented by the identifier.
 
 @param identifier  The identifier to removed. This should be an object previously returned by a called to -RFAddObserverForKeyPath:options:queue:block:.
 
 @return Whether the removal was successful. The only reason for failure would be if the identifier doesn't represent anything currently being observed by the object, or if the identifier is nil.
 */
- (BOOL)RFRemoveObserverWithIdentifier:(id)identifier;
@end

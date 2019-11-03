//
//  GCDConcurrency.m
//  SocketMessageServer
//
//  Created by Victor on 02.11.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDConcurrency.h"

@implementation GCDConcurrency
//MARK: SerialQueue
+ (dispatch_queue_t)createSerialQueueWithLabel:(const char *)label {
    dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
    return queue;
}

//MARK: ConcurrentQueue
+ (dispatch_queue_t)createConcurrentQueueWithLabel:(const char *)label {
    dispatch_queue_t queue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
    return queue;
}

//MARK: QoS queues
+ (dispatch_queue_t)createQoSQueueWithQoS:(qos_class_t)qos {
    dispatch_queue_t queue = dispatch_get_global_queue(qos, 0);
    return queue;
}

+ (dispatch_queue_t)createQosQueueWithLabel:(const char *)label qos:(qos_class_t)qos attributes:(dispatch_queue_attr_t)attr {
    dispatch_queue_attr_t createdAttr = dispatch_queue_attr_make_with_qos_class(attr, qos, 0);
    dispatch_queue_t myQueue = dispatch_queue_create(label, createdAttr);
    return myQueue;
}

//MARK: Tasks
+ (void)asyncTaskWithQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    dispatch_async(queue, block);
}

+ (void)syncTaskWithQueue:(dispatch_queue_t)queue block:(dispatch_block_t)block {
    dispatch_sync(queue, block);
}

@end

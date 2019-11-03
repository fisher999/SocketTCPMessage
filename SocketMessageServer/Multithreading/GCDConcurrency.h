//
//  GCDConcurrency.h
//  SocketMessageClient
//
//  Created by Victor on 02.11.2019.
//  Copyright © 2019 Victor. All rights reserved.
//

#import <Foundation/Foundation.h>;

@interface GCDConcurrency : NSObject
//MARK: SerialQueue
+ (dispatch_queue_t)createSerialQueueWithLabel: (const char *) label;
//MARK: Concurrent queue
+ (dispatch_queue_t)createConcurrentQueueWithLabel:(const char *) label;
//MARK: QoS queues
+ (dispatch_queue_t) createQoSQueueWithQoS: (qos_class_t) qos;
+ (dispatch_queue_t) createQosQueueWithLabel: (const char *) label qos: (qos_class_t) qos attributes: (dispatch_queue_attr_t) attr;
//MARK: Tasks
+ (void) asyncTaskWithQueue: (dispatch_queue_t) queue block: (dispatch_block_t) block;
+ (void) syncTaskWithQueue: (dispatch_queue_t) queue block: (dispatch_block_t) block;
@end

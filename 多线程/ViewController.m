//
//  ViewController.m
//  多线程
//
//  Created by 顿顿 on 16/8/16.
//  Copyright © 2016年 顿顿. All rights reserved.
//  xuexi

#import "ViewController.h"
#import "DZROperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"主线程：%@",[NSThread mainThread]);
    // 主线程：<NSThread: 0x60000007ba40>{number = 1, name = main}
    
    // NSThread
//    [self thread];
    
    // GCD
//    [self gcd];
    
    // NSOperation
    [self operation];
}

# pragma mark - NSThread

- (void)thread
{
    /*
     NSThread创建：
     1、init方法，需要 start 开启
     2、detachNewThreadSelector方法，自动启动
     3、performSelectorInBackground方法，自动启动
     */
    NSThread *threadInit = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(thread_initMethod:)
                                                     object:@"initMethod"];
    [threadInit start];
    
    [NSThread detachNewThreadSelector:@selector(thread_detch:) toTarget:self withObject:@"detachNewThread"];
    
    [self performSelectorInBackground:@selector(thread_perform:) withObject:@"performSelectorInBackground"];
    
    [NSThread exit];
}

- (void)thread_initMethod:(NSObject *)object
{
    NSLog(@"init方法--> object:%@, %@",object, [NSThread currentThread]);
    // init方法--> object:initMethod, <NSThread: 0x60000027b180>{number = 3, name = (null)}
}

- (void)thread_detch:(NSObject *)object
{
    NSLog(@"detach方法--> object:%@, %@",object, [NSThread currentThread]);
    // detach方法--> object:detachNewThread, <NSThread: 0x60000027b0c0>{number = 4, name = (null)}
}

- (void)thread_perform:(NSObject *)object
{
    NSLog(@"perform方法--> object:%@, %@",object, [NSThread currentThread]);
    // perform方法--> object:performSelectorInBackground, <NSThread: 0x60000007a2c0>{number = 5, name = (null)}
}

# pragma mark - GCD

- (void)gcd
{
    /*
     任务: 执行代码块
     队列: 存放任务的地方
     同步/异步: 执行方式
     
     GCD中有三种队列类型：
     1.The main queue: 与主线程功能相同。实际上，提交至main queue(主队列)的任务会在主线程中执行。main queue可以调用dispatch_get_main_queue()来获得。因为main queue是与主线程相关的，所以这是一个串行队列。
     2.Global queues: 全局队列是并发队列，并由整个进程共享。进程中存在四个全局队列：高、中（默认）、低、后台四个优先级队列。可以调用dispatch_get_global_queue函数传入优先级来访问队列。
     3.用户队列: 用户队列 (GCD并不这样称呼这种队列, 但是没有一个特定的名字来形容这种队列，所以我们称其为用户队列) 是用函数 dispatch_queue_create 创建的队列。创建用户队列,第一个参数是表示debug的,Apple建议我们使用倒置域名来命名队列，比如“com.dreamingwish.subsystem.task”。这些名字会在崩溃日志中被显示出来，也可以被调试器调用，这在调试中会很有用。第二个参数表示队列类型：串行（DISPATCH_QUEUE_SERIAL）或者并发（DISPATCH_QUEUE_CONCURRENT）。
     */
    
    // 串行同步
    [self serialSync];
    
    // 串行异步
    [self serialAsync];

    // 并发同步
    [self concurrentSync];

    // 并发异步
    [self concurrentAsync];
    
    // 主队列同步
    [self mainQueueSync];
    
    // 线程通讯
    [self threadCommunication];
    
    // 栅栏
    [self fence];
    
    // 队列组
    [self queueGroup];
}

// 串行同步
- (void)serialSync
{
    /*
     串行同步，输出：
     串行同步：0 --> <NSThread: 0x600000072d40>{number = 1, name = main}
     串行同步：1 --> <NSThread: 0x600000072d40>{number = 1, name = main}
     串行同步：2 --> <NSThread: 0x600000072d40>{number = 1, name = main}
     串行同步：0 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     串行同步：1 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     串行同步：2 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     串行同步：0 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     串行同步：1 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     串行同步：2 --> <NSThread: 0x60400007ee80>{number = 1, name = main}
     
     没有开新线程
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("com.dzr.multithreading.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_sync(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_sync(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
}

// 串行异步
- (void)serialAsync
{
    /*
     串行异步，输出：
     串行异步：0 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：1 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：2 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：0 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：1 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：2 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：0 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：1 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     串行异步：2 --> <NSThread: 0x604000467900>{number = 3, name = (null)}
     
     开了一条新线程
     */
    dispatch_queue_t serialQueue = dispatch_queue_create("com.dzr.multithreading.serialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(serialQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"串行异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
}

// 并发同步
- (void)concurrentSync
{
    /*
     并发同步，输出：
     并发同步：0 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：1 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：2 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：0 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：1 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：2 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：0 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：1 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     并发同步：2 --> <NSThread: 0x60000007c980>{number = 1, name = main}
     
     没有开新线程
     */
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.dzr.multithreading.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_sync(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_sync(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发同步：%i --> %@",i, [NSThread currentThread]);
        }
    });
}

// 并发异步
- (void)concurrentAsync
{
    /*
     并发异步，输出：
     并发异步：0 --> <NSThread: 0x600000277480>{number = 4, name = (null)}
     并发异步：0 --> <NSThread: 0x604000465f80>{number = 3, name = (null)}
     并发异步：0 --> <NSThread: 0x604000466140>{number = 5, name = (null)}
     并发异步：1 --> <NSThread: 0x600000277480>{number = 4, name = (null)}
     并发异步：1 --> <NSThread: 0x604000465f80>{number = 3, name = (null)}
     并发异步：1 --> <NSThread: 0x604000466140>{number = 5, name = (null)}
     并发异步：2 --> <NSThread: 0x600000277480>{number = 4, name = (null)}
     并发异步：2 --> <NSThread: 0x604000465f80>{number = 3, name = (null)}
     并发异步：2 --> <NSThread: 0x604000466140>{number = 5, name = (null)}
     
     开了三条新线程
     */
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.dzr.multithreading.concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"并发异步：%i --> %@",i, [NSThread currentThread]);
        }
    });
}

// 主队列同步
- (void)mainQueueSync
{
    /*
     会造成锁死，崩溃
     主队列同步会先执行任务1
     当前主线程正在执行 mainQueueSync 方法
     造成执行任务1等待mainQueueSync方法结束，mainQueueSync方法等待任务1-3任务结束
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"任务1：%@",[NSThread currentThread]);
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"任务2：%@",[NSThread currentThread]);
    });
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"任务3：%@",[NSThread currentThread]);
    });
}

// 线程通讯
- (void)threadCommunication
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"做一些费时的东西");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"主线程刷新UI");
        });
    });
}

// 栅栏
- (void)fence
{
    /*
     异步是没有顺序的，但是添加了栅栏，就可以将任务分为两部分，先做第一部分完毕后，才会做第二部分
     输出：
     任务2：0 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务1：0 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     任务2：1 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务1：1 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     任务2：2 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务1：2 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     并发异步执行
     任务4：0 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务3：0 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     任务4：1 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务3：1 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     任务4：2 --> <NSThread: 0x604000069940>{number = 4, name = (null)}
     任务3：2 --> <NSThread: 0x60000026b780>{number = 3, name = (null)}
     */
    dispatch_queue_t queue = dispatch_queue_create("com.dzr.multithreading.fence", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务1：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务2：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"并发异步执行");
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务3：%i --> %@",i, [NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务4：%i --> %@",i, [NSThread currentThread]);
        }
    });
}

// 队列组
- (void)queueGroup
{
    /*
     队列组，输出：
     任务1：0 --> <NSThread: 0x60400027a080>{number = 3, name = (null)}
     任务3：0 --> <NSThread: 0x604000279fc0>{number = 5, name = (null)}
     任务2：0 --> <NSThread: 0x60400027a0c0>{number = 4, name = (null)}
     任务1：1 --> <NSThread: 0x60400027a080>{number = 3, name = (null)}
     任务2：1 --> <NSThread: 0x60400027a0c0>{number = 4, name = (null)}
     任务3：1 --> <NSThread: 0x604000279fc0>{number = 5, name = (null)}
     任务1：2 --> <NSThread: 0x60400027a080>{number = 3, name = (null)}
     任务2：2 --> <NSThread: 0x60400027a0c0>{number = 4, name = (null)}
     任务3：2 --> <NSThread: 0x604000279fc0>{number = 5, name = (null)}
     任务完了，回到主线程刷新UI
     */
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.dzr.multithreading.group", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务1：%i --> %@",i,[NSThread currentThread]);
        }
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务2：%i --> %@",i,[NSThread currentThread]);
        }
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务3：%i --> %@",i,[NSThread currentThread]);
        }
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"任务完了，回到主线程刷新UI");
    });
}

# pragma mark - NSOperation

- (void)operation
{
    /*
     NSOperation创建：
     1、使用NSInvocationOperation子类，需要start开启
     2、使用NSBlockOperation子类，需要start开启
     3、使用继承NSOperation的子类，需要start开启
     */
    
    // 创建NSInvocationOperation对象
//    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationOperation:) object:@"invocation"];
//    [invocationOperation start];
    
    /*
     创建NSBlockOperation对象
     输出：
     block方法：<NSThread: 0x7feaf1701590>{number = 1, name = main}
     任务1：<NSThread: 0x7f839bc21280>{number = 2, name = (null)}
     任务2：<NSThread: 0x7f839be44180>{number = 3, name = (null)}
     任务3：<NSThread: 0x7f839be1f470>{number = 4, name = (null)}
     
     blockOperationWithBlock方法：主线程实现
     addExecutionBlock：开新线程
     */
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"block方法：%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务1：%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务2：%@",[NSThread currentThread]);
    }];
    [blockOperation addExecutionBlock:^{
        NSLog(@"任务3：%@",[NSThread currentThread]);
    }];
    [blockOperation start];
    
    /*
     创建继承 NSOperation 的子类DZROperation
     输出：
     DZROperation --> 0, <NSThread: 0x7fd22ee01ae0>{number = 1, name = main}
     DZROperation --> 1, <NSThread: 0x7fd22ee01ae0>{number = 1, name = main}
     DZROperation --> 2, <NSThread: 0x7fd22ee01ae0>{number = 1, name = main}
     
     未开新线程
     */
//    DZROperation *operation = [[DZROperation alloc] init];
//    [operation start];
    
    
    // 队列
//    [self operationQueue];
}

- (void)invocationOperation:(NSObject *)object
{
    // invocation方法：<NSThread: 0x600000071ec0>{number = 1, name = main}
    // 没有开新线程
    NSLog(@"invocation方法：%@",[NSThread currentThread]);
}

// operation队列
- (void)operationQueue
{
    /*
     队列NSOperationQueue
     队列类型：主队列，非主队列（串行，并发）
     
     队列NSOperationQueue有个参数最大并发数：maxConcurrentOperationCount
     maxConcurrentOperationCount默认-1，直接开启并发，所以非主队列默认是开启并发
     maxConcurrentOperationCount > 1，进行并发
     maxConcurrentOperationCount = 1，表示不开线程，是串行
     maxConcurrentOperationCount系统会限制一个最大值，所以设置maxConcurrentOperationCount很大也是无意义的
     */
    
    // 使用DZROperation方法
//    [self useDZROperation];
//
//    // 添加方式
//    [self useAddOperation];
//
//    // 常用方法
//    [self operationNotifacation];
    
    // 依赖关系
    [self useAddDependency];
}

- (void)useDZROperation
{
    /*
     非主队列（并发）
     输出：
     DZROperation --> 0, <NSThread: 0x7fc46660c030>{number = 2, name = (null)}
     DZROperation --> 0, <NSThread: 0x7fc466605c70>{number = 3, name = (null)}
     DZROperation --> 1, <NSThread: 0x7fc46660c030>{number = 2, name = (null)}
     DZROperation --> 1, <NSThread: 0x7fc466605c70>{number = 3, name = (null)}
     DZROperation --> 2, <NSThread: 0x7fc46660c030>{number = 2, name = (null)}
     DZROperation --> 2, <NSThread: 0x7fc466605c70>{number = 3, name = (null)}
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    DZROperation *operation1 = [[DZROperation alloc] init];
    DZROperation *operation2 = [[DZROperation alloc] init];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
}

- (void)useAddOperation
{
    /*
     添加任务
     maxConcurrentOperationCount = -1输出：
     添加任务2：<NSThread: 0x7fa3a2f169f0>{number = 3, name = (null)}
     添加任务1：<NSThread: 0x7fa3a2d09240>{number = 2, name = (null)}
     添加任务3：<NSThread: 0x7fa3a2d0a3d0>{number = 4, name = (null)}
     
     maxConcurrentOperationCount = 1输出：
     添加任务1：<NSThread: 0x7fe65270b6a0>{number = 2, name = (null)}
     添加任务2：<NSThread: 0x7fe65270b6a0>{number = 2, name = (null)}
     添加任务3：<NSThread: 0x7fe65270b6a0>{number = 2, name = (null)}
     
     开新线程
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperationWithBlock:^{
        NSLog(@"添加任务1：%@",[NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"添加任务2：%@",[NSThread currentThread]);
    }];
    [queue addOperationWithBlock:^{
        NSLog(@"添加任务3：%@",[NSThread currentThread]);
    }];
}

// 常用方式
- (void)operationNotifacation
{
    // 主队列
    NSOperationQueue *mainOperation = [NSOperationQueue mainQueue];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        // 做复杂操作
        NSLog(@"做复杂操作");
        
        [mainOperation addOperationWithBlock:^{
            // 刷新UI
            NSLog(@"刷新UI");
        }];
    }];
}

// 依赖关系
- (void)useAddDependency
{
    /*
     依赖关系，任务1依赖任务2，任务2完成后才能完成任务1
     不能相互依赖
     输出：
     任务2：0, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     任务2：1, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     任务2：2, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     任务1：0, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     任务1：1, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     任务1：2, <NSThread: 0x7fc82160c390>{number = 2, name = (null)}
     */
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务1：%d, %@",i, [NSThread currentThread]);
        }
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务2：%d, %@",i, [NSThread currentThread]);
        }
    }];
    
    // 任务1依赖任务2
    [operation1 addDependency:operation2];
    [queue addOperation:operation1];
    [queue addOperation:operation2];
}

@end

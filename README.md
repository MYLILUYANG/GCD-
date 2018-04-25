iOS GCD 常用基本方法
1 两种队列 
  |--> 串行队列 
     |--> dispatch_queue_t queue = dispatch_get_main_queue(); 系统主队列
     |--> dispatch_queue_t queue = dispatch_queue_create("queueName", DISPATCH_QUEUE_SERIAL);     "queueName"是队列标识符，DISPATCH_QUEUE_SERIAL创建的是串行队列  |--> 并行队列
     |-->dispatch_queue_t queue = dispatch_get_global_queue(0, 0) 第一个参数代表优先级 系统全局并发队列。
     |--> dispatch_queue_t queue = dispatch_queue_create("queueName", DISPATCH_QUEUE_CONCURRENT)  新创建并行队列
2 两种执行方法
  |--> 同步执行
     |--> dispatch_sync(queue, ^{ });  同步执行 ，执行的任务
  |--> 异步执行
     |--> dispatch_async(queue, ^{ }); 异步执行 ，执行的任务


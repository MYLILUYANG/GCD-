//
//  ViewController.m
//  GCD
//
//  Created by liluyang on 2018/4/25.
//  Copyright © 2018年 lly. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    对于系统版本6.0 以上的版本，GCD 已经 加入ARC管理。因此不需要dispatch_release()主动释放。
    //    dispatch_release(queue);
    
    // 1并行队列
    [self asyncConCurrent];
    
    // 2   串行队列
    //    [self asyncSerial];
    
    
    // 3   栅栏  控制并发队列的执行顺序
    //    [self barrier];
    
    // 4   延迟执行
    //    [self delay];
    
    
    // 5   apply 快速迭代
    //    [self apply];
    
    // 6  apply 快速迭代  应用
    //    [self moveFile];
    
    
    // 7  group 队列组 操作
    //    [self group];
    
    // 8  主队列 async 串行
    //    [self asyncMain];
    
    // 9  主队列同步  死锁
    //    [self syncMain];
    
    // 10 单例
    //    [self singleton];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //  10  单例
//    [self singleton];
}

-(void)singleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"只会执行一次  适合全局单例对象使用");
    });
    NSLog(@"别点了，就会执行一次");
}

-(void)asyncMain{
    dispatch_queue_t  queue = dispatch_get_main_queue();
//    主队列异步函数

    dispatch_async(queue, ^{

        for (int i = 0; i < 3; i++) {
            NSLog(@"11111%d-----%@", i,[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{

        for (int i = 0; i < 3; i++) {
            NSLog(@"22222%d-----%@", i,[NSThread currentThread]);
        }
    });

    dispatch_async(queue, ^{

        for (int i = 0; i < 3; i++) {
            NSLog(@"33333%d-----%@", i,[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{

        for (int i = 0; i < 3; i++) {
            NSLog(@"44444%d-----%@", i,[NSThread currentThread]);
        }
    });
//    主队列 同步函数    --->   同步函数会等 asyncMain方法调用完成后才会执行 后边的任务。
//    同步函数会立刻马上执行。  死锁
//    dispatch_sync(queue, ^{
//        for (int i = 0; i < 3; i++) {
//            NSLog(@"11111%d-----%@", i,[NSThread currentThread]);
//        }
//    });
    NSLog(@"end");
}

/**
 死锁原因： 1 主队列中会添加 syncMain 和 dispatch_sync 两个任务。 dispatch_sync 任务需要等待  syncMain执行完毕才会执行。
          2 syncMain 执行完毕需要 dispatch_sync执行完毕。
          3 所以造成 dispatch_sync 和 syncMain 互相等待的过程造成死锁。
          4 处理方法： 开子线程或者将dispatch_sync任务不要放在 syncMain函数中。
 */
-(void)syncMain{
//    死锁
    //    主队列 同步函数    --->   同步函数会等 asyncMain方法调用完成后才会执行 后边的任务。
    //    同步函数会立刻马上执行。  死锁
    dispatch_queue_t  queue = dispatch_get_main_queue();
        dispatch_sync(queue, ^{
            for (int i = 0; i < 3; i++) {
                NSLog(@"11111%d-----%@", i,[NSThread currentThread]);
            }
        });
    NSLog(@"end");
}

-(void)group{
//
//    队列组  是保证任务都已经完成。
    dispatch_group_t group = dispatch_group_create();
    __block UIImage *image1 = [[UIImage alloc] init];
    __block  UIImage *image2 = [[UIImage alloc] init];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        NSString *imagePath =@"http://h.hiphotos.baidu.com/image/pic/item/63d0f703918fa0ecf70575602a9759ee3c6ddb99.jpg";
        
        image1 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
        
    });
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        NSString *imagePath =@"http://d.hiphotos.baidu.com/image/pic/item/8435e5dde71190ef3ddc94b7c21b9d16fdfa60b6.jpg";
        
        image2 = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
//        拼接两张图片
//        开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height));
//        画1
        [image1 drawInRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * 0.4)];
//        画2
        [image2 drawInRect:CGRectMake(0, [UIScreen mainScreen].bounds.size.height *0.3, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.7)];
//        得到绘制好的图片
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//        关闭图形上下文
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           imageView.image = image;
        });
        
    });
    
}

-(void)apply{
//    会阻塞主线程进行
    NSLog(@"begin");
    
        
        NSString *from = @"/Users/liluyang/Desktop/from";
        NSString *to = @"/Users/liluyang/Desktop/to";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSArray *fileArray = [fileManager subpathsAtPath:from];
        
        dispatch_apply([fileArray count], dispatch_queue_create("apply", DISPATCH_QUEUE_CONCURRENT), ^(size_t index) {
            NSLog(@"%zd ----%@",index, [NSThread currentThread]);
            NSString *fromPath = [from stringByAppendingPathComponent:fileArray[index]];
            NSString *toPath = [to stringByAppendingPathComponent:fileArray[index]];
            [fileManager moveItemAtPath:fromPath toPath:toPath error:nil];
        });
    
    NSLog(@"end");
}

-(void)moveFile{
    NSString *from = @"/Users/liluyang/Desktop/from";
    NSString *to = @"/Users/liluyang/Desktop/to";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
   NSArray *fileArray = [fileManager subpathsAtPath:from];
    
    NSLog(@"任务开始");
    
    dispatch_async(dispatch_queue_create("fileManager", DISPATCH_QUEUE_CONCURRENT), ^{
        
        [fileArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

            NSString *fromPath = [from stringByAppendingPathComponent:obj];
            NSString *toPath = [to stringByAppendingPathComponent:obj];
//            NSError *erro = [NSError ];
            
            [fileManager moveItemAtPath:fromPath toPath:toPath error:nil];
            
            //        NSLog(@"%@",erro);
            NSLog(@"%ld",idx);

        }];
        dispatch_async(dispatch_queue_create("fileManager", DISPATCH_QUEUE_CONCURRENT), ^{
            NSLog(@"我什么时候执行");
        });
        NSLog(@"串行队列执行完毕");
    });
    NSLog(@"任务完成");
}

-(void)delay{
    NSLog(@"开始");
    
//    dispatch_get_main_queue() 主线程         系统自动创建的串行队列   主线程中执行
//    dispatch_get_global_queue(0, 0)全局线程  系统自动创建的并发队列
//
//    dispatch_queue_create("test", DISPATCH_QUEUE_SERIAL)   自定义串行队列
//    dispatch_queue_create("test1", DISPATCH_QUEUE_CONCURRENT) 自定义并发队列

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"执行");
    });
    NSLog(@"end");
}

-(void)barrier
{
//    栅栏函数不能在 全局主线程中执行
    dispatch_queue_t queue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    
    
    dispatch_async(queue, ^{
       
        for (int i = 0; i < 10; i++) {
            NSLog(@"11111%d-----%@", i,[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 10; i++) {
            NSLog(@"22222%d-----%@", i,[NSThread currentThread]);
        }
    });
        dispatch_barrier_async(queue, ^{
    
            NSLog(@"栅栏");
    
        });
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 10; i++) {
            NSLog(@"33333%d-----%@", i,[NSThread currentThread]);
        }
    });
    dispatch_async(queue, ^{
        
        for (int i = 0; i < 10; i++) {
            NSLog(@"44444%d-----%@", i,[NSThread currentThread]);
        }
    });
    

    
}

-(void)asyncSerial
{
    NSLog(@"begin");
    //    Serila Disapatch Queue 串行队列主要用在多个线程同事更新相同资源导致数据竞争时。
    //    第一个参数是进程的标识符 Apple 推荐写法为 使用应用程序ID这种逆序全程域名
    //    DISPATCH_QUEUE_SERIAL 表示队列类型为 串行队列  等待上个任务执行完成 再往下执行。
    dispatch_queue_t queue = dispatch_queue_create("queueSerial", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{
        NSLog(@"1");
    });
    dispatch_async(queue, ^{
        NSLog(@"2");
    });
    dispatch_async(queue, ^{
        NSLog(@"3");
    });
    dispatch_async(queue, ^{
        NSLog(@"4");
    });
    NSLog(@"end");
    
}

-(void)asyncConCurrent
{
    NSLog(@"begin");
    //    并行  第一个参数 是线程标识符    第二个参数表示创建的是并行队列 立即执行
    dispatch_queue_t queue =dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"111111--- %d----%@", i, [NSThread currentThread]);
        };
    
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"222222--- %d----%@", i, [NSThread currentThread]);
        };
    });
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"333333--- %d----%@", i, [NSThread currentThread]);
        };
    });
    NSLog(@"end");
}

@end
                   

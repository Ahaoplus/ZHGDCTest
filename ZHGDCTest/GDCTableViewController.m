//
//  GDCTableViewController.m
//  ZHGDCTest
//
//  Created by 张浩 on 2017/6/30.
//  Copyright © 2017年 hzbt. All rights reserved.
//

#import "GDCTableViewController.h"

@interface GDCTableViewController ()
{
    NSArray* titleArray;
}
@end

@implementation GDCTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    titleArray = @[@"1、不使用队列",@"2、异步方法---并行队列",@"3、同步方法---并行队列",@"4、GCDAsyncGroup",@"5、GCDAsynGroupBackgroupDoEnd",@"6、同步方法---串行队列",@"7、syncDispatchApply",@"8、syncDispatchApply",@"9、",@"10、"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return titleArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:{
            [self SingleThreadMethod];
        }
            break;
        case 1:{
            [self GCDAsyncMethod];
        }
            break;
        case 2:{
            [self GCDSyncMethod];
        }
            break;
        case 3:{
            [self GCDAsyncGroup];
        }
            break;
        case 4:{
            [self GCDAsynGroupBackgroupDoEnd];
        }
            break;
        case 5:{
            [self syncDispatchApply];
        }
            break;
        case 6:{
            [self asyncDispathApply];
        }
            break;

        default:
            break;
    }
}

/**
 单线程运行
 */
-(void)SingleThreadMethod{
    
    for (int i=0; i<10; i++) {
        
        for (int j = 0; j<30; j++) {
            NSLog(@"\n %s i=%d and j=%d",__func__,i,j);
        }
    }
    NSLog(@"The end...of %s",__func__);
}


/**
 加入异步队列
 */
-(void)GCDAsyncMethod{
    //全局队列是并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i=0; i<10; i++) {
        dispatch_async(queue, ^{
            for (int j = 0; j<30; j++) {
                NSLog(@"\n %s i=%d and j=%d",__func__,i,j);
            }
        });
    }
    NSLog(@"The end...of %s",__func__);
}

/**
 加入同步任务
 这将导致每个迭代器阻塞，一层一层的执行，这种情况和单线程效果一样
 */
-(void)GCDSyncMethod{
    //全局队列是并发队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i=0; i<10; i++) {
        dispatch_sync(queue, ^{
            for (int j = 0; j<30; j++) {
                NSLog(@"\n %s i=%d and j=%d",__func__,i,j);
            }
        });
    }
    NSLog(@"The end...of %s",__func__);
}

/**
 当遇到平行计算完成后再做某件事情的情况下
 这时候使用GCD的 dispatch_async 就悲剧了.我们还不能简单地使用dispatch_sync来解决这个问题, 因为这将导致每个迭代器阻塞，就完全破坏了平行计算。
 解决这个问题的一种方法是使用dispatch group。一个dispatch group可以用来将多个block组成一组以监测这些Block全部完成或者等待全部完成时发出的消息。使用函数dispatch_group_create来创建，然后使用函数dispatch_group_async来将block提交至一个dispatch queue，同时将它们添加至一个组。
 */
-(void)GCDAsyncGroup{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for(int i=0; i<10; i++)
        dispatch_group_async(group, queue, ^{
            for (int j = 0; j<30; j++) {
                NSLog(@"\n %s i=%d and j=%d",__func__,i,j);
            }
        });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    dispatch_release(group);
    
    NSLog(@"The end...of %s",__func__);
    
}

/**
 1、更风骚一点，将最后做的事情放在后台执行。我们使用dispatch_group_async函数建立一个block在组完成后执行；
 2、不仅所有数组元素都会被平行操作，后续的操作也会异步执行，并且这些异步运算都会将程序的其他部分的负载考虑在内。注意如果-最后的操作需要在主线程中执行，比如操作GUI，那么我们只要将main queue而非全局队列传给dispatch_group_notify函数就行了
 */
-(void)GCDAsynGroupBackgroupDoEnd{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    for(int i=0; i<10; i++)
        dispatch_group_async(group, queue, ^{
            
        });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"The end...of %s",__func__);
    });
//    dispatch_release(group);
}

/**
 对于同步执行，GCD提供了一个简化方法叫做dispatch_apply。这个函数调用单一block多次，并平行运算，然后等待所有运算结束，就像我们想要的那样：
 */
-(void)syncDispatchApply{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index){
        for (int j = 0; j<30; j++) {
            NSLog(@"\n %s i=%zu and j=%d",__func__,index,j);
        }
    });
    NSLog(@"The end...of %s",__func__);
}
/*
 *异步Version
 */
-(void)asyncDispathApply{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        dispatch_apply(10, queue, ^(size_t index){
            
            for (int j = 0; j<30; j++) {
                NSLog(@"\n %s i=%zu and j=%d",__func__,index,j);
            }
            
        });
        NSLog(@"The end...of %s",__func__);
    });
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  ZYPhotoBrowser
//
//  Created by 王智垚 on 2017/9/14.
//  Copyright © 2017年 王智垚. All rights reserved.
//

#import "ViewController.h"
#import "PhotoTableViewCell.h"
#import "CMAllMediaPhotoBrowserManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *thumbArray;
    NSArray *sourceUrlArray;
    CMAllMediaPhotoBrowserManager *photoManager;
}
@property(nonatomic, strong)NSArray *dataSource;

@end

@implementation ViewController

//http://s9.sinaimg.cn/orignal/5244a93cg9914e513e468&690
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataSource = @[@"11.jpg", @"22.jpg", @"33.jpg", @"44.jpeg", @"55.jpg", @"66.jpg", @"77.jpg", @"88.jpeg", @"99.jpeg"];
    
    sourceUrlArray = @[@"http://ww2.sinaimg.cn/bmiddle/e67669aagw1f1v6w3ya5vj20hk0qfq86.jpg",
                       @"http://3ds.tgbus.com/UploadFiles/201308/20130826163332457.jpg",
                       @"http://img5.pcpop.com/ProductImages/0x0/0/972/000972723.jpg",
                       @"http://img.xgo-img.com.cn/pics/998/997219.jpg",
                       @"http://img2.duitang.com/uploads/item/201211/10/20121110134323_X8GQK.jpeg",
                       @"http://img4q.duitang.com/uploads/item/201403/22/20140322130003_r5HKG.jpeg",
                       @"http://ww3.sinaimg.cn/bmiddle/61e36371gw1f1v6zegnezg207p06fqv6.gif",
                       @"http://cdnq.duitang.com/uploads/item/201207/13/20120713191526_sQW8N.jpeg",
                       @"https://gss3.baidu.com/6LZ0ej3k1Qd3ote6lo7D0j9wehsv/tieba-smallvideo-transcode/13945345_c75dfd3746c5d783393917579f267c37_4aff8898_3.mp4"];
    photoManager = [CMAllMediaPhotoBrowserManager sharedInstance];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView registerClass:[PhotoTableViewCell class] forCellReuseIdentifier:@"photoListCell"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoListCell"];
    cell.imgView.image = [UIImage imageNamed:_dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *mutArr = [NSMutableArray array];
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:i inSection:0];
        PhotoTableViewCell *cell = [tableView cellForRowAtIndexPath:indexP];
        [mutArr addObject:cell.imgView];
    }
    thumbArray = [mutArr copy];
    
    [photoManager manageShowPhotoBrowserWithThumbArray:thumbArray andSourceUrlArray:sourceUrlArray andTapImgIndex:indexPath.row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

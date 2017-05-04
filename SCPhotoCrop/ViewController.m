//
//  ViewController.m
//  SCPhotoCrop
//
//  Created by KanSC on 2017/5/4.
//  Copyright © 2017年 KanSC. All rights reserved.
//

#import "ViewController.h"
#import "KSCPhotoCropView.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1493887255&di=c132ef35a573ae222b756d4e174a596a&src=http://img27.51tietu.net/pic/2017-011500/20170115001256mo4qcbhixee164299.jpg"]]];
    
    KSCPhotoCropView *cropView = [[KSCPhotoCropView alloc] initWithWhetherCanChangeFrame:YES];
    cropView.originalImage = image;
//    cropView.minWidth = 100;
//    cropView.minHeight = 100;
//    cropView.initialFrame = CGRectMake(20, 64, 100, 100);
    [self.view addSubview:cropView];
    __weak typeof(self) weakSelf = self;
    [cropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  ViewController.m
//  QYLinkTextView
//
//  Created by DemonY on 15/5/25.
//  Copyright (c) 2015年 QY. All rights reserved.
//

#import "ViewController.h"
#import "QYTextView.h"

@interface ViewController () <QYTextViewDelegate>
@property (weak, nonatomic) IBOutlet QYTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.originalString = @"呵呵http://www.baidu.com 哈哈哈哈哈哈https://www.sina.com，yeah";
    self.textView.font = [UIFont systemFontOfSize:20];
}
#pragma mark - QYTextViewDelegate
- (void)textView:(QYTextView *)textView didClickLinkWithURL:(NSURL *)linkURL
{
    NSLog(@"\n点击了%@链接", linkURL.absoluteString);
}

@end

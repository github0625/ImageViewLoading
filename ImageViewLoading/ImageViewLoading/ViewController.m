//
//  ViewController.m
//  ImageViewLoading
//
//  Created by lixiang on 2017/4/1.
//  Copyright © 2017年 lixiang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSMutableData *_data;
    UIProgressView *progressView;
    UILabel *label;
    UIImageView *imgView;
    long long totalLength;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imgView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 20, self.view.frame.size.width-100, 300)];
    [self.view addSubview:imgView];
    
    progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 370, self.view.frame.size.width-20, 10)];
    [self.view addSubview:progressView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 320, self.view.frame.size.width-100, 30)];
    [self.view addSubview:label];
    
    UIButton *btnDown = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, self.view.frame.size.width-20, 35)];
    btnDown.backgroundColor = [UIColor purpleColor];
    [btnDown setTitle:@"开始下载" forState:UIControlStateNormal];
    [btnDown addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnDown];
}

//更新进度
- (void)updateProgress {
    
    float a = (float)_data.length/totalLength;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%.0f%@",a*100,@"%"];
    
    [progressView setProgress:(float)_data.length/totalLength];
    
}

#pragma mark 发送数据请求
-(void)sendRequest{
    NSString *urlStr=[NSString stringWithFormat:@"http://tupian.qqjay.com/u/2013/0615/47_195549_13.jpg"];
    //注意对于url中的中文是无法解析的，需要进行url编码(指定编码类型为utf-8)
    //另外注意url解码使用stringByRemovingPercentEncoding方法
    urlStr=[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //创建url链接
    NSURL *url=[NSURL URLWithString:urlStr];
    /*创建请求
     cachePolicy:缓存策略
     a.NSURLRequestUseProtocolCachePolicy 协议缓存，根据response中的Cache-Control字段判断缓存是否有效，如果缓存有效则使用缓存数据否则重新从服务器请求
     b.NSURLRequestReloadIgnoringLocalCacheData 不使用缓存，直接请求新数据
     c.NSURLRequestReloadIgnoringCacheData 等同于 SURLRequestReloadIgnoringLocalCacheData
     d.NSURLRequestReturnCacheDataElseLoad 直接使用缓存数据不管是否有效，没有缓存则重新请求
     eNSURLRequestReturnCacheDataDontLoad 直接使用缓存数据不管是否有效，没有缓存数据则失败
     timeoutInterval:超时时间设置（默认60s）
     */
    
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15.0f];
    //创建连接
    NSURLConnection *connection=[[NSURLConnection alloc]initWithRequest:request delegate:self];
    //启动连接
    [connection start];
    
}

#pragma mark - 连接代理方法
#pragma mark 开始响应
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"receive response.");
    _data=[[NSMutableData alloc]init];
    progressView.progress=0;
    label.text = @"0";
    
    //通过响应头中的Content-Length取得整个响应的总长度
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
    totalLength = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
    
}

#pragma mark 接收响应数据（根据响应内容的大小此方法会被重复调用）
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"receive data.");
    //连续接收数据
    [_data appendData:data];
    //更新进度
    [self updateProgress];
}

#pragma mark 数据接收完成
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"loading finish.");
    
    //数据接收完保存文件(注意苹果官方要求：下载数据只能保存在缓存目录)
    NSString *savePath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    savePath=[savePath stringByAppendingPathComponent:@"yuancan.jpg"];
    [_data writeToFile:savePath atomically:YES];
    
    imgView.image = [UIImage imageWithContentsOfFile:savePath];
    
    NSLog(@"path:%@",savePath);
}

#pragma mark 请求失败
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    //如果连接超时或者连接地址错误可能就会报错
    NSLog(@"connection error,error detail is:%@",error.localizedDescription);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

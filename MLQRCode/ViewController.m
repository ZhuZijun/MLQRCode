//
//  ViewController.m
//  MLQRCode
//
//  Created by zml on 15/11/18.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL _qrFlag;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _qrFlag = YES; // 二维码 YES 条形码 NO
    // Do any additional setup after loading the view, typically from a nib.
    [self setCapture:_qrFlag];
}

- (void)setCapture:(BOOL)qrFlag
{
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@",[error localizedDescription]);
    }
    AVCaptureSession *captureSession = [[AVCaptureSession alloc]init];
    [captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetaDataOutput = [[AVCaptureMetadataOutput alloc]init];
//    CGSize size = self.view.bounds.size;
//    CGRect cropRect = CGRectMake(50, 160, 220, 220);
//    CGFloat p1 = size.height/size.width;
//    CGFloat p2 = 1920./1080.; //使用了1080p的图像输出
//    if (p1 < p2) {
//        CGFloat fixHeight = self.view.bounds.size.width * 1920. / 1080.;
//        CGFloat fixPadding = (fixHeight - size.height)/2;
//        captureMetaDataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
//                                            cropRect.origin.x/size.width,
//                                            cropRect.size.height/fixHeight,
//                                            cropRect.size.width/size.width);
//    } else {
//        CGFloat fixWidth = self.view.bounds.size.height * 1080. / 1920.;
//        CGFloat fixPadding = (fixWidth - size.width)/2;
//        captureMetaDataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
//                                            (cropRect.origin.x + fixPadding)/fixWidth,
//                                            cropRect.size.height/size.height,
//                                            cropRect.size.width/fixWidth);
//    }
    [captureSession addOutput:captureMetaDataOutput];
    
    dispatch_queue_t  dispatchQueue;
    dispatchQueue = dispatch_queue_create("cameraQueue", NULL);
    
    [captureMetaDataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    if (qrFlag) {
        [captureMetaDataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    }
    else{
        [captureMetaDataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeQRCode, nil]];
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:self.view.layer.bounds];
    [self.view.layer addSublayer:previewLayer];
    
    [captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
  
    if (metadataObjects !=nil && [metadataObjects count]) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects firstObject];
        NSLog(@"%@",metadataObj.stringValue);
        NSString *urlString = metadataObj.stringValue;
        
        dispatch_async(dispatch_get_main_queue(), ^{
           //do something
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
        });
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

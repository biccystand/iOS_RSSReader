/*
     File: SquareCamViewController.m
 Abstract: Dmonstrates iOS 5 features of the AVCaptureStillImageOutput class
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

#import "SquareCamViewController.h"
//#import "Player.h"
//#import "Fruit.h"
#import "GameController.h"
#import "Game.h"
#import "HUDView.h"
#import "UIView+TSExtention.h"
#import "config.h"
#import "BButton.h"
//#import "PopTipManager.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AssertMacros.h>
#import <AssetsLibrary/AssetsLibrary.h>
//#import "SSDialogView.h"
//#import "SSGentleAlertView.h"
#import "CustomIOS7AlertView.h"
#import "DCSocial.h"
#import "UIView+Toast.h"

static NSString * const sampleDescription1 = @"小顔っくまは、顔を動かして遊ぶゲームだよ。\nゲームをしながら小顔エクササイズができるんだ。";
static NSString * const sampleDescription2 = @"ゲームを始めると画面に自分の顔が写るよ。うまく写るように向きや位置を調整してね。黄色い枠が表示されたら顔認識成功だよ。";
static NSString * const sampleDescription3 = @"ゲーム画面に顔を向けると小顔っくまを操作できるよ。\n無表情だと上に移動、口角をあげて笑顔を向けると下に移動するんだ。";
static NSString * const sampleDescription4 = @"笑顔をキープしながら片目を閉じると左右に動かすことができるよ。\n右目を閉じると右に、左目を閉じると左に動くんだ。";
static NSString * const sampleDescription5 = @"小顔っくまを上手に動かして、りんごを拾ってね。制限時間は60秒だよ。";


#pragma mark-

// used for KVO observation of the @"capturingStillImage" property to perform flash bulb animation
static const NSString *AVCaptureStillImageIsCapturingStillImageContext = @"AVCaptureStillImageIsCapturingStillImageContext";

static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size);
static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size) 
{	
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
	CVPixelBufferRelease( pixelBuffer );
}

// create a CGImage with provided pixel buffer, pixel buffer must be uncompressed kCVPixelFormatType_32ARGB or kCVPixelFormatType_32BGRA
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut);
static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut) 
{	
	OSStatus err = noErr;
	OSType sourcePixelFormat;
	size_t width, height, sourceRowBytes;
	void *sourceBaseAddr = NULL;
	CGBitmapInfo bitmapInfo;
	CGColorSpaceRef colorspace = NULL;
	CGDataProviderRef provider = NULL;
	CGImageRef image = NULL;
	
	sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
	if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
	else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
		bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
	else
		return -95014; // only uncompressed pixel formats
	
	sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
	width = CVPixelBufferGetWidth( pixelBuffer );
	height = CVPixelBufferGetHeight( pixelBuffer );
	
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
	
	colorspace = CGColorSpaceCreateDeviceRGB();
    
	CVPixelBufferRetain( pixelBuffer );
	provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
	image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
	
bail:
	if ( err && image ) {
		CGImageRelease( image );
		image = NULL;
	}
	if ( provider ) CGDataProviderRelease( provider );
	if ( colorspace ) CGColorSpaceRelease( colorspace );
	*imageOut = image;
	return err;
}

// utility used by newSquareOverlayedImageForFeatures for 
static CGContextRef CreateCGBitmapContextForSize(CGSize size);
static CGContextRef CreateCGBitmapContextForSize(CGSize size)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow = (size.width * 4);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate (NULL,
									 size.width,
									 size.height,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	CGContextSetAllowsAntialiasing(context, NO);
    CGColorSpaceRelease( colorSpace );
    return context;
}

#pragma mark-

@interface UIImage (RotationMethods)
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end

@implementation UIImage (RotationMethods)
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees 
{   
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	
	// Create the bitmap context
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
	
}

@end

#pragma mark-

@interface SquareCamViewController (InternalMethods)<UIAlertViewDelegate, AVAudioPlayerDelegate, CustomIOS7AlertViewDelegate>
//@property (assign) SSGentleAlertViewStyle style;
//@property (assign) BOOL original;
//@property (nonatomic, strong)	NSArray			*colorSchemes;
//@property (nonatomic, strong)	NSDictionary	*popContents;
//@property (nonatomic, strong)	id				currentPopTipViewTarget;
//@property (nonatomic, strong)	NSDictionary	*titles;
//@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
//
- (void)setupAVCapture;
- (void)teardownAVCapture;
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation;
@end

@implementation SquareCamViewController
{
    UIAlertView *_alert;
    float nadViewTop;
    UIButton *_stopButton;
    UIButton *_tutorialButton;
    UIButton *_gameButton;
    UIView *_rootView;
    AVCaptureSession *session;
    BOOL _sessionStopped;
    UIView *_toast;

//    PopTipManager *_popTipManager;
//    __weak IBOutlet UIView *baseView;
//    __weak IBOutlet UITableView *menuTableView;
}
- (IBAction)pushedStopButton:(id)sender {
//    [_controller stopGameOnTimeout:NO];
    [self showIntro];
}

- (void)setupAVCapture
{
	NSError *error = nil;
	
	session = [AVCaptureSession new];
    [session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	    [session setSessionPreset:AVCaptureSessionPreset640x480];
	else
	    [session setSessionPreset:AVCaptureSessionPresetPhoto];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//	require( error == nil, bail );
    
    if (error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
            [alertView show];
            [self teardownAVCapture];
        }
    }
	
//    isUsingFrontFacingCamera = NO;
    isUsingFrontFacingCamera = YES;
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a still image output
	stillImageOutput = [AVCaptureStillImageOutput new];
	[stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:(__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext)];
	if ( [session canAddOutput:stillImageOutput] )
		[session addOutput:stillImageOutput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
									   [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
		[session addOutput:videoDataOutput];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
	
	effectiveScale = 1.0;
	previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
	[previewLayer setBackgroundColor:[[UIColor whiteColor] CGColor]];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
	[previewLayer setFrame:[rootLayer bounds]];
	[rootLayer addSublayer:previewLayer];
	[session startRunning];

}

// clean up capture setup
- (void)teardownAVCapture
{
//	if (videoDataOutputQueue)
//		dispatch_release(videoDataOutputQueue);
	[stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
	[previewLayer removeFromSuperlayer];
}

// perform a flash bulb animation using KVO to monitor the value of the capturingStillImage property of the AVCaptureStillImageOutput class
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"running"]) {
        NSLog(@"kvc succeeded");
        NSLog(@"ch: %@", change);
        NSLog(@"new: %@", [change objectForKey:@"new"]);
        if ([[change objectForKey:@"new"] integerValue] == 1) {
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [previewView setAlpha:1.0];
            }completion:^(BOOL finished){
                
            }];
        }
    }
    
	if ( context == (__bridge void *)(AVCaptureStillImageIsCapturingStillImageContext) ) {
		BOOL isCapturingStillImage = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
		
		if ( isCapturingStillImage ) {
			// do flash bulb like animation
			flashView = [[UIView alloc] initWithFrame:[previewView frame]];
			[flashView setBackgroundColor:[UIColor whiteColor]];
			[flashView setAlpha:0.f];
			[[[self view] window] addSubview:flashView];
			
			[UIView animateWithDuration:.4f
							 animations:^{
								 [flashView setAlpha:1.f];
							 }
			 ];
		}
		else {
			[UIView animateWithDuration:.4f
							 animations:^{
								 [flashView setAlpha:0.f];
							 }
							 completion:^(BOOL finished){
								 [flashView removeFromSuperview];
								 flashView = nil;
							 }
			 ];
		}
	}
}

// utility routing used during image capture to set up capture orientation
- (AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
	AVCaptureVideoOrientation result = deviceOrientation;
	if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
		result = AVCaptureVideoOrientationLandscapeRight;
	else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
		result = AVCaptureVideoOrientationLandscapeLeft;
	return result;
}

// utility routine to create a new image with the red square overlay with appropriate orientation
// and return the new composited image which can be saved to the camera roll
- (CGImageRef)newSquareOverlayedImageForFeatures:(NSArray *)features 
											inCGImage:(CGImageRef)backgroundImage 
									  withOrientation:(UIDeviceOrientation)orientation 
										  frontFacing:(BOOL)isFrontFacing
{
	CGImageRef returnImage = NULL;
	CGRect backgroundImageRect = CGRectMake(0., 0., CGImageGetWidth(backgroundImage), CGImageGetHeight(backgroundImage));
	CGContextRef bitmapContext = CreateCGBitmapContextForSize(backgroundImageRect.size);
	CGContextClearRect(bitmapContext, backgroundImageRect);
	CGContextDrawImage(bitmapContext, backgroundImageRect, backgroundImage);
	CGFloat rotationDegrees = 0.;
	
	switch (orientation) {
		case UIDeviceOrientationPortrait:
			rotationDegrees = -90.;
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			rotationDegrees = 90.;
			break;
		case UIDeviceOrientationLandscapeLeft:
			if (isFrontFacing) rotationDegrees = 180.;
			else rotationDegrees = 0.;
			break;
		case UIDeviceOrientationLandscapeRight:
			if (isFrontFacing) rotationDegrees = 0.;
			else rotationDegrees = 180.;
			break;
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown:
		default:
			break; // leave the layer in its last known orientation
	}
	UIImage *rotatedSquareImage = [square imageRotatedByDegrees:rotationDegrees];
	
    // features found by the face detector
	for ( CIFaceFeature *ff in features ) {
		CGRect faceRect = [ff bounds];
		CGContextDrawImage(bitmapContext, faceRect, [rotatedSquareImage CGImage]);
	}
	returnImage = CGBitmapContextCreateImage(bitmapContext);
	CGContextRelease (bitmapContext);
	
	return returnImage;
}

// utility routine used after taking a still image to write the resulting image to the camera roll
- (BOOL)writeCGImageToCameraRoll:(CGImageRef)cgImage withMetadata:(NSDictionary *)metadata
{
	CFMutableDataRef destinationData = CFDataCreateMutable(kCFAllocatorDefault, 0);
	CGImageDestinationRef destination = CGImageDestinationCreateWithData(destinationData, 
																		 CFSTR("public.jpeg"), 
																		 1, 
																		 NULL);
	BOOL success = (destination != NULL);
//	require(success, bail);
    if (!success) {
        if (destinationData)
            CFRelease(destinationData);
        if (destination)
            CFRelease(destination);
        return success;
    }

	const float JPEGCompQuality = 0.85f; // JPEGHigherQuality
	CFMutableDictionaryRef optionsDict = NULL;
	CFNumberRef qualityNum = NULL;
	
	qualityNum = CFNumberCreate(0, kCFNumberFloatType, &JPEGCompQuality);    
	if ( qualityNum ) {
		optionsDict = CFDictionaryCreateMutable(0, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		if ( optionsDict )
			CFDictionarySetValue(optionsDict, kCGImageDestinationLossyCompressionQuality, qualityNum);
		CFRelease( qualityNum );
	}
	
	CGImageDestinationAddImage( destination, cgImage, optionsDict );
	success = CGImageDestinationFinalize( destination );

	if ( optionsDict )
		CFRelease(optionsDict);
	
//	require(success, bail);
	
    if (!success) {
        if (destinationData)
            CFRelease(destinationData);
        if (destination)
            CFRelease(destination);
        return success;
    }
	CFRetain(destinationData);
	ALAssetsLibrary *library = [ALAssetsLibrary new];
	[library writeImageDataToSavedPhotosAlbum:(__bridge id)destinationData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
		if (destinationData)
			CFRelease(destinationData);
	}];


}

// utility routine to display error aleart if takePicture fails
- (void)displayErrorOnMainQueue:(NSError *)error withMessage:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%d)", message, (int)[error code]]
															message:[error localizedDescription]
														   delegate:nil 
												  cancelButtonTitle:@"Dismiss" 
												  otherButtonTitles:nil];
		[alertView show];
	});
}

// main action method to take a still image -- if face detection has been turned on and a face has been detected
// the square overlay will be composited on top of the captured image and saved to the camera roll
- (IBAction)takePicture:(id)sender
{
    [_controller stopGameOnTimeout:NO];
    return;
//	// Find out the current orientation and tell the still image output.
//	AVCaptureConnection *stillImageConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
//	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
//	AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
//	[stillImageConnection setVideoOrientation:avcaptureOrientation];
//	[stillImageConnection setVideoScaleAndCropFactor:effectiveScale];
//	
//    BOOL doingFaceDetection = detectFaces && (effectiveScale == 1.0);
//	
//    // set the appropriate pixel format / image type output setting depending on if we'll need an uncompressed image for
//    // the possiblity of drawing the red square over top or if we're just writing a jpeg to the camera roll which is the trival case
//    if (doingFaceDetection)
//		[stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA] 
//																		forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//	else
//		[stillImageOutput setOutputSettings:[NSDictionary dictionaryWithObject:AVVideoCodecJPEG 
//																		forKey:AVVideoCodecKey]]; 
//	
//	[stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection
//		completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//			if (error) {
//				[self displayErrorOnMainQueue:error withMessage:@"Take picture failed"];
//			}
//			else {
//				if (doingFaceDetection) {
//					// Got an image.
//					CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(imageDataSampleBuffer);
//					CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, imageDataSampleBuffer, kCMAttachmentMode_ShouldPropagate);
//					CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
//					if (attachments)
//						CFRelease(attachments);
//					
//					NSDictionary *imageOptions = nil;
//					NSNumber *orientation = (__bridge NSNumber *)(CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyOrientation, NULL));
//					if (orientation) {
//						imageOptions = [NSDictionary dictionaryWithObject:orientation forKey:CIDetectorImageOrientation];
//					}
//					
//                    // when processing an existing frame we want any new frames to be automatically dropped
//                    // queueing this block to execute on the videoDataOutputQueue serial queue ensures this
//                    // see the header doc for setSampleBufferDelegate:queue: for more information
//                    dispatch_sync(videoDataOutputQueue, ^(void) {
//                    
//                        // get the array of CIFeature instances in the given image with a orientation passed in
//                        // the detection will be done based on the orientation but the coordinates in the returned features will
//                        // still be based on those of the image.
//						NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
//						CGImageRef srcImage = NULL;
//						OSStatus err = CreateCGImageFromCVPixelBuffer(CMSampleBufferGetImageBuffer(imageDataSampleBuffer), &srcImage);
//						check(!err);
//						
//                        CGImageRef cgImageResult = [self newSquareOverlayedImageForFeatures:features 
//																					   inCGImage:srcImage 
//																				 withOrientation:curDeviceOrientation 
//																					 frontFacing:isUsingFrontFacingCamera];
//						if (srcImage)
//							CFRelease(srcImage);
//						
//						CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, 
//																					imageDataSampleBuffer, 
//																					kCMAttachmentMode_ShouldPropagate);
//						[self writeCGImageToCameraRoll:cgImageResult withMetadata:(__bridge id)attachments];
//						if (attachments)
//							CFRelease(attachments);
//						if (cgImageResult)
//							CFRelease(cgImageResult);
//						
//					});
//					
//				}
//				else {
//					// trivial simple JPEG case
//					NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
//					CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, 
//																				imageDataSampleBuffer, 
//																				kCMAttachmentMode_ShouldPropagate);
//					ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//					[library writeImageDataToSavedPhotosAlbum:jpegData metadata:(__bridge id)attachments completionBlock:^(NSURL *assetURL, NSError *error) {
//						if (error) {
//							[self displayErrorOnMainQueue:error withMessage:@"Save to camera roll failed"];
//						}
//					}];
//					
//					if (attachments)
//						CFRelease(attachments);
//				}
//			}
//		}
//	 ];
}

// turn on/off face detection
- (void)setFaceDetection
{
//	detectFaces = [(UISwitch *)sender isOn];
	detectFaces = YES;
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:detectFaces];
	if (!detectFaces) {
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			// clear out any squares currently displaying.
			[self drawFaceBoxesForFeatures:[NSArray array] forVideoBox:CGRectZero orientation:UIDeviceOrientationPortrait];
		});
	}
}
- (IBAction)toggleFaceDetection:(id)sender
{
    return;
	detectFaces = [(UISwitch *)sender isOn];
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:detectFaces];
	if (!detectFaces) {
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			// clear out any squares currently displaying.
			[self drawFaceBoxesForFeatures:[NSArray array] forVideoBox:CGRectZero orientation:UIDeviceOrientationPortrait];
		});
	}
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
	
	CGRect videoBox;
	videoBox.size = size;
	if (size.width < frameSize.width)
		videoBox.origin.x = (frameSize.width - size.width) / 2;
	else
		videoBox.origin.x = (size.width - frameSize.width) / 2;
	
	if ( size.height < frameSize.height )
		videoBox.origin.y = (frameSize.height - size.height) / 2;
	else
		videoBox.origin.y = (size.height - frameSize.height) / 2;
    
	return videoBox;
}

// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSArray *sublayers = [NSArray arrayWithArray:[previewLayer sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for ( CALayer *layer in sublayers ) {
		if ( [[layer name] isEqualToString:@"FaceLayer"] )
			[layer setHidden:YES];
	}	
	
	if ( featuresCount == 0 || !detectFaces ) {
		[CATransaction commit];
		return; // early bail.
	}
		
	CGSize parentFrameSize = [previewView frame].size;
	NSString *gravity = [previewLayer videoGravity];
	BOOL isMirrored = [previewLayer isMirrored];
	CGRect previewBox = [SquareCamViewController videoPreviewBoxForGravity:gravity 
															   frameSize:parentFrameSize 
															apertureSize:clap.size];
	
	for ( CIFaceFeature *ff in features ) {
		// find the correct position for the square layer within the previewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
		CGRect faceRect = [ff bounds];
        [_controller reactToFaceFeature:ff];
        
//        if (CGRectIntersectsRect(player.frame, fruit.frame)) {
//            NSLog(@"set");
//            player.backgroundColor = [UIColor redColor];
//            fruit.backgroundColor  = [UIColor redColor];
//        }
//        else if (!ff.hasSmile && !ff.rightEyeClosed && !ff.leftEyeClosed) {
//            NSLog(@"smile4");
//            iv1.backgroundColor = [UIColor whiteColor];
////            [iv1 moveX:-10 moveY:-10];
//
//        }
//        else if (!ff.hasSmile && ff.rightEyeClosed && ff.leftEyeClosed) {
//            NSLog(@"smile5");
//            iv1.backgroundColor = [UIColor purpleColor];
//        }
//        else
//        {
//            NSLog(@"else");
//            iv1.backgroundColor = [UIColor brownColor];
//        }
        
//        float eyeOffset = (ff.rightEyePosition.x + ff.leftEyePosition.x)/2.0f - ff.bounds.origin.x;
//        float mouthOffset = ff.mouthPosition.x - ff.bounds.origin.x;
//        float eyeOffsetRatio = eyeOffset/ff.bounds.size.height;
//        float mouthOffsetRatio = mouthOffset/ff.bounds.size.height;
//        float aspectRatio = ff.bounds.size.width / ff.bounds.size.height;
//        label1.text = [NSString stringWithFormat:@"eye: %f", eyeOffsetRatio];
//        label3.text = [NSString stringWithFormat:@"mouth: %f", mouthOffsetRatio-eyeOffsetRatio];
//        label2.text = [NSString stringWithFormat:@"asp: %f", aspectRatio];
//        label4.text = [NSString stringWithFormat:@"mouth: %f", (ff.mouthPosition.y - ff.bounds.origin.x)/ff.bounds.size.width];
        
//        float eyeHeight = ff.rightEyePositionff.bounds.size.height;

		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
		CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
		faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;

		if ( isMirrored )
			faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
		
		CALayer *featureLayer = nil;
		
		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}
		
		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [CALayer new];
			[featureLayer setContents:(id)[square CGImage]];
			[featureLayer setName:@"FaceLayer"];
			[previewLayer addSublayer:featureLayer];
		}
		[featureLayer setFrame:faceRect];
		
		switch (orientation) {
			case UIDeviceOrientationPortrait:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
		}
		currentFeature++;
	}
	
	[CATransaction commit];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{	
	// got an image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
	int exifOrientation;
	
    /* kCGImagePropertyOrientation values
        The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
        by the TIFF and EXIF specifications -- see enumeration of integer constants. 
        The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
        
        used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
        If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
        
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.  
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.  
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.  
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.  
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}

//	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    imageOptions = @{
                     CIDetectorImageOrientation:[NSNumber numberWithInt:exifOrientation],
                     CIDetectorSmile: @(YES),
                     CIDetectorEyeBlink: @(YES),
                     };
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
}

- (void)dealloc
{
	[self teardownAVCapture];
    [self.nadView setDelegate:nil];
    self.nadView = nil;
}



#pragma mark -

// use front/back camera
- (void)setCameraPosition
{
	AVCaptureDevicePosition desiredPosition;
//	if (isUsingFrontFacingCamera)
//		desiredPosition = AVCaptureDevicePositionBack;
//	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
//	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

- (IBAction)switchCameras:(id)sender
{
    return;
	AVCaptureDevicePosition desiredPosition;
	if (isUsingFrontFacingCamera)
		desiredPosition = AVCaptureDevicePositionBack;
	else
		desiredPosition = AVCaptureDevicePositionFront;
	
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			[[previewLayer session] beginConfiguration];
			AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
			for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
				[[previewLayer session] removeInput:oldInput];
			}
			[[previewLayer session] addInput:input];
			[[previewLayer session] commitConfiguration];
			break;
		}
	}
	isUsingFrontFacingCamera = !isUsingFrontFacingCamera;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)showIntro
{
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"小顔っくまの遊び方";
    page1.desc = sampleDescription1;
//    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.bgImage = [UIImage imageWithColor:ColorPink];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bearintro"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"顔の認識";
    page2.desc = sampleDescription2;
    //    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page2.bgImage = [UIImage imageWithColor:ColorPink];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bearintro_recog"]];

    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"上下の移動";
    page3.desc = sampleDescription3;
//    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page3.bgImage = [UIImage imageWithColor:ColorPink];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bearintro2"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"左右の移動";
    page4.desc = sampleDescription4;
//    page3.bgImage = [UIImage imageNamed:@"bg3"];
    page4.bgImage = [UIImage imageWithColor:ColorPink];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bearintro4"]];
    
    EAIntroPage *page5 = [EAIntroPage page];
    page5.title = @"ゲームの得点";
    page5.desc = sampleDescription5;
//    page4.bgImage = [UIImage imageNamed:@"bg4"];
    page5.bgImage = [UIImage imageWithColor:ColorPink];
    page5.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bearintro5"]];
    

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:_rootView.bounds andPages:@[page1,page2,page3,page4,page5]];
    [intro setDelegate:self];
    
    [intro showInView:_rootView animateDuration:0.3];
}

//+ (void)setAppearanceToGentleAlertView:(SSGentleAlertView*)alertView
//{
//    alertView.backgroundImageView.image = [UIImage imageNamed:@"dialog_bg"];
//    alertView.dialogImageView.image = nil;
//    
//    alertView.titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
//    alertView.titleLabel.shadowColor = UIColor.clearColor;
//    alertView.messageLabel.textColor = [UIColor colorWithRed:0.4 green:0.2 blue:0.0 alpha:1.0];
//    alertView.messageLabel.shadowColor = UIColor.clearColor;
//    
//    UIButton* button = [alertView buttonBase];
//    [button setBackgroundImage:[SSDialogView resizableImage:[UIImage imageNamed:@"dialog_btn_normal"]] forState:UIControlStateNormal];
//    [button setBackgroundImage:[SSDialogView resizableImage:[UIImage imageNamed:@"dialog_btn_pressed"]] forState:UIControlStateHighlighted];
//    [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
//    [button setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
//    [alertView setButtonBase:button];
//    [alertView setDefaultButtonBase:button];
//}

#pragma mark - View lifecycle

//- (void)button1DidPush:(id)sender
//{
//    /*
//     UIAlertView* alert;
//     //alert = [[UIAlertView alloc] initWithTitle:nil
//     //message:@"Hello, SSGentleAlertView!"
//     alert = [[UIAlertView alloc] initWithTitle:@"Hello, SSGentleAlertView! 1234567890"
//     message:@"Hello, SSGentleAlertView! 1234567890"
//     delegate:self
//     cancelButtonTitle:nil
//     otherButtonTitles:@"OK", nil];
//     */
//    SSGentleAlertView* alert;
//    
//    
//    alert = [[SSGentleAlertView alloc] initWithStyle:3
//                                               title:@"Hello, SSGentleAlertView!"
//                                             message:nil
//                                            delegate:self
//                                   cancelButtonTitle:nil
//                                   otherButtonTitles:@"OK", nil];
////    if (self.isOriginal) {
//        [self.class setAppearanceToGentleAlertView:alert];
//        alert.disappearWhenBackgroundClicked = YES;
////    }
//    [alert show];
//}
//
//- (void)styleDidChange
//{
//    self.original = YES;
//    [self updateStyle:SSGentleAlertViewStyleDefault];
//}
//
//- (void)updateStyle:(SSGentleAlertViewStyle)style
//{
////    switch (style) {
////        case SSGentleAlertViewStyleNative:
////            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
////            self.navigationController.toolbar.barStyle = UIBarStyleDefault;
//////            self.segmentedControl.tintColor = nil;
////            break;
////        case SSGentleAlertViewStyleBlack:
////            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
////            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
//////            self.segmentedControl.tintColor = UIColor.blackColor;
////            break;
////        default:
////            self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
////            self.navigationController.toolbar.barStyle = UIBarStyleDefault;
//////            self.segmentedControl.tintColor = nil;
////            break;
////    }
////    self.style = style;
//}
//

-(void)makeToast: (NSString *)message{
//    [_toast handleToastTapped:nil];
    [_toast touchesBegan:nil withEvent:nil];
    _toast = [self.view makeToast:message];
}

-(void)removeToast
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self setUpPopTipView];
//    self.style = 1;
//    [self updateStyle:3];
    float tabBarHeight = self.tabBarController.rotatingFooterView.frame.size.height;
    NADView *nadView;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        nadView = [[NADView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kAdbarHeight-tabBarHeight, kScreenWidth, kAdbarHeight)];
        nadView.backgroundColor = [UIColor redColor];
    }
    else
    {
        nadView = [[NADView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kAdbarHeight-tabBarHeight, kScreenWidth, kAdbarHeight)];
    }
    
    nadViewTop = nadView.y;
    self.nadView = nadView;
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:kNendID spotID:kSpotID];
    [self.nadView setDelegate:self];
    [self.nadView load];
    
    [self.view addSubview:self.nadView];
    NSLog(@"nadview: %@", self.nadView);
    
//    self.navigationController.navigationBar.translucent = NO;
    
//    float buttonHeight = _stopButton.frame.size.height;
//    _stopButton.y = nadView.y - buttonHeight - 20;
//    _stopButton.x = kScreenWidth - _stopButton.width - 30;

    
//    self.view.backgroundColor = ColorPink;
//    baseView.backgroundColor = ColorPink;
    detectFaces = YES;
//    isUsingFrontFacingCamera = YES;
//    _alert = [[UIAlertView alloc] initWithTitle:@"ゲームの選択" message:@"ゲームを選んでください" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles: nil];
//    NSLog(@"array: %@", [self gameTitleArray]);
//    for (NSString *string in [self gameTitleArray]) {
//        [_alert addButtonWithTitle:string];
//    }
//    _alert = [[UIAlertView alloc] initWithTitle:@"ゲームの選択" message:@"ゲームを選んでください" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"チュートリアル", @"果物拾い", @"リンゴ", nil];
//    [_alert show];
	[self setupAVCapture];
    
	// Do any additional setup after loading the view, typically from a nib.
    GameController *gameController = [[GameController alloc] init];
    gameController.squareCamViewController = self;
    self.controller = gameController;
    self.controller.gameView = previewView;
//    self.controller.game = [Game gameWithNum:1];
    
    __weak SquareCamViewController* weakSelf = self;
    self.controller.onGameOver = ^(){
        [weakSelf showGameMenu];
    };
    
    HUDView* hudView = [HUDView viewWithRect:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:hudView];
    [self.controller setUpHud:hudView];
//    self.controller.hud = hudView;
    
//    [self setupDirectionImage];
	square = [UIImage imageNamed:@"faceSquare"];
	NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
	faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
//    [self.controller startGame];
    [self setCameraPosition];
    [self setFaceDetection];
    [self setUpButtons];
    [self showButtonInActive:NO];
}

- (void)setUpButtons
{
//    BButtonType type = 0;
//    int i = 0;
//    for(int j = 0; j < 2; j++) {
//        CGRect frame = CGRectMake(32.0f + (i * 144.0f),
//                                  40.0f + 100.0f + (j * 60.0f),
//                                  112.0f,
//                                  44.0f);

    CGRect frame = CGRectMake(2, nadViewTop-kBButtonHeight, kScreenWidth-4.0f, kBButtonHeight);
    _stopButton = [[BButton alloc] initWithFrame:frame type:BButtonTypeDanger style:BButtonStyleBootstrapV3];
    [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    
    [_stopButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopButton];

    frame = CGRectMake(2, nadViewTop-kBButtonHeight, kScreenWidth/2.0-3.0, kBButtonHeight);
    _gameButton = [[BButton alloc] initWithFrame:frame type:BButtonTypeDanger style:BButtonStyleBootstrapV3];
    [_gameButton setTitle:@"ゲームスタート" forState:UIControlStateNormal];
    
    [_gameButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_gameButton];

    frame = CGRectMake(kScreenWidth/2.0+1.0, nadViewTop-kBButtonHeight, kScreenWidth/2.0-3.0, kBButtonHeight);
    _tutorialButton = [[BButton alloc] initWithFrame:frame type:BButtonTypeDanger style:BButtonStyleBootstrapV3];
    [_tutorialButton setTitle:@"チュートリアル" forState:UIControlStateNormal];
    
    [_tutorialButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_tutorialButton];
//    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger introDone = (NSInteger)[userDefaults integerForKey:@"introDone"];
    _rootView =  self.tabBarController.view;
    if (!introDone) {
        [self showIntro];
        [userDefaults setInteger:1 forKey:@"introDone"];
    }

}

- (void)launchDialog:(id)sender
{
    if (!_appearing) {
        return;
    }
    CustomIOS7AlertView *alertView = [CustomIOS7AlertView alertWithTitle:@"Thank you for trying this demo" message:@"If you liked what you saw,\nand are interesting in seeing\nwhat we can do together,\nplease shoot us a mail by tapping the button below."];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Shoot us a mail!", @"Try another demo!", @"Close", nil]];
    [alertView setButtonColors:[NSMutableArray arrayWithObjects:[UIColor colorWithRed:255.0f/255.0f green:77.0f/255.0f blue:94.0f/255.0f alpha:1.0f],[UIColor colorWithRed:0.0f green:0.5f blue:1.0f alpha:1.0f],nil]];
    [alertView setDelegate:self];
    [alertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, (int)[alertView tag]);
        [alertView close];
    }];
    [alertView show];

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [alertView close];
}


- (void)buttonPressed:(UIButton*)sender
{
    if (sender == _tutorialButton) {
        [self showButtonInActive:YES];
        self.controller.game = [Game gameWithNum:1];
        self.controller.tutorial = YES;
        [self.controller startGame];
    }
    else if (sender == _gameButton) {
        [self showButtonInActive:YES];
        self.controller.game = [Game gameWithNum:2];
        self.controller.tutorial = NO;
        [self.controller startGame];
    }
    else if (sender == _stopButton) {
        [self showButtonInActive:NO];
        [_controller stopGameOnTimeout:NO];
        self.controller.tutorial = NO;
        NSLog(@"stop");
    }
}

- (void)showButtonInActive:(BOOL)active
{
    _gameButton.hidden = active;
    _tutorialButton.hidden = active;
    _stopButton.hidden = !active;
}

- (NSString *)titleForType:(BButtonType)type
{
    switch (type) {
        case BButtonTypePrimary:
            return @"Primary";
            
        case BButtonTypeInfo:
            return @"Info";
            
        case BButtonTypeSuccess:
            return @"Success";
            
        case BButtonTypeWarning:
            return @"Warning";
            
        case BButtonTypeDanger:
            return @"Danger";
            
        case BButtonTypeInverse:
            return @"Inverse";
            
        case BButtonTypeTwitter:
            return @"Twitter";
            
        case BButtonTypeFacebook:
            return @"Facebook";
            
        case BButtonTypePurple:
            return @"Purple";
            
        case BButtonTypeGray:
            return @"Gray";
            
        case BButtonTypeDefault:
        default:
            return @"Default";
    }
}

- (NSArray*)gameTitleArray
{
    NSMutableArray *array = [NSMutableArray array];
    NSString* fileName = [NSString stringWithFormat:@"game.plist"];
    NSString* gamePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
    
    NSLog(@"path: %@", gamePath);
    NSArray *gameArray = [NSArray arrayWithContentsOfFile:gamePath];
    NSAssert(gameArray, @"game config file not found");
    for (NSDictionary *dict in gameArray) {
        [array addObject:[dict objectForKey:@"title"]];
    }
    return array;
}

- (void)showGameMenu
{
//    [_alert show];
    [self showButtonInActive:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _appearing = YES;
    if (_sessionStopped) {
        [session startRunning];
        _sessionStopped = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    _appearing = NO;
    [session stopRunning];
    _sessionStopped = YES;
    [previewView setAlpha:0.0];
//    [_controller stopGameOnTimeout:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		beginGestureScale = effectiveScale;
	}
	return YES;
}

// scale image depending on users pinch gesture
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    return;
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [recognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [recognizer locationOfTouch:i inView:previewView];
		CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
		if ( ! [previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		effectiveScale = beginGestureScale * recognizer.scale;
		if (effectiveScale < 1.0)
			effectiveScale = 1.0;
		CGFloat maxScaleAndCropFactor = [[stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
		if (effectiveScale > maxScaleAndCropFactor)
			effectiveScale = maxScaleAndCropFactor;
		[CATransaction begin];
		[CATransaction setAnimationDuration:.025];
		[previewLayer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
		[CATransaction commit];
	}
}

#pragma mark - UIAlertViewDelegate Method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex) {
        return;
    }
    self.controller.game = [Game gameWithNum:(int)buttonIndex];
    [self.controller startGame];
}

#pragma mark - NadView Delegate Methods
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    return cell;
}



@end

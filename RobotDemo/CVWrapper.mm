//
//  CVWrapper.m
//  CVOpenTemplate
//
//  Created by Washe on 02/01/2013.
//  Copyright (c) 2013 foundry. All rights reserved.
//

#import "CVWrapper.h"
#import "UIImage+OpenCV.h"
#import "stitching.h"

//@interface CVWrapper()
//@property (nonatomic) cv::Mat uiimage_data;
//@end

@implementation CVWrapper
//@synthesize uiimage_data;


//-(UIImage*) toUIImage{
//    return [UIImage imageWithCVMat:uiimage_data];
//}

+ (UIImage*) processImageWithOpenCV: (UIImage*) inputImage
{
    NSArray* imageArray = [NSArray arrayWithObject:inputImage];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithOpenCVImage1:(UIImage*)inputImage1 image2:(UIImage*)inputImage2;
{
    NSArray* imageArray = [NSArray arrayWithObjects:inputImage1,inputImage2,nil];
    UIImage* result = [[self class] processWithArray:imageArray];
    return result;
}

+ (UIImage*) processWithArray:(NSArray*)imageArray
{
    if ([imageArray count]==0){
        NSLog (@"imageArray is empty");
        return 0;
        }
    std::vector<cv::Mat> matImages;

    for (id image in imageArray) {
        if ([image isKindOfClass: [UIImage class]]) {
            cv::Mat matImage = [image CVMat3];
            NSLog (@"matImage: %@",image);
            matImages.push_back(matImage);
        }
    }
    NSLog (@"stitching...");
    cv::Mat stitchedMat = stitch (matImages);
    UIImage* result =  [UIImage imageWithCVMat:stitchedMat];
    return result;
}

+ (UIImage *) createUIImageWithArray:(UInt8 *)dataArray
{
//    if([dataArray count] != 300){
//        NSLog(@"Data length is not enough");
//        return 0;
//    }
    
    cv::Mat matImage = cv::Mat(400,400,CV_8UC1);
    
    for (int i = 0; i<400; i++) {
        for (int j = 0; j<400; j++) {
        //printf("-%d", *(dataArray+((i*400)+j)));
           matImage.at<uchar>(399-i,j) = *(dataArray+((i*400)+j));
        }
    }
    
    UIImage *result = [UIImage imageWithCVMat:matImage];
    return result;
}





@end

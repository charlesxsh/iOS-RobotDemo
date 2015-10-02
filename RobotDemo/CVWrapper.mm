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

+ (UIImage *) createUIImageWithArray:(UInt8 *)dataArray length:(int)imageLength
{
    cv::Mat matImage = cv::Mat(imageLength,imageLength,CV_8UC1);
    if (imageLength == 60) {
        for (int i = 0; i<imageLength; i++) {
            for (int j = 0; j<imageLength; j++) {
                uchar t = *(dataArray+((i*imageLength)+j));
                if (t == 0) {
                    matImage.at<uchar>(i,j) = 255;
                }else{
                    matImage.at<uchar>(i,j) = 0;
                }
            }
        }
    }else{
        for (int i = 0; i<imageLength; i++) {
            for (int j = 0; j<imageLength; j++) {
                matImage.at<uchar>(i,j) = *(dataArray+((i*imageLength)+j));
            }
        }
    }
    UIImage *result = [UIImage imageWithCVMat:matImage];
    return result;
}

+ (bool) checkPointUncharted:(UInt8 *)dataArray positionx:(int)px positiony:(int)py
{
    float white_up_limit = 0.65;
    float white_down_limit = 0.4;
    int white_count = 0;
    UInt8 temp = 0;
    if (*(dataArray+((px*400)+py)) < 160 || *(dataArray+((px*400)+py)) > 245) {
        return false;
    }
    
    UInt8 *startpoint = dataArray + px*400 + py - 1203;
    for (int i = 0; i < 7; i++) {
        for (int j = 0; j < 7; j++) {
            temp = *(startpoint+i*400+j);
            if (temp < 160) {
                return false;
            }
            if (temp > 225) {
                white_count++;
            }
        }
    }
    float result = white_count / 49.0;
    if (result >= white_down_limit && result <= white_up_limit) {
        return true;
    }else{
        return false;
    }
}

+(NSMutableArray *) getAllUncharted:(UInt8 *)dataArray {
    NSMutableArray *na = [[NSMutableArray alloc]init];
    for (int i = 0; i < 400; i++) {
        for (int j = 0 ; j < 400; j++) {
            if ([CVWrapper checkPointUncharted:dataArray positionx:i positiony:j]){
                CGPoint temp_point = CGPointMake(i, j);
                [na addObject:[NSValue valueWithCGPoint:temp_point]];
            }
        }
    }
    return na;
}




@end



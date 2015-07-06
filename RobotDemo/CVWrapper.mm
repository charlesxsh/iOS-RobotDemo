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
           matImage.at<uchar>(i,j) = *(dataArray+((i*400)+j));
        }
    }
    
    UIImage *result = [UIImage imageWithCVMat:matImage];
    return result;
}

+ (bool) checkPointUncharted:(UInt8 *)dataArray positionx:(int)px positiony:(int)py
{
    float white_up_limit = 0.5;
    float white_down_limit = 0.4;
    int white_count = 0;
    UInt8 temp = 0;
    if (*(dataArray+((px*400)+py)) < 160 || *(dataArray+((px*400)+py)) > 230) {
        return false;
    }
    
    UInt8 *startpoint = dataArray + px*400 + py - 401;
    for (int i = 0; i<3; i++) {
        for (int j = 0; j < 3; j++) {
            temp = *(startpoint+i*400+j);
            if (temp < 175) {
                return false;
            }
            if (temp > 215) {
                white_count++;
            }
        }
    }
    float result = white_count / 9.0;
    if (result >= white_down_limit && result <= white_up_limit) {
        //printf("Area is %4.2f\n",result);
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



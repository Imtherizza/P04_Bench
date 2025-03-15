#!/bin/bash

/usr/src/tensorrt/bin/trtexec --onnx=onnx/unet_v2.onnx --saveEngine=engines/unetv2_int8_gpu.engine --exportProfile=profiles/unetv2_int8_gpu.json --int8 --useSpinWait --separateProfileRun --inputIOFormats=int8:chw32 --outputIOFormats=int8:chw32 --memPoolSize=workspace:1 --verbose > logs/unetv2_int8_gpu.log 2>&1 ;

tail logs/unetv2_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/mobilenetv2.onnx --saveEngine=engines/mobilenetv2_int8_gpu.engine --exportProfile=profiles/mobilenetv2_int8_gpu.json --int8 --iterations=500 --warmUp=1000 --useSpinWait --separateProfileRun --inputIOFormats=int8:chw32 --verbose > logs/mobilenetv2_int8_gpu.log 2>&1 ;

tail logs/mobilenetv2_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/resnet50_v1_prepared.onnx --shapes=input_tensor:0:1x3x224x224 --useSpinWait --separateProfileRun --iterations=500 --warmUp=10000 --int8 --inputIOFormats=int8:chw32 --outputIOFormats=int8:chw32 --memPoolSize=workspace:1 --saveEngine=engines/resnet50v1prep_int8_gpu.engine --exportProfile=profiles/resnet50v1prep_int8_gpu.json --verbose > logs/resnet50v1prep_int8_gpu.log 2>&1 ;

tail logs/resnet50v1prep_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/mobilenetssd_v1_prepared.onnx --shapes=Preprocessor/sub:0:1x3x300x300 --saveEngine=engines/mobilenetssdv1prep_int8_gpu.engine --exportProfile=profiles/mobilenetssdv1prep_int8_gpu.json --int8 --useSpinWait --separateProfileRun --inputIOFormats=int8:chw32 --outputIOFormats=int8:chw32 --memPoolSize=workspace:1 --verbose > logs/mobilenetssdv1prep_int8_gpu.log 2>&1 ;

tail logs/mobilenetssdv1prep_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/resnet34ssd_v1_prepared.onnx --shapes=image:1x3x1200x1200 --useSpinWait --separateProfileRun --iterations=500 --warmUp=10000 --int8 --inputIOFormats=int8:chw32 --outputIOFormats=int8:chw32 --memPoolSize=workspace:1 --saveEngine=engines/resnet34ssdv1prep_int8_gpu.engine --exportProfile=profiles/resnet34ssdv1prep_int8_gpu.json --verbose > logs/resnet34ssdv1prep_int8_gpu.log 2>&1 ;

tail logs/resnet34ssdv1prep_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/inception_homemade3v2.onnx --saveEngine=engines/inceptionh3v2_int8_gpu.engine --exportProfile=profiles/inceptionh3v2_int8_gpu.json --int8 --useSpinWait --separateProfileRun --inputIOFormats=int8:chw32 --memPoolSize=workspace:1 --verbose > logs/inceptionh3v2_int8_gpu.log 2>&1 ;

tail logs/inceptionh3v2_int8_gpu.log ;

/usr/src/tensorrt/bin/trtexec --onnx=onnx/dlv3_v2.onnx --saveEngine=engines/dlv3_int8_gpu.engine --exportProfile=profiles/dlv3_int8_gpu.json --int8 --useSpinWait --separateProfileRun --inputIOFormats=int8:chw32 --outputIOFormats=int8:chw32 --verbose > logs/dlv3_int8_gpu.log 2>&1 ;

tail logs/dlv3_int8_gpu.log ;

#!/bin/bash

#  SealClass Build
#
#  Created by Sin on 19/3/28.
#  Copyright (c) 2019 RongCloud. All rights reserved.


CUR_PATH=`pwd`
BUILD_PATH=`pwd`
OUTPUT_PATH="${BUILD_PATH}/output"
BUILD_DIR="build"
configuration="Release"
BUILD_APP_PROFILE=""
BIN_DIR="bin"
VER_FLAG=${Version}
CUR_TIME=$(date +%Y%m%d%H%M)

#清空上次的临时编译，参数为目标目录
function clean_last_build(){
  path="./"
  rm -rf $path/bin
  rm -rf $path/bin_tmp
  rm -rf $path/framework
  rm -rf $path/DerivedData
  rm -rf $path/build
}

#拉取源码，参数 1 为 git 仓库目录,2 为 git 分支
function pull_sourcecode() {
  path=$1
  branch=$2
  cd ${path}
  git fetch
  git reset --hard
  git checkout ${branch}
  git pull origin ${branch}
}

function pod_update() {
	pod update --no-repo-update
}

#清空上次的编译输出
rm -rf $OUTPUT_PATH
clean_last_build

mkdir $OUTPUT_PATH

cd ${BUILD_PATH}
pull_sourcecode "./" "dev"

pod_update

#不同电脑上不同版本的 pod 执行 pod update 可能会修改 SealClass.xcodeproj/project.pbxproj 文件
#必须要重置 pod 对其修改，否则部分电脑运行项目可能会报错
git checkout -- SealClass.xcodeproj/project.pbxproj

#更新版本号
sed -i "" -e '/CFBundleShortVersionString/{n;s/[0-9]\.[0-9]\{1,2\}\.[0-9]\{1,2\}/'"$VER_FLAG"'/; }' ./SealClass/Info.plist
sed -i "" -e '/CFBundleVersion/{n;s/[0-9]*[0-9]/'"$CUR_TIME"'/; }' ./SealClass/Info.plist

PROJECT_NAME="SealClass.xcworkspace"
targetName="SealClass"
TARGET_DECIVE="iphoneos"

echo "***开始build iphoneos文件***"

xcodebuild -workspace "${PROJECT_NAME}" -scheme "${targetName}" archive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -configuration "${configuration}" APP_PROFILE="${BUILD_APP_PROFILE}" -allowProvisioningUpdates
xcodebuild -exportArchive -archivePath "./${BUILD_DIR}/${targetName}.xcarchive" -exportOptionsPlist "archive.plist" -exportPath "./${BIN_DIR}"
mv ./${BIN_DIR}/${targetName}.ipa ${CUR_PATH}/${BIN_DIR}/${targetName}_v${VER_FLAG}_${DEV_FLAG}_${BUILD_NUMBER}_${CUR_TIME}.ipa
cp -af ./${BUILD_DIR}/${targetName}.xcarchive/dSYMs/${targetName}.app.dSYM ${CUR_PATH}/${BIN_DIR}/${targetName}_${DEV_FLAG}_${CUR_TIME}.app.dSYM

echo "***编译结束***"

echo "***输出 ipa 与 dsym ***"
cp -af ${BIN_DIR}/*.ipa ${OUTPUT_PATH}/

cp -af ${BIN_DIR}/*.app.dSYM ${OUTPUT_PATH}/

zip -r $OUTPUT_PATH/SealClass_v${VER_FLAG}_${BUILD_NUMBER}_${CUR_TIME}.app.dSYM.zip $OUTPUT_PATH/*.app.dSYM
rm -rf $OUTPUT_PATH/*.app.dSYM


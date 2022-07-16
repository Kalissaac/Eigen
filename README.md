# Eigen

Matrix client for macOS. 100% native, no Electron bloat.

<img width="1012" alt="Eigen" src="https://user-images.githubusercontent.com/16791380/177373284-ee45c637-2ac5-4be3-97a3-c90e7ff3f2ef.png">

## Download
Head to [GitHub Actions](https://github.com/Kalissaac/Eigen/actions/workflows/ci.yml) and select the most recent build, scroll down, download, and unzip the artifact.

## Running locally
```sh
$ git clone https://github.com/Kalissaac/Eigen.git
$ cd Eigen
# install CocoaPods
$ pod install
# update developer settings, replacing with your Apple Developer Team ID and bundle ID
$ printf "DEVELOPMENT_TEAM = <your team id> \
         \nEIGEN_NAMESPACE = com.<your company (or anything)>.Eigen \
         \nCODE_SIGN_STYLE = Automatic" > Configs/LocalConfig.xcconfig
# open in Xcode
$ open Eigen.xcworkspace/
```
In Xcode, press run and it should launch!

#!/bin/sh
if [ "$1" = "" ] ; then
  PROFILE=exfe
else
  while getopts ":p:" optname; do
    case "$optname" in
      "p")
        PROFILE=$OPTARG
        ;;
      "?")
        echo "Unknown option $OPTARG"
        echo "Usage: Profile: $0 -p [exfe|0d0f|pilot]"
        exit 1
        ;;
      ":")
        if [ "$OPTARG" = "p" ]; then
          PROFILE=exfe
        else
          echo "No argument value for option $OPTARG"
        fi
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
  done
fi
# check param
if [ "$PROFILE" = "" ] ; then
  echo "Error: Missing params"
  echo "Usage: Profile: $0 -p [exfe|0d0f|pilot]"
  exit 1;
fi
# switch profile
if [ "$PROFILE" = "exfe" ]; then
  echo "Switch default profile exfe"
  PROJECT="EXFE"
  BUILD_ACTION="archive"
  SIGN=""
fi
if [ "$PROFILE" = "0d0f" ]; then
  echo "Switch profile 0d0f"
  PROJECT="0d0f"
  BUILD_ACTION="build"
  SIGN=""
fi
if [ "$PROFILE" = "pilot" ]; then
  echo "Switch profile pilot"
  PROJECT="Pilot"
  BUILD_ACTION="build"
  SIGN=""
fi

#check value
if [ "$PROJECT" = "" ] ; then
  echo "Error: Unknown Profile"
  echo "Usage: Profile: $0 -p [exfe|0d0f|pilot]"
  exit 1;
fi

EXFE_VER=m2B
for TEMP in $(expr $(date '+%y') - 10) $(expr $(date '+%m')) $(expr $(date '+%d'))
do
  if [ $TEMP -ge 10 ]
    then
      TEMP=$(printf \\$(printf '%03o' $(expr 55 + $TEMP)))
  fi
  EXFE_VER=$EXFE_VER$TEMP
done
/usr/libexec/PlistBuddy -c "Set :EXFE-build $EXFE_VER" EXFE/$PROJECT-Info.plist 

SCHEME=$PROJECT
PROJECT_FILE="$PROJECT.xcodeproj"
BUILD="xcodebuild"
BUILD_OUTPUT="build.output"
echo Cleaning $PROJECT
$BUILD -target $PROJECT -configuration Release -scheme $SCHEME clean > /dev/null
echo $BUILD_ACTION-ing $PROJECT
$BUILD -target $PROJECT -configuration Release -scheme $SCHEME $BUILD_ACTION > $BUILD_OUTPUT
APP_PATH=`cat $BUILD_OUTPUT|grep Validate|awk '{print $2}'`
BUILD_PATH=`pwd`"/builds/"
mkdir -p $BUILD_PATH
IPA_PATH="$BUILD_PATH$PROJECT.ipa"
echo Package $PROJECT
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$APP_PATH" -o "$IPA_PATH"
echo Cleaning Log $BUILD_OUTPUT
rm $BUILD_OUTPUT

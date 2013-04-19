#!/bin/sh
PROJECT="$1"
SERVER="0d0f.com"
EXT=".ipa"
IPA_PATH=`pwd`"/builds/$PROJECT$EXT"
SEED=$(date '+_%y%m%d')
BUILD=$PROJECT$SEED$EXT
if [ -f $build ]
then
    SEED=$(date '+_%y%m%d_%H%M%S')
    BUILD=$PROJECT$SEED$EXT
fi
echo $PROJECT $IPA_PATH $BUILD
chmod 666 $IPA_PATH
#scp $IPA_PATH $SERVER:/usr/local/www/exfeweb/static/img/
#scp $IPA_PATH $SERVER:/usr/home/stony/beta/iOS/$BUILD
scp $IPA_PATH $SERVER:/0d0f/app/ios
scp $IPA_PATH $SERVER:/0d0f/app/ios/$BUILD

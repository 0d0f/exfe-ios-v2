#!/bin/sh
PROJECT="$1"
SERVER="app.0d0f.com"
if [ -n "$EXFE_USER" ]
  then
    echo "if then"
    SERVER=$EXFE_USER"@"$SERVER
fi
EXT=".ipa"
IPA_PATH=`pwd`"/builds/$PROJECT$EXT"
SEED=$(date '+_%y%m%d_%H%M%S')
BUILD=$PROJECT$SEED$EXT
echo $PROJECT $IPA_PATH $SERVER:/0d0f/app/ios/$BUILD
chmod 666 $IPA_PATH
scp $IPA_PATH $SERVER:/0d0f/app/ios
scp $IPA_PATH $SERVER:/0d0f/app/ios/$BUILD

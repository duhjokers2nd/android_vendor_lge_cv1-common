#!/system/bin/sh

# path for dumpreports, quickdump

BUILD_ID=`getprop ro.build.id`
TIMESTAMP=`date +'%Y-%m-%d-%H-%M-%S'`
QUICKDUMP_FILE_NAME="quickdump-$TIMESTAMP"
#SHELL_FILE_PATH="/data/data/com.android.shell/files"
#QUICKDUMP_PATH="$SHELL_FILE_PATH/quickdump"
PATH_EXTERNAL_STORAGE=$EXTERNAL_STORAGE
QUICKDUMP_PATH="$PATH_EXTERNAL_STORAGE/quickdump"
QUICKDUMP_OUTPUT="$QUICKDUMP_PATH/$QUICKDUMP_FILE_NAME"

echo QUICKDUMP will save to $QUICKDUMP_OUTPUT.
log -p i -t QuickDump "QUICKDUMP will save to $QUICKDUMP_OUTPUT."

rm -rf "$QUICKDUMP_PATH"
log -p i -t QuickDump "rm -rf $QUICKDUMP_PATH, then mkdir again"

#if [ ! -e "$SHELL_FILE_PATH" ]; then
#    mkdir -p "$QUICKDUMP_PATH"
#    chmod -R 700 "$SHELL_FILE_PATH"
#    chown -R shell:shell "$SHELL_FILE_PATH"
#elif  [ ! -e "$QUICKDUMP_PATH" ]; then
if  [ ! -e "$QUICKDUMP_PATH" ]; then
    mkdir "$QUICKDUMP_PATH"
fi

# check path
if [ ! -e "$QUICKDUMP_PATH" ]; then
     am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_FAILED --receiver-permission android.permission.DUMP --ez fflag true
     echo "am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_FAILED --receiver-permission android.permission.DUMP  --ez fflag true"
     log -p i -t QuickDump "QUICKDUMP_FAILED, $QUICKDUMP_PATH is not exist."
     exit 0;
fi

# prevent media scanning
touch "$QUICKDUMP_PATH/.nomedia"

# run dumpstate
log -p i -t QuickDump "/system/bin/dumpstate -p -o $QUICKDUMP_OUTPUT"
/system/bin/dumpstate -p -o $QUICKDUMP_OUTPUT

#chmod -R 700 "$QUICKDUMP_PATH"
#chown -R shell:shell "$QUICKDUMP_PATH"

# broadcast finished intent
if [ -e "$QUICKDUMP_OUTPUT-$BUILD_ID-undated.txt" ]; then
    am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_COMPLETED --es path $QUICKDUMP_PATH  --receiver-permission android.permission.DUMP --ez fflag true
    echo am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_COMPLETED --es path $QUICKDUMP_PATH  --receiver-permission android.permission.DUMP --ez fflag true
    log -p i -t QuickDump "am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_COMPLETED --es path $QUICKDUMP_OUTPUT  --receiver-permission android.permission.DUMP --ez fflag true"
else
    am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_FAILED --receiver-permission android.permission.DUMP --ez fflag true
    echo "am broadcast --user 0 -a com.lge.android.quickdump.intent.QUICKDUMP_FAILED --receiver-permission android.permission.DUMP"  --ez fflag true
    log -p i -t QuickDump "QUICKDUMP_FAILED, $QUICKDUMP_OUTPUT.txt is not exist."
fi

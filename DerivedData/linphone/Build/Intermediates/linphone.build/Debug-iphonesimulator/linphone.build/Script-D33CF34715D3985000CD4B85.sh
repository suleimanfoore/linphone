#!/bin/sh
if [ "$CONFIGURATION" == "Debug" ]; then
    exit 0
fi

CONVERT=/opt/local/bin/convert
CONVERTFILTER="-sharpen 1x0.0 -filter Catrom"
OPTIPNG=/opt/local/bin/optipng
CMDS="${CONVERT} ${OPTIPNG}"
for i in $CMDS; do
command -v $i > /dev/null && continue || { echo "$i command not found"; exit 1; }
done

DIR=${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
PNGS=$(find $DIR -type f -name *.png)
for PNG in $PNGS; do
    BASENAME=$(basename $PNG ".png")
    PROCESS=true
    if [ -f $DIR/$BASENAME"@2x.png" ]; then
        echo "Ignoring $BASENAME";
        PROCESS=false
    fi
    case $BASENAME in *@2x)
        echo "Ignoring $BASENAME";
        continue
    esac

    if $PROCESS ; then
        echo "Processing ${BASENAME} (${CONVERTFILTER})..."
        mv $DIR/$BASENAME".png" $DIR/$BASENAME"@2x.png"
        $CONVERT $DIR/$BASENAME"@2x.png" $CONVERTFILTER -resize "50%" $DIR/$BASENAME".png" > /dev/null
    fi

    echo "Optimizing ${BASENAME} and ${BASENAME}@2x ..."
    $OPTIPNG -quiet $DIR/$BASENAME"@2x.png" > /dev/null
    $OPTIPNG -quiet $DIR/$BASENAME".png" > /dev/null

done

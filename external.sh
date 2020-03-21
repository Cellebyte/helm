
EXTERNAL_DIR=./external
CHARTS_DIR=./charts
for dir in $CHARTS_DIR/*/
do
    dir=${dir%*/}
    directory=${dir##*/}
    directory_version=`echo "${CHARTS_DIR}/${dir##*/}/version.txt"`
    echo "${directory_version}"
    if [ -f "$directory_version" ]; then
        echo "${directory}"
        echo "${directory_version}"
        VERSION=`cat "${directory_version}"`
        UNPREFIXED_VERSION=${VERSION}
        UNPREFIXED_VERSION=${UNPREFIXED_VERSION#"v"}
        git -C "${EXTERNAL_DIR}/${directory}" checkout "${VERSION}"
        bash "${CHARTS_DIR}/${directory}/setup.sh" "${CHARTS_DIR}" "${directory}" "${VERSION}" "${UNPREFIXED_VERSION}"
    fi
done

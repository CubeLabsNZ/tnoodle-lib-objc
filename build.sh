#!/usr/bin/env bash

set -ex
set -o pipefail

: "${J2OBJC_DIR:=j2objc}" "${TNOODLE_DIR:=tnoodle-lib}" "${BUILD:=build}" "${LIBTOOL:=libtool}" "${LIPO:=lipo}" "${OBJCFLAGS:=-Os}" "${TAR:=tar}"

J2OBJC="${J2OBJC_DIR}/j2objc"
J2OBJCC="${J2OBJC_DIR}/j2objcc"

IOS_ROOT="$(xcrun --sdk iphoneos --show-sdk-path)"
IOSSIM_ROOT="$(xcrun --sdk iphonesimulator --show-sdk-path)"
MACOSX_ROOT="$(xcrun --sdk macosx --show-sdk-path)"


SOURCE_PATHS="$(printf "${TNOODLE_DIR}/%s/src\n" {scrambles,sq12phase,min2phase,threephase,svglite} | paste -sd: - )"

find "${TNOODLE_DIR}"/{scrambles,sq12phase,min2phase,threephase,svglite}/src/main/java -type f -name '*.java' -print0 | \
	xargs -0 "$J2OBJC" --swift-friendly --doc-comments -sourcepath "$SOURCE_PATHS" -classpath "${J2OBJC_DIR}/lib/j2objc_junit.jar" -d "${BUILD}" 

ios_objs=()
mac_objs=()

while IFS= read -r -d '' line; do
	infile="${BUILD}/${line}"

	ios_obj="${BUILD}/ios/${line%.m}.o"
	ios_objs+=("$ios_obj")

	mac_obj="${BUILD}/mac/${line%.m}.o"
	mac_objs+=("$mac_obj")

	mkdir -p "$(dirname "$ios_obj")" "$(dirname "$mac_obj")"

	"$J2OBJCC" "-I${BUILD}" -c "$infile" -o "${ios_obj}-x86_64" -target x86_64-apple-ios-simulator -isysroot "$IOSSIM_ROOT" "$OBJCFLAGS"
	"$J2OBJCC" "-I${BUILD}" -c "$infile" -o "${ios_obj}-arm64" -target arm64-apple-ios -isysroot "$IOS_ROOT" -fembed-bitcode "$OBJCFLAGS"
	"$J2OBJCC" "-I${BUILD}" -c "$infile" -o "${ios_obj}-arm64e" -target arm64e-apple-ios -isysroot "$IOS_ROOT" -fembed-bitcode "$OBJCFLAGS"

	"$LIPO" -create "${ios_obj}-"{x86_64,arm64,arm64e} -output "$ios_obj"


	# J2ObjC libraries under the macosx folder are x86_64 only.
	"$J2OBJCC" "-I${BUILD}" -c "$infile" -o "${mac_obj}" -target x86_64-apple-macos10.12 -isysroot "$MACOSX_ROOT" "$OBJCFLAGS"

	
done < <(cd "${BUILD}" ; find . -type f -name '*.m' -print0)

libtool -static "${ios_objs[@]}" -o "${BUILD}/libtnoodle_ios.a"
libtool -static "${mac_objs[@]}" -o "${BUILD}/libtnoodle_mac.a"

pushd "${BUILD}" > /dev/null
find . -type f \( -name '*.h' -o -name '*.m' \) -print0 | xargs -0 tar czf source.tar.gz
find . -type f -name '*.h' -print0 | xargs -0 tar czf headers.tar.gz

#!/bin/bash

# Help
function show_help() {

cat << EOF
To-Do

For more information, please consult the README file or visit:
https://github.com/heliomass/iOS-Springboard-Spacer

EOF

}

while [ $# -gt 0 ]; do
	case "$1" in
		--dir-name)
			dir_name=$2
			shift 2
			;;
		--help)
			show_help
			shift
			exit 0
			;;
		*)
			echo "Unrecognised paramter ${1}. Please use the --help switch to see usage." >&2
			exit 1
			;;
	esac
done

if [ -z "$dir_name" ]; then
	echo 'Please supply the dir-name argument.' >&2
	exit 1
fi

# Check the directory exists
if [ ! -d "$dir_name" ]; then
	echo "Specified directory doesn't exist." >&2
	exit 1
fi

# Get the most recent file in the directory
for file in "$dir_name"/*; do
	break
done

# If no files are found, it's OK. Exit gracefully.
if [[ $file =~ '*' ]]; then
	echo 'No file to process.'
	exit 0
fi

# Use this file to generate the new homescreen icons
./springboard_spacer.sh \
	--file_name $file \
	--output_dir /Users/heliomass/Sites/springboard

# Send a success notification
if [ $? -eq 0 ]; then
	prowl 0 "Image Converter" "New background is ready."
else
	prowl 0 "Image Converter" "Was unable to convert image."
fi

# Delete the file in question
rm $file

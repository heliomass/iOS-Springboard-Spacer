#!/bin/bash

# Dependencies
function check_deps() {

	local __missing_dep=0

	if [ -z "$(which identify)" ]; then
		echo 'Missing "identify".' >&2
		__missing_dep=1
	fi
	if [ -z "$(which convert)" ]; then
		echo 'Missing "convert".' >&2
		__missing_dep=1
	fi

	return $__missing_dep

}

# Help
function show_help() {

cat << EOF
Usage:
	--file_name  - The PNG file containing a screenshot of your empty homescreen
	--output_dir - An empty directory in which to output the generated spacing icons

For more information, please consult the README file or visit:
https://github.com/heliomass/iOS-Springboard-Spacer

EOF

}

check_deps
if [ $? -ne 0 ]; then
	echo 'One or more dependencies are missing. Please ensure that ImageMagick is installed.'
	echo 'http://www.imagemagick.org/script/index.php'
	exit 1
fi

file_name=
output_dir=
while [ $# -gt 0 ]; do
	case "$1" in
		--file_name)
			file_name=$2
			shift 2
			;;
		--output_dir)
			output_dir=$2
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

if [ -z "$file_name" -o -z "$output_dir" ]; then
	echo 'Please supply both a --file_name and --output_dir switch.' >&2
	echo 'Use --help to view usage.' >&2
	exit 1
fi

if [ ! -d "$output_dir" ]; then
	echo "Output directory doesn't exist."
	exit 1
fi

# Deduce screensize and orientation
file_type=$(identify $file_name | awk '{print $2}')
file_dim=$(identify $file_name | awk '{print $3}')

if [ "$file_type" != 'PNG' ]; then
	echo 'Wrong file type. Please supply PNG.' >&2
	exit 1
fi

# Using the filesize as a guide, set up arrays containing all the icon positions.
case "$file_dim" in
	640x1136)
		echo 'iPhone 5/5S, iPod Touch 5G identified.'

		num_icons_x=4; # Number of columns
		num_icons_y=5; # Number of rows
		icon_dim=120;  # Icon size (width and height are the same)

		icons=( \
			'32+50'  '184+50'  '336+50'  '488+50'  \
			'32+226' '184+226' '336+226' '488+226' \
			'32+402' '184+402' '336+402' '488+402' \
			'32+578' '184+578' '336+578' '488+578' \
			'32+754' '184+754' '336+754' '488+754' \
		)

		;;
	*)
		echo 'Wrong screen dimensions. iPhone 5 and 5S supported only.' >&2
		exit 1
		;;
esac

# Produce the icons and associated HTML pages.
counter=0
while [ $counter -lt ${#icons[@]} ]; do
	echo -n '.'
	convert $file_name -crop "120x120+${icons[$counter]}" ${output_dir}/${counter}.png
	cat << EOF > ${output_dir}/${counter}.html
<html>
<head>
	<title>&#8290;</title>
	<link rel="apple-touch-icon" sizes="${icon_dim}x${icon_dim}" href="./${counter}.png" />
</head>
<body>
	<p>
		Add me to your homescreen.
	</p>
	<p>
		<img src="./${counter}.png" />
	</p>
	<p>
		<a href="./index.html">back</a>
	</p>
</body>
</html>
EOF
	let counter=counter+1
done
echo ' completed.'

# Produce the index page
cat << EOF > ${output_dir}/index.html
<html>
<head>
<title>Transparent Springboard Icons</title>
</head>
<body>
<h1>Transparent Springboard Icons</h1>
<p>Your icons are below.</p>
<table>
EOF

counter=0
for (( i=0; i<$num_icons_y; i++ )); do
	echo '<tr>' >> ${output_dir}/index.html
	for (( j=0; j<$num_icons_x; j++ )); do
		cat << EOF >> ${output_dir}/index.html
<td>
<a href="./${counter}.html">
<img src="./${counter}.png" />
</a>
</td>
EOF
	let counter=counter+1
	done
	echo '</tr>' >> ${output_dir}/index.html
done

cat << EOF >> ${output_dir}/index.html
</table>
</body>
</html>
EOF
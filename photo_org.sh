#!/usr/bin/env bash

# 2023-11-03
# Chris Maguire
#
# Use exiftool to get photo info
# Organize photos by date using photo info
# Name photos with date and camera model
#
# TODO:
#   - maybe keep screenshots somewhere else, or throw them away
#     - might be from Google Hangouts
#
#   - Seems like a lot of the "no model" "photos" are actually screenshots.
#     I should maybe put these in a different directory structure
#
# - get dates for PNG/JPG files from the accompanying JSON file
#   - e.g. /home/c/4tb/pics/goog_pics_2022/pics_2022/2022_chris_iphone_pics/Takeout/Google Photos/Photos from 2021/
#   - maybe copy the JSON file as well
#
# - Look for DateTimeOriginal before FileModifyDate (DSCN0245.JPG)
#
# - Save picasaoriginal photos
#
# - Fix this:
#    Copying IMG_2584.PNG from pics/goog_pics_2015/pics_2015/December 20, 2015/IMG_2584.PNG to pics3/2015/IMG/2584.PNG"/2015/IMG_2584.PNG"_______/2015/IMG_2584.PNG"_ 2015/IMG_2584.PNG"_ 2015/IMG_2584.PNG"_378307.PNGtouch: cannot touch 'pics3/2015/IMG/2584.PNG"/2015/IMG_2584.PNG"_______/2015/IMG_2584.PNG"_': No such file or directory
#    touch: cannot touch '2015/IMG_2584.PNG"_': No such file or directory
#    touch: cannot touch '2015/IMG_2584.PNG"_378307.PNG': No such file or directory

dir=${0%/*}

source "${dir}/photo_org_date.sh"
source "${dir}/photo_org_model.sh"
source "${dir}/photo_org_file_number.sh"
source "${dir}/photo_org_sequence_number.sh"
#source photo_org_file_size.sh
source "${dir}/photo_org_utility.sh"

function main {
  local out_dir=$1
  local photo_path=$2
  local photo_file=${photo_path##*/}
  local ext=${photo_file##*.}
  local exif=

  if [[ ${photo_file} =~ ^[.] ]] ; then
    echo "Filename (${photo_path}) starts with dot"
  fi

  # exif field variables
  local create_date=
  local model=
  local file_number=
  local sequence_number=

  local file_size=$(stat --format=%s "${photo_path}")

  exif_fields "${photo_path}"

  photo_date=$(echo ${create_date} | awk -F'[: -]' '{print $1 "_" $2 "_" $3 "_" $4 "_" $5 "_" $6}')
  photo_year=${photo_date%%_*}
  photo_month=${photo_date#*_}
  photo_month=${photo_month%%_*}
  photo_dir=${out_dir}/${photo_year}/${photo_month}
  maybe_model=${model}${model:+_}
  maybe_num=${file_number}${file_number:+_}
  maybe_seq=${sequence_number}${sequence_number:+_}
  photo_name="${photo_date}_${maybe_model}${maybe_num}${maybe_seq}${file_size}"

  # I'm keeping the extension off in case I want to disambiguate dupes with numbers,
  # e.g. _2, _3, _4
  out_path="${photo_dir}/${photo_name}"

  if [[ ! -d ${photo_dir} ]]; then
    mkdir -p ${photo_dir}
  fi

  if [[ -f "${out_path}.${ext}" ]] ; then
    echo "File ${out_path}.${ext} already exists (${photo_path})"
    # maybe keep checking until we find how many copies we have and add a number
    # for now we'll just skip it
  else
    echo -n "Copying ${photo_file} from ${photo_path} to ${out_path}.${ext}"

    # We don't actually have to copy the file to check if this works
    # We can just create an empty file
    #cp "${photo_path}" ${out_path}.${ext}
    touch ${out_path}.${ext}
  fi

  echo ""
}

function exif_fields {
  local photo_path=$@
  create_date ${photo_path}
  model ${photo_path}
  file_number ${photo_path}
  sequence_number ${photo_path}
}

function exif_field {
  declare -n var=$1
  exif_field_name=$2
  path=$3
  var=$(exiftool -json -${exif_field_name} "${path}" | jq --raw-output ".[0].${exif_field_name}")
}

if [[ $# -ne 2 ]] ; then
  echo -e "Called with $# args: $@"
  echo "Usage: photo_org.sh <out_dir> <file path>"
  exit 1
fi

out_dir=$1
photo_path=$2
main ${out_dir} "${photo_path}"

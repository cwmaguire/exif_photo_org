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
#   - I'm not sure these JSON files contain anything the EXIF info doesn't already have
#
# - Look for DateTimeOriginal before FileModifyDate (DSCN0245.JPG)
#
# - Save picasaoriginal photos

dir=${0%/*}

source "${dir}/photo_org_date.sh"
source "${dir}/photo_org_model.sh"
source "${dir}/photo_org_file_number.sh"
source "${dir}/photo_org_sequence_number.sh"
source "${dir}/photo_org_utility.sh"

function main {
  local out_dir=$1
  local photo_path=$2
  local photo_file=${photo_path##*/}
  local ext=${photo_file##*.}
  local exif=

  # exif field variables
  local create_date=
  local model=
  local file_number=
  local sequence_number=

  local file_size=$(stat --format=%s "${photo_path}")

  exif_fields "${photo_path}"

  photo_date_fields=($(echo ${create_date} | awk -F'[: -]' '{print $1, $2, $3, $4, $5, $6}'))
  photo_year=${photo_date_fields[0]:=0000}
  photo_month=${photo_date_fields[1]:=00}
  photo_day=${photo_date_fields[2]:=00}
  photo_hour=${photo_date_fields[3]:=00}
  photo_minute=${photo_date_fields[4]:=00}
  photo_second=${photo_date_fields[5]:=00}
  photo_date=${photo_year}_${photo_month}_${photo_day}_${photo_hour}_${photo_minute}_${photo_second}

  photo_dir=${out_dir}/${photo_year}/${photo_month}
  maybe_model=${model}${model:+_}
  maybe_num=${file_number}${file_number:+_}
  maybe_seq=${sequence_number}${sequence_number:+_}
  photo_name="${photo_date}_${maybe_model}${maybe_num}${maybe_seq}${file_size}"
  #photo_name="${photo_date}_${maybe_model}${file_size}"

  # I'm keeping the extension off in case I want to disambiguate dupes with numbers,
  # e.g. _2, _3, _4
  # For now I'm disambiguating with file sizes in the file name.
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
    #touch ${out_path}.${ext}

    cp "${photo_path}" ${out_path}.${ext}
  fi

  echo ""
}

function exif_fields {
  local photo_path=$@
  # these functions are in sourced scripts
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
  if [[ ${var} == "null" ]] ; then
    var=
  fi
  rtrim var
}

if [[ $# -ne 2 ]] ; then
  echo -e "Called with $# args: $@"
  echo "Usage: photo_org.sh <out_dir> <file path>"
  exit 1
fi

out_dir=$1
photo_path=$2
main ${out_dir} "${photo_path}"

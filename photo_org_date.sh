function create_date {
  local photo_path=$@
  exif_field create_date CreateDate "${photo_path}"

  # could use an until loop here

  if [[ -z ${create_date} ]] ; then
    exif_field create_date ModifyDate "${photo_path}"
  fi

  if [[ -z ${create_date} ]] ; then
    exif_field create_date DateCreated "${photo_path}"
  fi

  if [[ -z ${create_date} ]] ; then
    exif_field create_date FileModifyDate "${photo_path}"
  fi

  if [[ -z ${create_date} ]] ; then
    echo "Did not find date for ${photo_path}"
    exiftool -json -s "${photo_path}"
    # bail - we don't want to copy this file
    exit 1
  fi
}

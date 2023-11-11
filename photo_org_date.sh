function create_date {
  local photo_path=$@
  exif_field create_date CreateDate "${photo_path}"

  if [[ -z ${create_date} ]] ; then
    exif_field create_date ModifyDate "${photo_path}"

    #if [[ -n ${create_date} ]] ; then
      #echo "No CreateDate, got ModifyDate ${create_date}"
    #fi
  fi

  if [[ -z ${create_date} ]] ; then
    exif_field create_date DateCreated "${photo_path}"

    #if [[ -n ${create_date} ]] ; then
    #  echo "No CreateDate or ModifiedDate, got DateCreated ${create_date}"
    #fi
  fi

  if [[ -z ${create_date} ]] ; then
    exif_field create_date FileModifyDate "${photo_path}"

    #if [[ -n ${create_date} ]] ; then
      #echo "No CreateDate or ModifiedDate or DateCreated, got FileModifyDate ${create_date}"
    #fi
  fi

  if [[ -z ${create_date} ]] ; then
    echo "Did not find date for ${photo_path}"
    exiftool -json -s "${photo_path}"
    # bail - we don't want to copy this file
    exit 1
  fi
}

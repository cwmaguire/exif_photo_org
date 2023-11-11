function model {
  local photo_path=$@
  local comment=

  exif_field model Model "${photo_path}"
  if [[ ${model} ]] ; then
    first_n_words model 2
  fi

  if [[ -z ${model} ]] ; then
    if [[ ${lowercase_photo_path} =~ thumbnail ]] ; then
      model=thumbnail
    elif [[ ${lowercase_photo_path} =~ previews ]] ; then
      model=preview
    fi
  fi

  # Picasa and Facebook list themselves in Software
  # "Rim Exif Version1.00a" might mean "Dropbox"
  # Too bad it didn't record the original
  if [[ -z ${model} ]] ; then
    exif_field model Software "${photo_path}"
    # for "QuickTime 7.6.6"
    first_n_words model 1
  fi

  if [[ -z ${model} ]] ; then
    exif_field model LensModel "${photo_path}"
    # for "iPhone 5s ...", "iPod touch ..."
    first_n_words model 2
  fi

  if [[ -z ${model} ]] ; then
    local lowercase_photo_path=${photo_path,,}

    if [[ ${lowercase_photo_path} =~ webcam ]] ; then
      model=webcam
    elif [[ ${lowercase_photo_path} =~ iphone ]] ; then
      model=iPhone
    elif [[ ${lowercase_photo_path} =~ scan ]] ; then
      model=scanned
    elif [[ ${lowercase_photo_path} =~ z2 ]] ; then
      model=dImage_Z2
    elif [[ ${lowercase_photo_path} =~ argus ]] ; then
      model=argus
    elif [[ ${lowercase_photo_path} =~ /micro/ ]] ; then
      model=USB_microscope
    elif [[ ${lowercase_photo_path} =~ smugmug ]] ; then
      model=smugmug
    elif [[ ${lowercase_photo_path} =~ 'screen shot' ]] ; then
      model=screenshot
    fi
  fi

  if [[ -z ${model} ]] ; then
    exif_field comment Comment "${photo_path}"
    #echo "Comment for ${photo_path} is ${comment}"
    if [[ ${comment,,} =~ webcam ]] ; then
      model=webcam
    fi
  fi

  if [[ -z ${model} ]] ; then
    echo "Did not find model"
    exiftool -json -s "${photo_path}"
  fi

  model=${model/ /_}
}


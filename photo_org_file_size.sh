function file_size {
  local photo_path=${1}
  exif_field file_size FileSize "${photo_path}"
}

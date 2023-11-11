function file_number {
  local photo_path=$@
  exif_field file_number FileNumber "${photo_path}"
}

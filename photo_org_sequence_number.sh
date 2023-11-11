function sequence_number {
  local photo_path=$@
  exif_field sequence_number SequenceNumber "${photo_path}"
}

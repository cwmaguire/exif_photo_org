# exif_photo_org
Organize photos using EXIF info from exiftool

> NOTE: currently the files are not copied; a filename is created with
> touch to simulate what would happen for testing.

# Why BASH?

It hurts so good.
Also, it's built into many Linux distros.
Honestly, I don't really know.

## Main file:
- photo_org.sh

Currently I'm running it with this:
```
find pics \( -iname "*.jpg" -o -iname "*.heic" -o -iname "*.png" -o -iname "*.jpeg" \) -exec ./photo_org.sh pics3 "{}" \; | tee log2
```
## Function files:
- everything else

# Goal
Copy all photo files from one unorganized directory tree of files into
an organized tree of files with standard names using EXIF info.

# Implementation

## Organization
Files are organized by year and month according to the EXIF information
in this order:
1) `CreateDate`
2) `ModifyDate`
3) `DateCreated`
4) `FileModifyDate`
5) or the file is not copied

## Naming
Files are named D_M_N_Q_S.ext where
- D = yyyy_mm_dd_hh_MM_ss_
- M = model
- N = EXIF `FileNumber`
- Q = EXIF `SequenceNumber`
- ext = original file extension

### Model
Model comes from:
1) "thumbnail" if the filename contains "thumbnail"
2) "preview" if the filename contains "preview"
3) first word of EXIF `Software`, e.g. Picasa
4) first 2 words of `LensModel`, e.g. iPhone 5s
5) filename keywords:
    1) webcam      -> webcam
    2) iphone      -> iPhone
    3) scan        -> scanned
    4) z2          -> dImage_Z2
    5) argus       -> argus
    6) /micro/     -> USB_microscope
    7) smugmug     -> smugmug
    8) screen shot -> screenshot
6) "webcam" if the EXIF `Comment` contains "webcam"

# Notes to myself on BASH:
- wrap params to functions in double quotes
  - or capture all possible params in the function with `$@` / `$*`
- lowercase vars with `${var,,}`
- uppercase vars with `${var^^}`
- turn params into var references `declare -n var=$1`
- pipes are run in subshells, so piping to readarray assigns to a var in
  a subshell
- replace var chars with `${var/x/y}`
- get substrings or array slices with `${var:x}` or `${var:x:y}`
  - can use a var for `x` or `y`, e.g. `${var:${var2}:${var3}}`
- match in `if [[ ... ]]` with `=~`
  - note that quotes are not required
  - use a var for wonky stuff

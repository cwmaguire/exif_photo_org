# Get n words from a string
#
# Example usage:
#  input=$1
#  count=$2
#  separator=$3
#  get_words input $count $separator
#            ^
#            note the missing dollar sign; we're using nameref variable

function first_n_words {
  declare -n var=$1
  count=$2
  separator=${3:- }  # default to a space
  regex=

  for (( x=0 ; x < ${count} ; x+=1 )) ; do
    regex+="[[:alnum:]]+${separator}+"
  done

  while [[ ${var} =~ $regex ]] ; do
    var=${var%${separator}*}
  done

}

# Example usage:
#  input=$1
#  count=$2
#  separator=$3
#  get_words input $count $separator
#            ^
#            note the missing dollar sign; we're using nameref variable

function last_n_words {
  declare -n var=$1
  count=$2
  separator=${3:- }  # default to a space
  regex=

  for (( x=0 ; x < ${count} ; x+=1 )) ; do
    regex+="${separator}+[[:alpha:]]+"
  done

  while [[ ${var} =~ $regex ]] ; do
    var=${var#*${separator}}
  done

}

function rtrim {
  declare -n var_=$1

  var_=${var_%%  *} # trim multiple spaces
  var_=${var_% }    # trim single space
}

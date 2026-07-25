#!/usr/bin/env bash

if (( $# != 1 )); then
    >&2 echo "A markdown input file is required!"
    exit 1
fi

fullfile=$1
input=$(basename -- "$fullfile")
filename="${input%.*}"
output="${filename}.pdf"

pandoc ${input} -o ${output} \
  --pdf-engine=typst \
  --metadata-file=metadata.yaml \
  -V papersize=a4 \
  -V margin-top=2cm -V margin-bottom=2cm \
  -V margin-left=2.5cm -V margin-right=2.5cm \
  -V linkcolor=blue \
  --template=template.typ \
  --number-sections


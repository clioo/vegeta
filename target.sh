#!/bin/bash
# Params:
# -rate       Number of requests per time unit (default: 1/min)
# -duration   Duration of attack (default: 1min)
# -units      Units of rate and duration [m,s] (default: m for minutes)
# -desc       Description of attack, used for naming output files
# -target     Location of target file
# **************************************************
# Output:
# - YYYYMMDD_HHMM_desc.csv            CSV file with request details
# - YYYYMMDD_HHMM_desc-plot.html      HTML file with latency plot
# - YYYYMMDD_HHMM_desc-summary.json   JSON with summary of the attack

# **************************************************
# Examples:
# > Initial test 1 in 1 sec.
#   sh target.sh -target targets/dco-fastapi-local/hello.txt
# > 500 requests in 5 minutes (150/min), with description dco
#   sh target.sh -target targets/dco-fastapi-local/hello.txt -duration 5 -rate 100 -desc dco
# > 150 requests in one minute
#   sh target.sh -target targets/dco-fastapi-local/hello.txt -rate 150 -desc dco
# > Change units to seconds. 20 requests in 10 seconds (2 requests / second)
#   sh target.sh -target targets/dco-fastapi-local/hello.txt -units s -duration 10 -rate 2

RATE=1 
DURATION=1
DESC="attack"
UNITS="m"

while test $# -gt 0; do
  case "$1" in
    -rate)
      shift
      RATE=$1
      shift
      ;;
    -units)
      shift
      UNITS=$1
      shift
      ;;
    -duration)
      shift
      DURATION=$1
      shift
      ;;
    -desc)
      shift
      DESC=$1
      shift
      ;;
    -target)
      shift
      TARGET=$1
      shift
      ;;
    *)
      echo "$1 is not a recognized flag!"
      exit 1;
      ;;
    esac
  done


if [ -z ${TARGET+x} ] # if targer variable is not set
then
    echo "-target is required to specify the url we want to test."
    exit 1 # returns exit error (non 0 value exit)
fi

# making sure the directory exists
FILE="results/$(date +'%Y%m%d_%H%M')_$DESC"
# in case results folder doesn't existe, we create it
mkdir -p "${FILE%/*}" && touch "$FILE.csv"

# if only one request do it in one second (change units to seconds)
TOTAL=$(expr "$DURATION" '*' "$RATE")
if [[ "$TOTAL" -eq 1 ]]; then
  UNITS="s"
fi

TITLE="$TOTAL requests during $DURATION$UNITS from $TARGET ($RATE requests/$UNITS)"
echo "$TITLE\nFile: $FILE"

vegeta attack -timeout 60s -name="$DESC" -duration=$DURATION$UNITS -rate=$RATE/$UNITS -targets=$TARGET | \
      vegeta encode --to=csv > $FILE.csv && vegeta report $FILE.csv &&\
      vegeta report -type=json -output=$FILE-summary.json $FILE.csv &&\
      cat $FILE.csv | vegeta plot --title="$TITLE" > $FILE-plot.html

# Add headers to CSV
echo 'timestamp,http_code,latency_ns,bytes_out,bytes_in,error,body,attack_name,id' | cat - $FILE.csv > temp && mv temp $FILE.csv
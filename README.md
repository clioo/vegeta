# Vegeta attack for custom domains

This project aims to stress any kind web based project using [**Vegeta**](https://github.com/tsenart/vegeta).


## Install
The installation process from source in the official docs

### Target
A target is a file that contains the values of every HTTP request to be sent. You can find examples at **targets** directory

### MAC and Linux

    brew update && brew install vegeta

|Parameter|Required|Description |
|--|--|--|
|-rate| optional| Number of requests per time unit (default: 1/min |
|-duration|optional|Duration of attack (default: 1min)
|-units|optional|Units of rate and duration [m,s] (default: m for minutes)
|-desc|optional|Description of attack, used for naming output files
|-target|required|Location of target file




## Output
Every output will be saved in **results** folder with the datetime the attack was performed.

|File|Type|Description  |
|--|--|--|
|YYYYMMDD_HHMM_desc.csv| CSV | A file that contains every HTTP request details
|YYYYMMDD_HHMM_desc-plot.html| HTML | A file with latency plot
|YYYYMMDD_HHMM_desc-summary.json| JSON | JSON with summary of the attack


## Examples

### Initial test 1 in 1 sec.
    sh target.sh -target targets/dco-fastapi-local/hello.txt

### 500 requests in 5 minutes (150/min), with description dco
    sh target.sh -target targets/dco-fastapi-local/hello.txt -duration 5 -rate 100 -desc dco

### 150 requests in one minute

    sh target.sh -target targets/dco-fastapi-local/hello.txt -rate 150 -desc dco

### Change units to seconds. 20 requests in 10 seconds (2 requests / second)

    sh target.sh -target targets/dco-fastapi-local/hello.txt -units s -duration 10 -rate 2

## Official docs
https://github.com/tsenart/vegeta
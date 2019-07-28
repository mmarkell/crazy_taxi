# Solution Intro
Analyzing 80 + GB of spatial data is no easy task, especially when you do it locally. This solution relies on Postgres and PostGIS to store trips via longitude / latitude points and run optimized spatial queries. This solution also relies on Docker, so that if money were not a factor, it would be trivial to deploy the code on a more beastly server and get some actual useful data.

# Running the code
- `git clone `
- install docker
- download some of the trips dataset from http://www.andresmh.com/nyctaxitrips/ to `{git repo}/data/trip_data`. Docker is looking for data at data/trip_data/test.csv. If you want to add multiple csv files, simply add them next to test.csv in init-data.sql.
- Run `docker-compose down && docker-compose up`
- In the command line output, you should see a link to open Jupyter notebooks. Click it.
- If you have questions, comments, or want to give me money to host this on Azure or AWS, please let me know! :) 

# Questions:
## 1. Metrics
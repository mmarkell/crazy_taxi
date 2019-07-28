# Solution Intro
Analyzing 80 + GB of spatial data is no easy task, especially when you do it locally. This solution relies on Postgres and PostGIS to store trips via longitude / latitude points and run optimized spatial queries. This solution also relies on Docker, so that if money were not a factor, it would be trivial to deploy the code on a more beastly server and get some more detailed data.

# Running the code
- `git clone https://github.com/mmarkell/crazy_taxi.git`
- [install docker](https://www.docker.com/products/docker-desktop)
- download some of the trips dataset from http://www.andresmh.com/nyctaxitrips/ to `{git repo}/data/trip_data`. Docker is looking for data at data/trip_data/test.csv. If you want to add multiple csv files, simply add them next to test.csv in init-data.sql.
- `docker-compose down && docker volume rm uber_postgres_data && docker-compose up`. The first two commands are necessary if you already have it running, or if you want to load data into the db again.
- In the command line output, you should see a link to open Jupyter notebooks. Click it.
- If you have questions, comments, or want to give me money to host this on Azure or AWS, please let me know! :) 


# Seeing insights:
    In addition to answers below, I have also included a jupyter notebook with a sql client where you can run any queries or see visualizations as you wish. Follow the 'running the code' section above to use the jupyter notebook.

## 1. Metrics (Find some queries and visualization in the jupyter notebook)
1. The average trip length is about 11 minutes.
2. The average driver has around 5 trips per hour.
3. We can also glean information such as common pickup and dropoff locations and how those fluctuate throughout the day. For instance in New York, people take taxis towards downtown in the morning and out of the city at night. This is useful to know where to dispatch drivers or where to calculate surge pricing, for instance.
4. The most important metrics to care about are supply and demand. How does ridership demand fluctuate with date and time? Where should we have drivers wait for riders? From what pickup locations are rides most lucrative? How does driver utilization fluctuate with city area or time? 

## 2. Pickup matching
1. 60% of all rides can be matched to some other ride with distance = .2 miles and time = 5 minutes during rush hour. As distance narrows down to 100 meters and time to 3 minutes, it decreases to about 10%. This seems like a great compromise to me. Any further walking and it would be a bad user experience, but it is still a non-trivial portion of rides which will make the traffic burden significantly less.
2. I have graphed the distribution of share-able rides across the day in the Jupyter notebook, and there are two obvious spikes during rush hour. The optimal share-able cutoff fluctuates during the day to account for changes in supply, as we can be significantly more conservative with sharing during rush hour. 

## 3. Trip matching
1. Naively, we can simply do fuzzy matching on both pickup and dropoff locations, meaning if two rides start and end in approximately the same place and at approximately the same time, we should match them. We can also do this based off of euclidean distance and rectangles, matching rides where the pickup location of one ride is within the rectangle from another ride's pickup to dropoff location.

2. In a more expensive but more accurate design, we should query for the actual path between pickup and dropoff and match based on how much deviance from that path it would take to make a stop for a new shared rider. If an existing ride would have to take 1 extra minute to pickup a new shared rider, and another ride would have to take 2 extra minutes to pick the new shared rider up, we should choose the first existing ride. However, this gets more complicated if the first existing ride's destination was much further away from the new rider's destination. We need to choose based on minimizing the sum of all new driving that would have to happen if a rider is added.
## 4. Chaining
My computer isn't fast enough to do these calculations. But the way I would do it is with a modified Dijkstra's algorithm. I would first add a column to the table, "chain_factor", which indicates the longest incident chain of rides for that row, initialized to zero. Here is some pseudocode for the query:
```For curr_ride in sorted(rides):
        for other_ride in rides
            If other_ride.pickup = curr_ride.dropoff and !cycle(curr_ride, other_ride):
                other_ride.chain_factor = max(other_ride.chain_factor, curr_ride.chain_factor + 1)
```

We could detect cycles in several ways. We could add a table to the db with rides that have already been traversed. We could also keep track of rides using a bloom filter. By sorting the
rides first, this is basically a topologically sorted DAG. 
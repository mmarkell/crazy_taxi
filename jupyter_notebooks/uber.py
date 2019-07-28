import sys
import numpy
import matplotlib
import psycopg2

class taxidb():
    def __init__(self):
        self.database = 'postgres'
        self.username = 'postgres'
        self.password = 'password'
        self.hostname = 'postgis'
        self.connection = None

    def get_average_trip_length(self):
        query = """
            SELECT AVG (TRIP_TIME_IN_SECS)
            FROM TRIPS
        """
        result = self.executeQuery(query)
        return next(result)

    def get_shareable_ride_count_by_distance_and_time(self, distance, time, hour=None):
        query = """
            select count(*) from trips as t1
            join trips as t2
            on ST_DWithin(t1.pickup_geo, t2.pickup_geo, %s) 
            where 
            t1.pickup_longitude <> 0 
            and t1.Id > t2.Id
            and t1.medallion <> t2.medallion
            and t1.pickup_datetime - t2.pickup_datetime < interval '%s minutes'"""
        if hour is not None:
            query += (""" and date_part('hour', t1.pickup_datetime) = """ + hour)
        result = self.executeQuery(query % (distance, time))
        return next(result)

    def getConnection(self):
        return self.connection or psycopg2.connect(user = self.username,
            password = self.password,
            host = self.hostname,
            port = "5432",
            database = self.database)

    def getCursor(self):
        return self.getConnection().cursor()

    def closeConnection(self):
        self.getConnection().close()

    def executeQuery(self, query):
        cursor = self.getCursor()
        cursor.execute(query)
        row = cursor.fetchone()
        while row:
            yield row
            row = cursor.fetchone()
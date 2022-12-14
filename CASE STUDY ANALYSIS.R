library(tidyverse)
library(dplyr)
library(readr)
library(lubridate)  
library(ggplot2)
library(ggplot2)
library(scales)
library(hms)
getwd() 
setwd("/Users/ice50l/Downloads/CASE STUDY CSV FILES")


q08_2022 <- read_csv("202208-divvy-tripdata.csv")
q07_2022 <- read_csv("202207-divvy-tripdata.csv")
q06_2022 <- read_csv("202206-divvy-tripdata.csv")
q05_2022 <- read_csv("202205-divvy-tripdata.csv")
q04_2022 <- read_csv("202204-divvy-tripdata.csv")
q03_2022 <- read_csv("202203-divvy-tripdata.csv")
q02_2022 <- read_csv("202202-divvy-tripdata.csv")
q01_2022 <- read_csv("202201-divvy-tripdata.csv")
q12_2021 <- read_csv("202112-divvy-tripdata.csv")
q11_2021 <- read_csv("202111-divvy-tripdata.csv")
q10_2021 <- read_csv("202110-divvy-tripdata.csv")
q09_2021 <- read_csv("202109-divvy-tripdata.csv")
all_trips <- bind_rows(q08_2022, q07_2022, q06_2022, q05_2022, q04_2022, q03_2022, q02_2022, q01_2022, q12_2021, q11_2021, q10_2021, q09_2021)
all_trips$length_of_ride <- difftime(all_trips$ended_at,all_trips$started_at, unit = "mins")
all_trips <- all_trips %>%
  select(-c(start_lat, start_lng, end_lat, end_lng))

#Data cleanup/check
colnames(all_trips)
nrow(all_trips)
str(all_trips)
summary(all_trips)
unique(all_trips$member_casual)
table(all_trips$member_casual)

#Separating years, months, day, date
all_trips$date <- as.Date(all_trips$started_at) 
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")
View(all_trips)
all_trips$length_of_ride <- as.numeric(as.character(all_trips$length_of_ride))
is.numeric(all_trips$length_of_ride)

#Creating a new dataframe for values with no Null values
all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$length_of_ride<0),]
all_trips_v2 <- na.omit(all_trips_v2)
View(all_trips_v2)

#Summarizing the data
summary(all_trips_v2$length_of_ride)
aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual, FUN = min)
aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(length_of_ride)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)	
na.omit(all_trips_v2)

#Test2
all_trips_v2$Month_Name <- months(as.Date(all_trips_v2$date))

#Data visualization
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(length_of_ride)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge") + scale_y_continuous(labels = comma) +labs(y = "Number of rides", x = "Day of the week")
  
                              

#Visualizing average duration
all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(length_of_ride)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge") + labs(y = "Average Ride Duration in minutes", x = "Day of the week/Member type")

#Bike comparison for members/casuals
all_trips_v2 %>%
  group_by(rideable_type, member_casual)%>%
  summarise(number_of_rides = n())%>%
  ggplot(aes(x = rideable_type , y = number_of_rides, fill = member_casual)) +
  geom_col(position = 'dodge') + scale_y_continuous(labels = comma)  + labs(y = "Number of Rides", x = "Ride Type")

#Month and average ride time visual 
all_trips_v2 %>%
  group_by(Month_Name, member_casual) %>%
  summarise(average_duration = mean(length_of_ride))%>%
  ggplot(aes(x = Month_Name, y = average_duration, group = member_casual)) +  geom_line(aes(color = member_casual)) + labs(y = "Average Ride Duration", x = "Name of Month (2021-2022)") + scale_x_discrete(limits = month.name)

#Month and Number of rides
all_trips_v2 %>%
  group_by(Month_Name, member_casual) %>%
  summarise(number_of_rides = n()) %>%
  ggplot(aes(x = Month_Name, y = number_of_rides, group = member_casual)) +geom_line(aes(color = member_casual)) + labs(y = "Number of Rides" , x = "Month (Aug 2021 - September 2022)") +scale_y_continuous(labels = comma) + scale_x_discrete(limits = month.name)


#Exporting the data
counts <- aggregate(all_trips_v2$length_of_ride ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)
counts
testfile <- all_trips_v2
write.csv(testfile, file = '/Users/ice50l/Downloads/Case Study R csv/all_trips_v2.csv')



# Daylight saving time impact on web usage around the world

# Abstract
The daylight saving time (DST) has been debated more and more recently, bringing into discussion whether it should be abolished or not. While most of the countries do not observe daylight saving time, most of Europe and North America does, making it an important problem, especially for us Europeans.
We will analyze the impact that the DST has on several timezones related to the web usage. In this regard, we will use tweets to monitor the posting behaviour of Twitter users around the time of hour changes in different parts of the world. As the dataset provided on the cluster comprises only posts from the 16th June 2017, we are going to collect a dataset of our own for the two hour change periods, using the Twitter API.
We would like to see how the posting distribution transitions as the hour change occurs, in order to observe the users' behaviour change due to the hour change.

# Research questions
We would like to answer the following questions:
1. Does the hour change have an immediate effect on the tweets' distribution?
2. Does one of the hour changes (spring time or winter time) have a more drastic impact than the other?
3. Does the hour change affect people in different locations in different ways?
Other questions may follow if we identify interesting patterns in the data.

# Dataset
Given that the Twitter dataset provided consists only of posts from the 16th June, we will need to collect another dataset using the Twitter API.
The posts come in the format of a list of dictionary objects, each describing a published post or a deleted one. We will only monitor the published posts, which also provide the date the post was created (through the *created_at* tag) and the timezone of the user (in the *user/time_zone* field). The date and the timezone will constitute the main data that we are going to use in our analysis. The data will consist of posts in the range of about a week before and after the hour changes.
As an extension, we also consider making use of the Wikipedia dataset to enrich our observations.

# A list of internal milestones up until project milestone 2
Until milestone 2 we want to make the following steps:
1. Get acquainted with the Twitter API.
2. Download the posts needed.
3. Analyze the posts time distribution.
4. Look for additional interesting patterns.
5. Decide if we also need to use Wikipedia data to produce more observations.

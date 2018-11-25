# NLP on Amazon Reviews to Aid Customer’s Decision Process

## Abstract
A 150 word description of the project idea, goals, dataset used. What story you would like to tell and why? What's the motivation behind your project?

Popular Amazon products usually have thousands of reviews from various users explaining the pros/cons of the products along with a description of their personal opinion on the product. While this data may be useful to Amazon customers, often times these comments are time-consuming to sift through. Additionally, users may get more confused reading many positive and negative reviews and Amazon may lose a potential customer. In order to save users time when they are online shopping, we want to conduct a keyword analysis on these reviews by identifying positive and negative words to help a user quickly determine whether they may want this product. After summarizing, we plan on  creating a visualization for these reviews. The dataset used for this study comes from UCSD Julian McAuleys “Amazon product data” dataset.

## Research questions
A list of research questions you would like to address during the project. 

* Can we generate keywords from Amazon reviews through sentiment analysis?
* Can we use sentiment analysis to improve similar word search?

## Dataset
List the dataset(s) you want to use, and some ideas on how do you expect to get, manage, process and enrich it/them. Show us you've read the docs and some examples, and you've a clear idea on what to expect. Discuss data size and format if relevant.

List the dataset(s) you want to use, and some ideas on how do you expect to get, manage, process and enrich it/them. Show us you've read the docs and some examples, and you've a clear idea on what to expect. Discuss data size and format if relevant.

We would like to use the Amazon reviews dataset provided to us. We will be using the 5-core (9.9gb) subset of the data where the items/users have at least 5 reviews. The dataset contains 41.13 million reviews and filters out both users with multiple accounts and plagiarized reviews. 

Each JSON object contains the following data: reviewerID, asin, reviewerName, helpfulness, reviewText, overall, summary, unixReviewTime, and reviewTime

Here is an example below: 
![picture alt](https://github.com/sdhar3/ADA-Project/blob/master/example.png "example of one review")

Our intention is to conduct sentiment analysis on the data and the Amazon product data website recommends we use this data set specifically. 

We are going to take the review text from the file and the “overall” from each comment and anything above a “overall” of 3 will be labeled as positive and anything below will be labeled as negative. Then we will create a deep neural network to conduct sentiment analysis. We are going to run a couple noise reducing algorithms to clean up filler words and create higher accuracy within analysis. 

We also plan to do data visualization to see how related certain words are to each other. 

## A list of internal milestones up until project milestone 2
Add here a sketch of your planning for the next project milestone.

Tasks before November 11th:
* Clean the data and combine the datasets
* Run noise reduction methods remove filler words and improve the speed of the deep network

Tasks before November 18th:
* Write the code for the deep neural network create graph showing what words are indicative of positive review and what words are indicative of negative reviews.
* Look at graphs and create a method to find similar words.

Tasks before November 25th:
* Apply the model to find keywords for the reviews so that it become easier for future customers to get a better general idea of the reviews without have to read all of them.
* Visualize these keywords for some of the reviews that were given for particular items being sold on Amazon.


## Questions for TAa
Add here some questions you have for us, in general or project-specific.

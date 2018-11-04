# Towards healthy, tasty and durable recipes

# Abstract
The goal of the analysis is to determine what ingredients people like to eat and to discover their underlying combination/association rules (avoid combining mustard and chocolate together) to create new healthy recipes. Those rules would be discovered by using machine learning techniques on recipes dataset like the [Kaggle “whats cooking” dataset](https://www.kaggle.com/c/whats-cooking/data?fbclid=IwAR2RkMMWvBHJUirhgx-f5uB5ZVZ0XmlscS7OWJmuVZHUhDB9r2C8dLv4Bj4) amongst others. Note that tastes are not universal, and that the recipe origin might be considered to reach a better accuracy.
Once the rules are discovered, we study the nutritional facts of the ingredients and come up with healthy recipes satisfying them. A recipe is said to be healthy if it is nutritionally balanced and if it counts for roughly one third of the [reference daily intake (RDI)](https://en.wikipedia.org/wiki/Reference_Daily_Intake). The food nutritional facts would be retrieved from [websites](https://www.fda.gov/Food/ucm063367.htm) and from the [OpenFoodFact dataset](https://static.openfoodfacts.org/data/data-fields.txt).
Finally, the recipes would prefer local ingredients to reduce global CO2 emissions. The locality of an ingredient would be determined using the [countries import/export](https://www.indexmundi.com/trade/exports/?fbclid=IwAR3kwLE6OsmnoGuBRTFrlsmTsd94Xio8uGUCB7aw472rnmfpUnl2lI8GUvI).
Regarding social Impact, the nutrition balance would be an answer to junk food and malnutrition issues across the world, including diabetes and other potentially food-related diseases. Moreover, tastiness would ensure the adoption of the recipes and the actual impact of their creation.

# Research questions
The following questions need to be answered for the project to be fully achieved.

## How to infer rules about the ingredients combinations?
_First idea_: create a weighted directed graph with one node per ingredient and one link per cooccurrence of the ingredients in a recipe. Cluster the nodes to obtain sets of ingredients that go along well.
_Second idea_ : Apply an associative data mining algorithm, for instance [“Apriori”](https://en.wikipedia.org/wiki/Apriori_algorithm).

## How to combine ingredients to get a balanced nutritional intake?
_First Idea_ : Start from one, get the pool of ingredients satisfying the tastiness rules constraints and select the one having the less in common nutritionally speaking. Continue until the meal is balanced or until there are too many ingredients to add a new one.


# Dataset
This section enumerates the datasets we are using to do the analysis.

## Determine the rules for tastiness (recipes datasets)
- [Kaggle “whats cooking”](https://www.kaggle.com/c/whats-cooking/data?fbclid=IwAR2RkMMWvBHJUirhgx-f5uB5ZVZ0XmlscS7OWJmuVZHUhDB9r2C8dLv4Bj4) (2Mb) : perfect format, we can even exploit the test set. For each recipe (even those in test set) we keep track of the ingredients. No preprocessing seems to be needed, as quantities are not specified.
- [“From cookies to cook”](infolab.stanford.edu/~west1/from-cookies-to-cooks/) (2.5Gb zipped) : We can directly retrieve the ingredients, the size is big but should be ok.  Same idea than with the Kaggle dataset but we preprocess by removing duplicated recipes if any and by matching ingredients names with the ones given in the Kaggle dataset.

## Determine the healthiness of ingredients (nutritional facts datasets)
- [OpenFoodFact](https://world.openfoodfacts.org) (1.6Gb) : this dataset will be used to determine the nutritional facts of transformed products. We will not look for vegetables nor fruits or meats, but we would look for "Peanut butter" for instance. The fields are given in the abstract, the nutritional facts are complete enough to be used. An undetermined nutritional value for some field will be considered to be 0.
- [Nutrition Advance fruits facts](https://www.nutritionadvance.com/healthy-foods/types-of-fruit/) (Small) : Information for fruits, to be parsed
- [Nutrition Advance vegetable facts](https://www.nutritionadvance.com/healthy-foods/types-of-vegetables/) (Small) : information for vegetables, to be parsed
Other relevant websites

## Determine the local foods (import/export dataset)
- [Index Mundi imports/exports](https://www.indexmundi.com/trade/exports/?fbclid=IwAR3kwLE6OsmnoGuBRTFrlsmTsd94Xio8uGUCB7aw472rnmfpUnl2lI8GUvI) (medium) : should be parsed. For each country and each type of food, we look for the difference between exported and imported products. If a product is way more (to be defined) exported than imported, we consider it to be local. We will only look at raw products  (vegetables, fruits and meats), not at transformed products (peanut butter).

# A list of internal milestones up until project milestone 2
- Preprocessing of each dataset mentioned above. (format the datasets, deal with NaN values, ...)
- Prepare a pipeline to answer each subquestion that will be implemented between milestone 2 and 3.

# Questions for TA
- Do you think the size of the project is reasonable ?

import numpy as np
import pandas as pd
import json
import tqdm
import collections

def load_data(high_score):
    #read usda mapping
    if high_score :
        ing_mapping = json.load(open("./../generated/ing_usda_mapping_high_score.json"))
    else :
        ing_mapping = json.load(open("./../generated/ing_usda_mapping_low_score.json"))

    #read usda id description
    item_describe = json.load(open("./../generated/usda_id_describe.json"))

    #read cleaned recipes
    cleaned_kaggle_recipes = json.load(open("./../generated/clean_kaggle_recipes.json"))['recipe']
    cleaned_cookies_recipes = json.load(open("./../generated/clean_cookies_recipes.json"))['recipe']

    cleaned_kaggle_recipes  = [cleaned_kaggle_recipes[c]  for c in cleaned_kaggle_recipes]
    cleaned_cookies_recipes = [cleaned_cookies_recipes[c] for c in cleaned_cookies_recipes]

    #read ingredients count
    ingredients_count = json.load(open("./../generated/ingredients_count.json"))['count']
    
    return ing_mapping, item_describe, cleaned_kaggle_recipes, cleaned_cookies_recipes, ingredients_count

def main(high_score = True):
    
    ing_mapping, item_describe, cleaned_kaggle_recipes, cleaned_cookies_recipes, ingredients_count = load_data(high_score)
    
    #spot collisions
    mapped_ids = [ing_mapping[k] for k in ing_mapping]

    #build dict to store collisions
    collisions = {}

    for m in tqdm.tqdm(ing_mapping) :
        if ing_mapping[m] not in collisions.keys() :
            collisions[ing_mapping[m]] = [m]

        else :
            collisions[ing_mapping[m]].append(m)
            
    #Find representative name for each group
    item_number = 43
    proportion = 0.5

    representative_keys = dict()

    for i, c in tqdm.tqdm(enumerate(collisions)) :

        all_items = " ".join(collisions[c]).split(" ")
        counter = collections.Counter()
        counter.update(all_items)

        #find common names
        common_names = [x[0] for x in counter.most_common() if x[1] > len(collisions[c])*proportion]

        #choose database description
        if len(common_names) == 0 :
            representative_keys[c] = item_describe[str(c)]

        elif len(common_names) == 1 :
            representative_keys[c] = common_names[0]

        else :
            #determine order

            #case 1, there exist an entry with only wanted words
            exact_match = [x.split(" ") for x in collisions[c] if (len(set(common_names).difference(set(x.split(" "))))== 0)]
            if len(exact_match) != 0 :
                representative_keys[c] = " ".join(exact_match[0])

            #case 2, no exact match
            else :

                all_words_collisions = [x.split(" ") for x in collisions[c] if set(common_names).issubset(set(x.split(" ")))]

                index_tuples = [ (word, index) for collision in all_words_collisions for index, word in enumerate(collision) if (word in common_names)]

                index_counts = np.array([0]*len(common_names))

                #average the relative indices
                for it in index_tuples :
                    word_index = common_names.index(it[0])
                    index_counts[word_index] += it[1]

                index_counts = index_counts

                common_names_ordered = " ".join([common_names[i] for i in np.argsort(index_counts)])
                representative_keys[c] = common_names_ordered
                
    if high_score :
        json.dump(representative_keys, open("./../generated_test/high_score_key_representative.json" , 'w'))
    else :
        json.dump(representative_keys, open("./../generated_test/low_score_key_representative.json" , 'w'))

if __name__ == "__main__":
    main()
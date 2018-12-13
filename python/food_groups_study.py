import pandas as pd
import numpy as np
import tqdm
import json

def load_data():
    #recipes
    cleaned_recipes = json.load(open("./../generated/high_score_repr_recipes.json"))

    #mapping
    ing_mapping = json.load(open("./../generated/ing_usda_mapping_high_score.json"))

    #group description
    columns = ["food_group_id", "food_group_name"]
    food_groups = pd.read_csv("./../data/usda/FD_GROUP.txt", sep="^", encoding="ISO-8859-1", names=columns, header=None)

    #id mapping
    columns = ["food_id", "food_group_id"]
    use_cols = [0, 1]
    food_des = pd.read_csv("./../data/usda/FOOD_DES.txt", sep="^", encoding="ISO-8859-1", names=columns, usecols=use_cols, header=None)
    
    return cleaned_recipes, ing_mapping, food_groups, food_des

def recipe_to_ids(recipe) : return [int(ing[8:]) for ing in recipe if ing[:8] == 'usda_id=']

def ids_to_food_groups(ids) : return [ids_dict[i] for i in ids]

def food_groups_to_vector(food_groups) :
    count_vector = [0]*len(food_groups_index)
    for fg_id in food_groups :
        count_vector[food_groups_index.index(fg_id)] += 1

    return count_vector

def recipe_to_vector(recipe) : return food_groups_to_vector(ids_to_food_groups(recipe_to_ids(recipe)))

def main():
    cleaned_recipes, ing_mapping, food_groups, food_des = load_data()
    
    # Create food groups dictionaries
    
    #useful ids
    usda_ids = [ing_mapping[ing]for ing in ing_mapping]

    #matching ids dict
    ids_dict = dict()
    for usda_id in usda_ids :
        matching_group = int(food_des[food_des["food_id"] == usda_id]['food_group_id'].values[0])
        ids_dict[usda_id] = matching_group

    json.dump(ids_dict, open("./../generated/food_to_group_high_score.json", 'w'))

    #food groups description ids
    group_des = dict()
    for entry in food_groups.values :
        group_des[entry[0]] = entry[1]

    json.dump(group_des, open("./../generated/group_des.json", 'w'))
    
    
if __name__ == "__main__":
    main()
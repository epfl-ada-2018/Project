import numpy as np
import pandas as pd

def main():
    data_path = '../generated/'
    cookies_recipes = pd.read_json(data_path + 'clean_cookies_recipes.json')
    kaggle_recipes = pd.read_json(data_path + 'clean_kaggle_recipes.json')
    
    cookies_recipes = cookies_recipes[['id', 'title', 'recipe']]
    kaggle_recipes = kaggle_recipes[['id', 'recipe']]
    
    all_recipes = pd.concat([cookies_recipes, kaggle_recipes], sort=False)
    
    df_recipe = all_recipes['recipe'].apply(pd.Series).stack().to_frame().reset_index()
    df_recipe = df_recipe[0].to_frame()
    df_recipe = df_recipe.rename({0:'ingredient'}, axis=1)
    
    count_table = df_recipe['ingredient'].value_counts().to_frame().rename({'ingredient':'count'}, axis = 1)

    without_junk = count_table[count_table['count'] > 4]
    without_junk.to_json("../generated/ingredients_count.json")
    count_table.to_json("../generated/ingredients_count_all.json")
    
if __name__ == "__main__":
    main()
import pandas as pd
import numpy as np
import tqdm
import json
import networkx as nx
import collections

def name_ingredients(recipe, repr_per_id) :
    
    named_ingredients = []
    
    for r in recipe :
        if r[:8] == "usda_id=" :
            named_ingredients.append(repr_per_id[r[8:]])
            
        else :
            named_ingredients.append(r)
            
    return named_ingredients
            

def ingredients_tuples(recipe) :
    
    tuples = []
    for ing1 in range(len(recipe) - 1) :
        for ing2 in range(ing1 + 1, len(recipe)) :
            if recipe[ing1] < recipe[ing2] :
                tuples.append((recipe[ing1], recipe[ing2]))
                
    return tuples

def nb_connections(from_ing, to_ing) :
    try :
        return ing_graph[from_ing][to_ing]['weight']
    except :
        return 0
    
def nb_asso(ing, ing_graph) :
    return sum([ing_graph[ing][c]['weight'] for c in ing_graph[ing]])
    
def nb_outgoing_edges(ing) :
    try :
        return ing_graph.degree[ing]
    except :
        return 0
    
def max_association(ing) :
    return max([ing_graph[ing][c]['weight'] for c in ing_graph[ing]])

def friendship(ing1, ing2, nb_assos) :
    ing1_likes_ing2 = (nb_connections(ing1, ing2) / nb_assos[ing1])
    ing2_likes_ing1 = (nb_connections(ing2, ing1) / nb_assos[ing2])
    friendship     =  max(ing1_likes_ing2, ing2_likes_ing1)
    return friendship


def recipe_compatibility(ingredient, recipe) :
    if ingredient in recipe : 
        return 0    
    else :         
        return sum([friendship(ingredient, ing) for ing in recipe]) / len(recipe)

def main():
    #Load data
    cleaned_recipes = json.load(open("./../generated/high_score_repr_recipes.json"))
    repr_per_id = json.load(open("./../generated/high_score_key_representative.json"))
    
    # Create graph
    cleaned_name_recipes = [name_ingredients(r, repr_per_id) for r in cleaned_recipes]
    
    asso_counter = collections.Counter()
    for recipe in tqdm.tqdm(cleaned_recipes) :
            asso_counter.update(ingredients_tuples(name_ingredients(recipe, repr_per_id)))
            
    ing_graph = nx.Graph()

    for item in asso_counter.most_common() :
        ing_graph.add_edge(item[0][0],item[0][1],weight=item[1])
        
    #compute number of associations dictionnary
    nb_assos = dict()
    for ing in ing_graph.nodes(): 
        nb_assos[ing] = nb_asso(ing, ing_graph)
        
    #save compatibilities
    compatibilities = dict()
    for ing1 in tqdm.tqdm(ing_graph.nodes()) :    
        per_ing = dict()

        for ing2 in ing_graph.nodes() :
            per_ing[ing2] = friendship(ing1, ing2, nb_assos)

        compatibilities[ing1] = per_ing

    json.dump(compatibilities, open("./../generated/high_score_ing_friendship.json", 'w'))
    
    
if __name__ == "__main__":
    main()   
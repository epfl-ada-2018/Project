import numpy as np
import json

unit_quantities = [('garlic clove', (3, 'g')),
 ('egg yolk', (17, 'g')),
 ('egg white', (33, 'g')),
 ('red onion', (110, 'g')),
 ('green onion', (110, 'g')),
 ('red bell pepper', (100, 'g')),
 ('bay leaf', (0.5, 'g')),
 ('boneles skinles chicken breast', (300, 'g')),
 ('yellow onion', (110, 'g')),
 ('egg', (50, 'g')),
 ('chicken breast', (250, 'g')),
 ('onion', (110, 'g')),
 ('green bell pepper', (100, 'g')),
 ('green pepper', (15, 'g')),
 ('boneles skinles chicken breast half', (150, 'g')),
 ('sweet potato', (170, 'g')),
 ('cinnamon stick', (5, 'g')),
 ('white onion', (110, 'g')),
 ('red pepper', (15, 'g')),
 ('celery rib', (40, 'g')),
 ('jalapeno pepper', (14, 'g')),
 ('vanilla bean', (5, 'g')),
 ('sweet onion', (110, 'g')),
 ('flour tortilla', (34, 'g')),
 ('baking potato', (170, 'g')),
 ('pork chop', (150, 'g')),
 ('russet potato', (170, 'g')),
 ('bell pepper', (100, 'g')),
 ('plum tomato', (170, 'g')),
 ('whole clove', (3, 'g')),
 ('red potato', (170, 'g')),
 ('whole chicken', (2267, 'g')),
 ('yellow bell pepper', (100, 'g')),
 ('boneles chicken breast', (300, 'g')),
 ('chicken thigh', (85, 'g')),
 ('corn tortilla', (34, 'g')),
 ('minced garlic clove', (3, 'g')),
 ('chicken bouillon cube', (5, 'g')),
 ('fennel bulb', (235, 'g')),
 ('butternut squash', (500, 'g')),
 ('rom tomato', (170, 'g')),
 ('ice cube', (28, 'g')),
 ('carrot', (72, 'g')),
 ('whole chicken breast', (300, 'g')),
 ('Spanish onion', (0, 'g')),
 ('potato', (170, 'g')),
 ('tomato', (170, 'g')),
 ('Granny Smith apple', (150, 'g')),
 ('apple', (150, 'g')),
 ('chicken breast half', (150, 'g'))]

def main():
    #create dictionnary
    unit_quantities_dict = dict()
    for ing in unit_quantities :
        unit_quantities_dict[ing[0]] = ing[1]

    json.dump(unit_quantities, open("../generated/1m_unit_quantities.json", 'w'))

if __name__ == "__main__":
    main()
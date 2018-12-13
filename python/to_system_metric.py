import numpy as np
import json

convert_ml = {"bushel":  35239.1,
              "cup": 236.588,
              "dash": 0.92,
              "drop": 0.05,
              "fl.": 29.5735,
              "oz": 29.5735,
              "gallon": 3785.41,
              "glass": 236.588,
              "kg": 1000,
              "liter": 1000,
              "ounce": 29.5735,
              "c.": 236.588,
              "pinch": 0.31,
              "pint": 500,
              "pound": 453.5924,
              "lb": 453.5924,
              "quart": 946.353,
              "scoop": 0.15,
              "shot": 44.3603,
              "tablespoon": 15,
              "teaspoon": 5,
              "tsp": 5,
              "tbsp": 15
            }

convert_gr = {"bushel": 35239.0704,
              "cup": 128,
              "dash": 0.72,
              "drop": 0.05,
              "fl.": 28,
              "oz": 28,
              "gallon": 3753.46,
              "glass": 147,
              "kg": 1000,
              "liter": 1000,
              "ounce": 28,
              "c.": 128,
              "pinch": 0.36,
              "pint": 450,
              "pound": 453.592,
              "lb": 453.592,
              "quart": 946.352946,
              "scoop": 29,
              "shot": 29.57,
              "tablespoon": 14.3,
              "teaspoon": 4.2,
              "tsp": 4.2,
              "tbsp": 14.3
            }

def main():
    json.dump(convert_ml, open("../generated/convert_ml.json", 'w'))
    json.dump(convert_gr, open("../generated/convert_gr.json", 'w'))

if __name__ == "__main__":
    main()
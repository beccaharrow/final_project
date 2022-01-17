import json 
with open('X_people.json') as file: 
    x = json.load(file)

new_x = []
for dictionary in x:
     keys = dictionary.keys()
     if 'ontology/weight' in keys: 
         new_x.append(dictionary)

with open('new_x.json', 'w') as saving: 
    json.dump(new_x, saving)

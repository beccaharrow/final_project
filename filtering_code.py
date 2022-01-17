import json 

filtered_data = []
file_names = ['A_people.json', 'B_people.json', 'C_people.json', 'D_people.json', 'E_people.json', 'F_people.json', 'G_people.json', 'H_people.json', 'I_people.json', 'J_people.json', 'K_people.json', 'L_people.json', 'M_people.json', 'N_people.json', 'O_people.json', 'P_people.json', 'Q_people.json', 'R_people.json', 'S_people.json', 'T_people.json', 'U_people.json', 'V_people.json', 'W_people.json', 'X_people.json', 'Y_people.json', 'Z_people.json']
for file_name in file_names:
    with open(file_name) as file:
        current_data = json.load(file)
    for dictionary in current_data:
        new_entry = {}
        keys = dictionary.keys()
        if 'ontology/weight' in keys and 'ontology/height' in keys and 'athlete' in dictionary['http://www.w3.org/1999/02/22-rdf-syntax-ns#type_label']:
            new_entry['weight'] = dictionary['ontology/weight']
            new_entry['height'] = dictionary['ontology/height']
            filtered_data.append(new_entry)

with open('filtered_data.csv', 'a') as file:
    file.write('Weight, Height\n')
    for entry in filtered_data:
        file.write(f"{entry['weight']},{entry['height']}\n")

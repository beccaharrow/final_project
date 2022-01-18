import json 

filtered_data = []
file_names = ['A_people.json', 'B_people.json', 'C_people.json', 'D_people.json', 'E_people.json', 'F_people.json', 'G_people.json', 'H_people.json', 'I_people.json', 'J_people.json', 'K_people.json', 'L_people.json', 'M_people.json', 'N_people.json', 'O_people.json', 'P_people.json', 'Q_people.json', 'R_people.json', 'S_people.json', 'T_people.json', 'U_people.json', 'V_people.json', 'W_people.json', 'X_people.json', 'Y_people.json', 'Z_people.json']
sport_types = {'basketball player', 'swimmer', 'badminton player', 'baseball player', 'softball player', 'handball player', 'volleyball player', 'boxer', 'horse rider', 'soccer player', 'golf player', 'martial artist', 'cyclist', 'rugby player', 'table tennis player', 'tennis player', 'wrestler', 'archer', 'fencer', 'diver', 'hockey player', 'rower', 'sailor', 'skateboarder', 'shooter', 'water polo player', 'biathlete', 'triathlete', 'pentathlete', 'kayaker', 'canoer', 'bmx rider', 'rock climber', 'surfer', 'weightlifter'}
for file_name in file_names:
    with open(file_name) as file:
        current_data = json.load(file)
    for dictionary in current_data:
        new_entry = {}
        keys = dictionary.keys()
        if 'ontology/weight' in keys and isinstance(dictionary['ontology/weight'], str) == True and 'ontology/height' in keys and 'athlete' in dictionary['http://www.w3.org/1999/02/22-rdf-syntax-ns#type_label']:
            new_entry['weight'] = float(dictionary['ontology/weight'])/1000
            new_entry['height'] = dictionary['ontology/height']
            labels = set(dictionary['http://www.w3.org/1999/02/22-rdf-syntax-ns#type_label'])
            new_entry['sport'] = labels.intersection(sport_types)
            if len(new_entry['sport']) == 0: 
                for sport in sport_types: 
                    if sport in dictionary['title']: 
                        new_entry['sport'] = {sport}
                    elif "http://purl.org/dc/elements/1.1/description" in keys and sport in dictionary['http://purl.org/dc/elements/1.1/description']:
                        new_entry['sport'] = {sport}
            if len(new_entry['sport']) == 0: 
                new_entry['sport'] = {'other'}
            filtered_data.append(new_entry)

with open('filtered_data2.csv', 'a') as file:
    file.write('Weight, Height, Type of Sportsman\n')
    for entry in filtered_data:
        file.write(f"{entry['weight']},{entry['height']}, {entry['sport']}\n")

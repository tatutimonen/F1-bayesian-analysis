import pandas as pd
import numpy as np
import math
import re
from datetime import timedelta

quali_df = pd.read_csv('../../data/qualifying.csv')
drivers_df = pd.read_csv('../../data/drivers.csv')
drivers_df['dob'] = pd.to_datetime(drivers_df['dob'])
races_df = pd.read_csv('../../data/races.csv')

quali_differences_df = pd.DataFrame(columns=['driverId', 'forename', 'surname', 'difference', 'teammateId', 'teammateName','age', 'year', 'circuit'])

invalid_count = 0
not_1_count = 0
null_count = 0
for index, row in quali_df.iterrows():
    race_id = row['raceId']
    constructor_id = row['constructorId']
    driver_id = row['driverId']
    teammate = quali_df[(quali_df['raceId'] == race_id) & (quali_df['constructorId'] == constructor_id) & (quali_df['driverId'] != driver_id)]
    if len(teammate) == 1:
        q = ''
        if (row['q3'] != '\\N' and teammate['q3'].item() != '\\N') and not (isinstance(row['q3'], float) or isinstance(teammate['q3'].item(), float)):
            q = 'q3'
        elif (row['q2'] != '\\N' and teammate['q2'].item() != '\\N') and not (isinstance(row['q2'], float) or isinstance(teammate['q2'].item(), float)):
            q = 'q2'
        elif (row['q1'] != '\\N' and teammate['q1'].item() != '\\N') and not (isinstance(row['q1'], float) or isinstance(teammate['q1'].item(), float)):
            q = 'q1'
        else:
            null_count +=1
        if q != '':
            quali_time_regex = re.match(r"(?P<m>[0-9]+):(?P<s>[0-9]+).(?P<ms>[0-9]+)", row[q])
            quali_time_sec = timedelta(minutes=float(quali_time_regex['m']),seconds=float(quali_time_regex['s']),milliseconds=float(quali_time_regex['ms'])).total_seconds()
            teammate_time_regex = re.match(r"(?P<m>[0-9]+):(?P<s>[0-9]+).(?P<ms>[0-9]+)", teammate[q].item())
            teammate_time_sec = timedelta(minutes=float(teammate_time_regex['m']),seconds=float(teammate_time_regex['s']),milliseconds=float(teammate_time_regex['ms'])).total_seconds()
            
            #Try calculating with respect to pole time
            difference = quali_time_sec - teammate_time_sec
            
            teammate_id = teammate['driverId'].item()
            teammate_name = drivers_df[drivers_df['driverId'] == teammate_id]['driverRef'].item()
            
            forename = drivers_df[drivers_df['driverId'] == driver_id]['forename'].item()
            surname = drivers_df[drivers_df['driverId'] == driver_id]['surname'].item()
            year = races_df[races_df['raceId'] == race_id]['year'].item()
            age = year-drivers_df[drivers_df['driverId'] == driver_id]['dob'].item().year
            circuit = races_df[races_df['raceId'] == race_id]['name'].item()
            quali_differences_df = quali_differences_df.append(pd.DataFrame([[driver_id, forename, surname, difference, teammate_id, teammate_name, age, year, circuit]], columns=['driverId', 'forename', 'surname', 'difference', 'teammateId', 'teammateName','age', 'year', 'circuit']))
            #quali_differences_df = quali_differences_df.append(pd.DataFrame([[difference, age]], columns=['difference', 'age']))
            #print('asd')
        else:
            invalid_count += 1
    else:
        not_1_count +=1

quali_differences_df.reset_index(drop=True, inplace=True)
quali_diff_copy = quali_differences_df.copy()
quali_differences_df = quali_differences_df[(quali_differences_df['difference'] > -2.5) & (quali_differences_df['difference'] <2.5)]
driver_means = quali_differences_df.groupby('driverId').mean()

for index, row in quali_differences_df.iterrows():
    driver_id = row['driverId']
    # driver id is the index in driver_means
    driver_mean = driver_means[driver_means.index == driver_id]['difference'].item()
    quali_differences_df.at[index, 'difference'] -= driver_mean

quali_differences_df.to_csv('../../data/quali_differences_processed123.csv',index=False)
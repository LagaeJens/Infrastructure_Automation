import csv

# Specify the delimiter as a semicolon
delimiter = ';'

with open('Infrastructure_Automation/Python/Week_2/Voorbeeld_1.csv', 'r') as csvfile:
    csv_reader = csv.reader(csvfile, delimiter=delimiter)

    for row in csv_reader:
        # Process each row here
        print(row)

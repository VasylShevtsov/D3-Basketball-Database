from faker import Faker
import random

# Instantiate a Faker object
fake = Faker()

# Function to generate synthetic player data
def generate_players_data(number_of_players):
    players_data = []
    for _ in range(number_of_players):
        players_data.append({
            'PlayerID': fake.unique.random_int(min=1, max=9999),
            'TeamID': fake.random_int(min=1, max=100),  # Assuming 100 teams
            'FirstName': fake.first_name(),
            'LastName': fake.last_name(),
            'Position': random.choice(['Guard', 'Forward', 'Center']),  # Simplified positions
            'HeightInches': random.randint(65, 85),  # Heights in inches
            'Weight': random.randint(150, 250),  # Weight in pounds
            'HighSchool': fake.company()  # Using company names as high school names
        })
    return players_data

# Number of players to generate
num_of_players = 100

# Generate the player data
players_data = generate_players_data(num_of_players)

# Output to a SQL file
with open('player_data.sql', 'w') as f:
    for player in players_data:
        f.write(f"INSERT INTO Player (PlayerID, TeamID, FirstName, LastName, Position, HeightInches, Weight, HighSchool) "
                f"VALUES ({player['PlayerID']}, {player['TeamID']}, '{player['FirstName']}', '{player['LastName']}', "
                f"'{player['Position']}', {player['HeightInches']}, {player['Weight']}, '{player['HighSchool']}');\n")
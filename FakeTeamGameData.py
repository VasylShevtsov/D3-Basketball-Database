from faker import Faker
from datetime import timedelta, datetime
import random

fake = Faker()

# generate a list of dictionaries containing team data
def generate_teams_data(number_of_teams):
    teams_data = []
    for i in range(number_of_teams):
        team_data = {
            'TeamID': i + 1,
            'TeamName': fake.company(),
            'Location': fake.city()
        }
        teams_data.append(team_data)
    return teams_data


num_of_teams = 50
teams = generate_teams_data(num_of_teams)
team_ids = [team['TeamID'] for team in teams]

with open('teams_data.sql', 'w') as f:
    for team in teams:
        f.write(f"INSERT INTO Team (TeamID, TeamName, Location) VALUES ({team['TeamID']}, '{team['TeamName']}', '{team['Location']}');\n")

# Function to generate synthetic player data
def generate_players_data(number_of_players, team_ids):
    players_data = []
    for _ in range(number_of_players):
        players_data.append({
            'PlayerID': fake.unique.random_int(min=1, max=9999),
            'TeamID': random.choice(team_ids), 
            'FirstName': fake.first_name(),
            'LastName': fake.last_name(),
            'Position': random.choice(['Guard', 'Forward', 'Center']),
            'HeightInches': random.randint(65, 85),  # Heights in inches
            'Weight': random.randint(150, 250),  # Weight in pounds
            'HighSchool': fake.company()
        })
    return players_data

num_of_players = 100
players_data = generate_players_data(num_of_players, team_ids)

# Output to a SQL file
with open('player_data.sql', 'w') as f:
    for player in players_data:
        f.write(f"INSERT INTO Player (PlayerID, TeamID, FirstName, LastName, Position, HeightInches, Weight, HighSchool) "
                f"VALUES ({player['PlayerID']}, {player['TeamID']}, '{player['FirstName']}', '{player['LastName']}', "
                f"'{player['Position']}', {player['HeightInches']}, {player['Weight']}, '{player['HighSchool']}');\n")


# Function to generate unique game pairings
def generate_unique_game_pairings(team_ids, number_of_games):
    games_data = []
    
    for _ in range(number_of_games):
        home_team = random.choice(team_ids)
        away_team = home_team
        while away_team == home_team:
            away_team = random.choice(team_ids)
        
        game_date = fake.date_between(start_date='-2y', end_date='today')
        # home_score = random.randint(50, 150)
        # away_score = random.randint(50, 150)

        game_data = {
            'HomeTeamID': home_team,
            'AwayTeamID': away_team,
            'GameDate': game_date,
        }
        
        games_data.append(game_data)
    
    return games_data

# Generate synthetic games data
number_of_games = 100  # Number of games you want to generate
games = generate_unique_game_pairings(team_ids, number_of_games)

# Output to a SQL file
with open('games_data.sql', 'w') as f:
    game_id = 1  # Starting game ID
    for game in games:
        f.write(f"INSERT INTO Game (GameID, HomeTeamID, AwayTeamID, Date) VALUES ({game_id}, {game['HomeTeamID']}, {game['AwayTeamID']}, '{game['GameDate']}');\n")
        game_id += 1


def generate_team_game_statistics(games_data):
    statistics_data = []
    for game in games_data:
        # For each game, create a statistic for the home team and the away team.
        for team_id in [game['HomeTeamID'], game['AwayTeamID']]:
            # Assign 'Home' or 'Away' based on whether the team is the home or away team.
            home_or_away = 'Home' if team_id == game['HomeTeamID'] else 'Away'
            
            # Generate random statistics within a typical range for a basketball game.
            field_goals_made = random.randint(20, 45)
            three_pointers_made = random.randint(5, 20)
            free_throws_made = random.randint(5, 30)
            total_points = field_goals_made * 2 + three_pointers_made * 3 + free_throws_made
            
            # Create a dictionary of statistics for the team.
            team_game_statistic = {
                'TeamID': team_id,
                'GameID': game['GameID'],
                'HomeOrAway': home_or_away,
                'FreeThrowsMade': free_throws_made,
                'FieldGoals': field_goals_made,
                'FieldGoalsAttempted': field_goals_made + random.randint(20, 40),  # Assumes a certain number of missed shots
                'ThreePointersMade': three_pointers_made,
                'ThreePointersAttempted': three_pointers_made + random.randint(10, 25),
                'FreeThrowsAttempted': free_throws_made + random.randint(5, 15),
                'PersonalFouls': random.randint(5, 20),
                'OffensiveRebounds': random.randint(5, 15),
                'DefensiveRebounds': random.randint(10, 25),
                'Assists': random.randint(10, 30),
                'Steals': random.randint(3, 12),
                'Blocks': random.randint(2, 10),
                'Turnovers': random.randint(5, 20),
                'TotalPoints': total_points,
            }
            statistics_data.append(team_game_statistic)
    return statistics_data

team_game_statistics = generate_team_game_statistics(games)

# Output to a SQL file
with open('team_game_statistics_data.sql', 'w') as f:
    for statistic in team_game_statistics:
        f.write(f"INSERT INTO TeamGameStatistic (TeamID, GameID, HomeOrAway, FreeThrowsMade, FieldGoals, FieldGoalsAttempted, ThreePointersMade, ThreePointersAttempted, FreeThrowsAttempted, PersonalFouls, OffensiveRebounds, DefensiveRebounds, Assists, Steals, Blocks, Turnovers, TotalPoints) VALUES ({statistic['TeamID']}, {statistic['GameID']}, '{statistic['HomeOrAway']}', {statistic['FreeThrowsMade']}, {statistic['FieldGoals']}, {statistic['FieldGoalsAttempted']}, {statistic['ThreePointersMade']}, {statistic['ThreePointersAttempted']}, {statistic['FreeThrowsAttempted']}, {statistic['PersonalFouls']}, {statistic['OffensiveRebounds']}, {statistic['DefensiveRebounds']}, {statistic['Assists']}, {statistic['Steals']}, {statistic['Blocks']}, {statistic['Turnovers']}, {statistic['TotalPoints']});\n")


require 'sinatra'
require 'pry'
require 'csv'

def read_csv(filename)
  data = []
  CSV.foreach(filename, headers:true, converters: :numeric) do |row|
    data << row.to_hash
  end
data
end

def find_team_and_record(data)
teams = []
winners = []
losers = []
win_count = Hash.new{0}
lose_count = Hash.new{0}
  data.each do |game|
    teams << game["home_team"]
    teams << game["away_team"]
    teams.uniq!
      if game["home_score"] > game["away_score"]
        winners << game["home_team"]
        losers << game["away_team"]
      end
        if game["away_score"] > game["home_score"]
          winners << game["away_team"]
          losers << game["home_team"]
        end
    end
  winners.each do |team|
    win_count[team] += 1
  end
  losers.each do |team|
    lose_count[team] += 1
  end
  teams.each do |team|
    unless winners.include?(team)
      win_count[team] = 0
    end
    unless losers.include?(team)
      lose_count[team] = 0
    end
  end
team_record = lose_count.reduce(win_count.dup){|h,(k,v)| h[k] = (h[k] && [h[k], v] || v); h}
end


def team_history(data,team)
team_games = []
  data.each do |game|
    if team == game["home_team"] || team == game["away_team"]
      team_games << game
    end
  end
team_games
end

def team_win_and_loss(team,league_history)
  season_stats = []
  league_history.each do |fb_team, record|
    if team == fb_team
      season_stats << record
    end
  end
season_stats
end


before do
@scoreboard = read_csv('football.csv')
end


get '/' do
@team_record = find_team_and_record(@scoreboard)
erb :index
end

get '/leaderboard' do
@team_record = find_team_and_record(@scoreboard)
erb :index
end

get '/teams/:team' do
@team_record = find_team_and_record(@scoreboard)
team = params[:team]
@team_games = team_history(@scoreboard, team)
@season_stats = team_win_and_loss(team,@team_record)
erb :show
end


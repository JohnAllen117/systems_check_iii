# Bundler Gems
require 'rubygems'
require 'bundler/setup'
# Normal Gems
require 'sinatra'
require 'pg'
require 'pry'
require 'sinatra/reloader'

def db_connection
  begin
    connection = PG.connect(dbname: 'recipes')

    yield(connection)

  ensure
    connection.close
  end
end

def recipe_list
  db_connection do |conn|
    conn.exec('SELECT name, id FROM recipes ORDER BY name ASC')
  end
end

def get_recipe_using_id(recipe_id)
  sql = 'SELECT recipes.name, recipes.description,
  recipes.instructions FROM recipes WHERE recipes.id = $1'
  result = db_connection do |conn|
    conn.exec(sql, [recipe_id])
  end

  result.first
end

def get_ingredients_list(recipe_id)
  db_connection do |conn|
    conn.exec('SELECT ingredients.name FROM ingredients
      WHERE ingredients.recipe_id = $1', [recipe_id])
  end
end

get '/' do
  erb :index
end

get '/recipes' do
  @recipe_names = recipe_list
  erb :recipes
end

get '/recipes/:id' do
  @recipe_id = params[:id]
  @recipe_info = get_recipe_using_id(@recipe_id)
  @ingredients_list = get_ingredients_list(@recipe_id)
  erb :show
end

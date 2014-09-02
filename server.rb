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
def get_recipe_list
  db_connection do |conn|
    conn.exec('SELECT name, id FROM recipes ORDER BY name ASC')
  end
end

def get_recipe_using_id recipe_id
  db_connection do |conn|
    conn.exec("SELECT recipes.name, recipes.description, recipes.instructions FROM recipes WHERE recipes.id = $1",
      [recipe_id])
  end
end

def get_ingredients_list recipe_id
  db_connection do |conn|
    conn.exec("SELECT ingredients.name FROM ingredients WHERE ingredients.recipe_id = $1", [recipe_id])
  end
end

get '/' do
  erb :index
end

get '/recipes' do
  @recipe_names =  get_recipe_list
  @recipe_names = @recipe_names.to_a

  erb :recipes
end

get '/recipes/:id' do
  @recipe_id = params[:id]
  @recipe_info = get_recipe_using_id(@recipe_id).to_a.first
  @ingredients_list = get_ingredients_list(@recipe_id).to_a  erb :show
end






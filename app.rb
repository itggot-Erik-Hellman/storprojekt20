require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

db = SQLite3::Database.new("db/workflow.db")
db.results_as_hash = true

get ('/') do
    slim(:start)
end

post ('/users/create') do
    email = params[:email]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (email, password_digest) VALUES (?,?)",email,password_digest)
    redirect('/')
end

post ('/users/login') do
    result = db.execute("SELECT id, password_digest FROM users WHERE email=?", params[:email])

    if(BCrypt::Password.new(result.first["password_digest"]) == params[:password])
        session[:user_id] = result.first["id"]
        redirect('/main_page')
    else    
        redirect('/')
    end
end

get ('/main_page') do
    slim(:main_page)
    db.execute("SELECT category_name FROM category")
end

get ('/logo') do
    redirect('/main_page')
end

post ('/new') do
    id = params[:id]
    category_name = params[:category_name]
    db = SQLite3::Database.new("db/workflow.db") 
    create = db.execute("INSERT INTO category (id, category_name) VALUES (?,?)",id,category_name)
    redirect('/main_page')
end

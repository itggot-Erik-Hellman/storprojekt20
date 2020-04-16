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
    db.results_as_hash = true
    destination = db.execute("SELECT * FROM category")
    slim(:main_page, locals:{destination:destination})
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

post ('/delete/:id') do
    id = params[:id]
    db = SQLite3::Database.new("db/workflow.db") 
    db.execute("DELETE FROM category WHERE id=?",id.to_i)
    redirect('/main_page')
end

post ('/update/:id') do
    id = params[:id]
    category_name = params[:category_name]
    db = SQLite3::Database.new("db/workflow.db")
    db.execute("UPDATE category SET category_name=? WHERE id=?", category_name,id.to_i)
    redirect('/main_page')
end
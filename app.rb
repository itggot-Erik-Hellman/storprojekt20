require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get ('/') do
    slim(:start)
end

post ('/users/create') do
    email = params[:email]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/workflow.db")
    db.execute("INSERT INTO users (email, password_digest) VALUES (?,?)",email,password_digest)
    redirect('/')
end

post ('/users/login') do
    email = params[:email]
    password = params[:password]
    password_check = db.execute("SELECT password_digest FROM users WHERE email = ?", email)
    user_id = db.execute("SELECT id FROM users WHERE email = ?", email)

end
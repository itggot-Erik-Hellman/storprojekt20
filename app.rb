require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
#Hämtar in sinatra, slim, SQL, och bcrypt
enable :sessions
#Enablar sessions med sinatra
db = SQLite3::Database.new("db/workflow.db")
db.results_as_hash = true

get ('/error') do
    session[:error]
end

get ('/') do #Gör så att informationen som visas i routen '/' är från slim filen "index.slim"
    slim(:index)
end

post ('/users') do #Routen '/users' lägger till ett email samt ett lösenord som crypteras av bcrypt. Http-metoden är post eftersom man ändrar på något, i detta fall databasen där man lägger till email och password
    email = params[:email]
    password = params[:password]
    password_digest = BCrypt::Password.create(password) #crypterar det lösenord användaren skrev in i hemsidan
    db.execute("INSERT INTO users (email, password_digest) VALUES (?,?)",email,password_digest) #lägger in det email och lösenord användaren har skrivit in till table: "users" attribut: "email" och "password_digest"
    redirect('/') #dirigerar om användaren tillbaka till startsidan efter att den har gjort sitt konto
end

post ('/login') do #Routen '/login' Kollar om det användaren har skrivit in i email och lösenord stämmer översäns med det som finns i databasen "authentication". Om det gör det kommer användaren in till hemsidan: '/main_page' om inte så redigeras han tillbaka till startsidan
    db.results_as_hash = true
    result = db.execute("SELECT id, password_digest FROM users WHERE email=?", params[:email])

    if(BCrypt::Password.new(result.first["password_digest"]) == params[:password])
        session[:user_id] = result.first["id"]
        redirect('/main_page')
    else    
        session[:error] = "Wrong email or password"
        redirect('/error')
    end
end

get ('/main_page') do #routen '/main_page' är min första get http-metod. Detta då '/main_page' bara ska visa information.
    db.results_as_hash = true
    destination = db.execute("SELECT * FROM category")
    slim(:main_page, locals:{destination:destination}) #Gör så att informationen inuti '/main_page' är från slim filen "main_page.slim" samt skickar med destination
end

get ('/logo') do #visar min logo samt när man trycker på den så redigeras man till '/main_page'
    redirect('/main_page')
end

post ('/new') do #Skapar en ny category_name vilket är vart man har åkt
    id = params[:id]
    category_name = params[:category_name]
    db = SQLite3::Database.new("db/workflow.db") 
    create = db.execute("INSERT INTO category (id, category_name) VALUES (?,?)",id,category_name) #Lägger in det man har skrivit in i table:category och attributerna "id" och "category_name"
    redirect('/main_page')
end

post ('/delete/:id') do #Tar bort en hel rad i tabellen:category. Använder mig även av en dynamisk route för att inte behöve skriva samma kod för varje rad i category
    id = params[:id]
    db = SQLite3::Database.new("db/workflow.db") 
    result = db.execute('SELECT rank FROM users WHERE id=?', session[:user_id])[0][0].to_i #kollar vilken rank kontot har och beroende på om den är admin (rank:1) eller inte så kan man deleta eller så får man ett error medelande
    if result == 1
    db.execute("DELETE FROM category WHERE id=?",id.to_i) #tar bort från tabellen category beroende på vilket id man tillkallar
    redirect('/main_page')
    else
        session[:error] = "ERROR NO ADMIN 101"
        redirect('/error')
    end
end

post ('/update/:id') do #updaterar category_name i tabellen category
    id = params[:id]
    category_name = params[:category_name]
    db = SQLite3::Database.new("db/workflow.db")
    db.execute("UPDATE category SET category_name=? WHERE id=?", category_name,id.to_i) #updaterar informationen i category_name beroende på vad användaren har skrivit (kan ändra Tyskland till tex Finland eller vad som helst)
    redirect('/main_page')
end

get ('/profile') do
    slim(:profile)
end

post ('/name/:id') do
    id = params[:id]
    email = params[:email]
    db = SQLite3::Database.new("db/workflow.db")
    db.execute("UPDATE users SET email=? WHERE id=?", email,id.to_i)
    redirect('/profile')
end
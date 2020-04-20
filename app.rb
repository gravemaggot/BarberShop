#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def is_barber_exists? db, name
    db.execute('select * from barbers where name=?', [name]).length > 0
end

def seed_db db, barbers

    barbers.each do |barber|
        if !is_barber_exists? db, barber 
            db.execute "INSERT INTO barbers (name) VALUES ( ? )", [barber]
        end
    end

end

def get_db
    db = SQLite3::Database.new('./public/barbershop.db')
    db.results_as_hash = true

    return db
end

configure do
    get_db.execute(
        "CREATE TABLE IF NOT EXISTS 'users' (
            'id' INTEGER PRIMARY KEY AUTOINCREMENT,
            'username' TEXT,
            'phone' TEXT,
            'datestamp' TEXT,                              
            'barber' TEXT,
            'color' TEXT
    );")

    get_db.execute(
        "CREATE TABLE IF NOT EXISTS 'barbers' (
            'id' INTEGER PRIMARY KEY AUTOINCREMENT,
            'name' TEXT);")

    seed_db get_db, ['Walter White', 'Jessie Pinkman', 'Gus Fring', 'Adelina', 'Lina'];

end

get '/' do
	erb "Hello, Vovanus! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do

    @barbersSelect = ""

    @results = get_db.execute 'select name from barbers order by id'         

    erb :visit
    
end

get '/contacts' do
	erb :contacts
end

get '/showusers' do
    
    @results = get_db.execute "select username,phone,datestamp,barber,color from users order by id desc" 

    erb(:showusers)

end

post '/visit' do

    @username  = params[:username]; 
    @phone     = params[:phone];
	@datetime  = params[:datetime];
    @master    = params[:master];
    @color     = params[:color];

    @title     = 'Thanks you!';
    @message   = "Dear #{@user_name}, we'll be waiting for you at #{@datetime}. Master: #{@master}. Color: #{@color}";

    # Проверка заполнения
    errPattern = {
        :username   => 'Введите имя',
        :phone      => 'Укажите телефон',
        :datetime   => 'Не правильная дата визита'
    };

    @error = errPattern.select {|key,_| params[key] == ''}.values.join(", "); 

    if @error != '' 
        return erb(:visit)
    end;

    # Запись в файл
    if writeDatabase(@username,@phone,@datetime,@master,@color) 
        erb(:message)
    else
        @error = 'Ошибка записи. Попробуйте еще раз.';
        erb(:visit)
    end

end


def writeDatabase(username, phone, datestamp, barber, color)

    queryText = "INSERT INTO users (username,phone,datestamp,barber,color) VALUES ( ? , ? , ? , ? , ? )";
    get_db.execute(queryText, [username, phone, datestamp, barber, color]);

    true;

end

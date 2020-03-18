#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
	erb "Hello, Vovanus! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/visit' do

    @username  = params[:username]; 
    @phone     = params[:phone];
	@datetime  = params[:datetime];
    @master    = params[:master];
    @color     = params[:color];

    @title     = 'Thanks you!';
    @message   = "Dear #{@user_name}, we'll be waiting for you at #{@date_time}. Master: #{@master}. Color: #{@color}";

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

def writeDatabase(username,phone,datetime,master,color)

    require 'sqlite3'

    query = SQLite3::Database.new('./public/barbershop.db');

    queryText = "INSERT INTO visits (username,phone,datetime,master,color) " + 
                "VALUES ('#{username}','#{phone}','#{datetime}','#{master}','#{color}');";
    query.execute(queryText);

    return true;

end
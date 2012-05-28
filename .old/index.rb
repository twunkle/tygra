require 'rubygems' # в 1.9 Ruby уже не надо, но для пакетов
require 'sinatra' # подключили сам фрэймворк
require 'sinatra/reloader' # класс для автоматической перегрузки сервера приложений при внесении изменений
require Dir.pwd + '/classes/twitter.rb' # наш класс для парсинга сообщений из Твиттера
require Dir.pwd + '/classes/imagebar.rb' # наш класс для рисования текста на изображении
require 'ostruct' # класс для приведения yaml конфигов в структуры ruby
require 'yaml' # для чтения yaml конфига

set :env,  :production # устанавливаем переменную окружения

configure do  # блок конфигурации, вызывается при старте приложения
  set :root, File.dirname(__FILE__)
    enable :static # чтобы работала отдача статичных файлоф из папки publc
      enable :logging # логгирование
        enable :dump_errors # для дампа ошибок
          disable :sessions # а вот сессии нам не нужны
          end
          
          get '/' do # наш первый роутинг для главной страницы
            response['Cache-Control'] = "public, max-age=#{5*60*10}" # заголовок для кэширования страницы
              erb :index # покажем наш уже готовый шаблон views/index.html.erb внутри стандартного layout
              end # этот роутинг просто отрисовывает интерфейс для пользователя
              
              get '/twit/:theme/:user.gif' do # второй роутинг, на запрос отрисовывания картинки
                theme_dir = Dir.pwd + '/themes/' # наши настройки к ТЕМИЗАЦИИ картинки
		user_name = params[:user] # получаем из адресной строки имя пользователя
                    theme     = params[:theme] # получаем название ТЕМЫ для картинки тоже из адреса
                    
                      # наши обработчики разных ошибок, что показать и сказать если чего-то нет  
                        halt [ 404, "Page not found" ]           unless user_name
                          halt [ 500, "Sorry wrong theme" ]        unless theme
                            halt [ 404, "Can't find themes file" ]   unless FileTest.exists? theme_dir + theme + '.yml'
                              halt [ 404, "Can not found background" ] unless FileTest.exists? theme_dir + theme + '.gif'
                                
                                  # читаем yaml файл конфигурации темы и преобразовываем в ruby объект
                                    conf = OpenStruct.new( YAML.load_file theme_dir + theme + '.yml' )
                                      
                                        # получаем данные последнего твита пользователя
                                          twit = Twitter.get_last_post user_name
                                          
                                            # выдаём заголовки для кэширования картинки, например на 2 минуты
                                              response['Cache-Control'] = "public, max-age=#{60*2}"
                                                content_type 'image/gif' # теперь mime тип контента, что хотим отдать
                                                  ImageBar.draw theme_dir, theme, twit, conf # рисуем текст на картинке и отдаём в браузер
                                                  end

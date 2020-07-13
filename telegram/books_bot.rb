require File.expand_path('../config/environment', __dir__)
require 'openssl'
require 'telegram/bot'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

token = '1212341741:AAE7QeQfJu1CGhlXSFDYB35EXTvrqG1DnUM'
Telegram::Bot::Client.run(token) do |bot|

  

  bot.listen do |message|

    case message.text


      when '/show_book' 
        bot.api.send_message(chat_id: message.chat.id, text: "Send me book's id")
        bot.listen do |message|
          puts message.text
          book = Book.find_by_id(message.text)
          if book.nil?
            bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
          else
            bot.api.send_message(chat_id: message.chat.id, 
            text: "#{STATUS['success']}\nLoaded book:\nId: #{book['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}", date: message.date)
          end
        end
      


      when '/delete_book'
        bot.api.send_message(chat_id: message.chat.id, text: "Send me book's id to delete")
        bot.listen do |message|
          puts message.text
          book = Book.find_by_id(message.text)
          if book.nil?
            bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
          else
            book.destroy
            bot.api.send_message(chat_id: message.chat.id, 
            text: "#{STATUS['success']}\nDeleted book:\nId: #{book['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}", date: message.date)
          end
        end


      when '/mark_as_read'
        bot.api.send_message(chat_id: message.chat.id, text: "Send me book's id to mark as read")
        bot.listen do |message|
          puts message.text
          book = Book.find_by_id(message.text)
          if book.nil?
            bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
          else
            book.update(:status => 'true')
            bot.api.send_message(chat_id: message.chat.id, 
            text: "#{STATUS['success']}\nLoaded book:\nId: #{book ['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}", date: message.date)
          end
        end



      when '/show_all_books'
         bot.api.send_message(chat_id: message.chat.id,
         text: "Enter which books you want to see:\nall - all books\ntrue - books that are read\nfalse - books that are unread")
         bot.listen do |message|
          if message.text == 'all'

            all_books = Array.new(Book.all)
            bot.api.send_message(chat_id: message.chat.id, text: "#{STATUS['success']}\n#{all_books}" )

          elsif message.text == 'true'
            
            books_true = Array.new(Book.where(status: true))
            bot.api.send_message(chat_id: message.chat.id, text: "#{STATUS['success']}\n#{books_true}" )

          else

            books_false = Array.new(Book.where(status: false))
            bot.api.send_message(chat_id: message.chat.id, text: "#{STATUS['success']}\n#{books_false}" )

          end
        end
       

      when '/show_author' 
        bot.api.send_message(chat_id: message.chat.id, text: "Send me author's id")
        bot.listen do |message|
          puts message.text
          author = Author.find_by_id(message.text)
          if author.nil?
            bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
          else
            bot.api.send_message(chat_id: message.chat.id, 
            text: "#{STATUS['success']}\nLoaded author:\nId: #{author['id']},\nTitle: #{author['name']},\nStatus: #{author['surname']}", date: message.date)
          end
        end

      when '/delete_author'
        bot.api.send_message(chat_id: message.chat.id, text: "Send me book's id to delete")
        bot.listen do |message|
          puts message.text
          author = Author.find_by_id(message.text)
          if author.nil?
            bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
          else
            author.destroy
            bot.api.send_message(chat_id: message.chat.id, 
            text: "#{STATUS['success']}\nDeleted author:\nId: #{author['id']},\nTitle: #{author['name']},\nStatus: #{author['surname']}", date: message.date)
          end
        end

       when '/show_all_authors'
        all_authors = Array.new(Author.all)
        bot.api.send_message(chat_id: message.chat.id, text: "#{STATUS['success']}\n#{all_authors}" )

      else

        bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you :(")

    end
  end
end
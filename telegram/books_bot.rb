require File.expand_path('../config/environment', __dir__)
require 'openssl'
require 'telegram/bot'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

token = '1212341741:AAE7QeQfJu1CGhlXSFDYB35EXTvrqG1DnUM'
Telegram::Bot::Client.run(token) do |bot|
bot.listen do |message|


  case message

    when Telegram::Bot::Types::CallbackQuery
      case message.data 


        when 'find_book'
          bot.api.send_message(chat_id: message.from.id, text: "Send book's id to find or back to select another command")
          bot.listen do |message|
            if message.text == "back"
              books_methods = [
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Find book by id', callback_data: 'find_book'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Show books', callback_data: 'show_books'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add book', callback_data: 'add_book'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete book by id', callback_data: 'delete_book'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: "Add author to the book", callback_data: 'add_author_to_book'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: "Show book's authors", callback_data: 'book_authors'),
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Mark a book as read', callback_data: 'mark_book')
              ]
              markup_books_methods = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: books_methods)
              bot.api.send_message(chat_id: message.from.id, text: "Select the desired command", reply_markup: markup_books_methods)
              break
            else
              puts message.text
              book = Book.find_by_id(message.text)
                if book.nil?
                  bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
                else
                  bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                  text: "*Status: #{STATUS['success']}*\n\nLoaded book:\nId: #{book['id']}\nTitle: #{book['title']}\nStatus: #{book['status']}", date: message.date)
                end
            end
          end

          

        when 'show_books'
          kb_show_books = [
            Telegram::Bot::Types::KeyboardButton.new(text: "All books"),
            Telegram::Bot::Types::KeyboardButton.new(text: "Read books"),
            Telegram::Bot::Types::KeyboardButton.new(text: "Unread books")
          ]
          markup_show_books = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_show_books, one_time_keyboard: true)
          bot.api.send_message(chat_id: message.from.id, text: "Choose which books you want to see", reply_markup: markup_show_books)



        when 'add_book'
          bot.api.send_message(chat_id: message.from.id, text: "Send title of the book")
          bot.listen do |message|
            title = message.text
            bot.api.send_message(chat_id: message.from.id, text: "Send status of the book (true or false)")

            bot.listen do |message|
              status = message.text
              puts title
              puts status
              book = Book.new(title: title, status: status)
              if book.save
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['created']}*\n\nCreated book:\nId: #{book['id']}\nTitle: #{book['title']}\nStatus: #{book['status']}", date: message.date)
                break
              else
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['bad_request']}*", date: message.date)
                break
              end
            end
            break
          end

            

        when 'delete_book'
          bot.api.send_message(chat_id: message.from.id, text: "Send book's id to delete")
          bot.listen do |message|
            puts message.text
            book = Book.find_by_id(message.text)
              if book.nil?
                bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
              else
                book.destroy
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['success']}*\n\nDeleted book:\nId: #{book['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}", date: message.date)
              end
              break
          end


        when 'add_author_to_book'
          bot.api.send_message(chat_id: message.from.id, text: "Send book's id to add the author")
          bot.listen do |message|
            puts message.text
            book = Book.find_by_id(message.text) 
            if book.nil?
              puts 'not_found'
              bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
            else
              puts 'ok'
              bot.api.send_message(chat_id: message.from.id, text: "Send author's id", date: message.date)
              bot.listen do |message|
                author = Author.find_by_id(message.text)
                if author.nil?
                  bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
                else
                  book.authors << author
                  bot.api.send_message(chat_id: message.chat.id, text: STATUS['success'], date: message.date)
                end
              end
            end
            break
          end


        when 'book_authors'
          bot.api.send_message(chat_id: message.from.id, text: "Send book's id to show its authors")
          bot.listen do |message|

            book = Book.find_by_id(message.text) 
            if book.nil?
              bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
            else
              book_authors = book.authors.where("authors_books.book_id" => book[:id])
              ikb_book_authors = []
              for author in book_authors do
                ikb_book_authors << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{author['id']}, Name: #{author['name']}, Surname: #{author['surname']}", callback_data: 'author')
              end 
              markup_ikb_book_authors = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_book_authors)
              bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nBook's authors:", reply_markup: markup_ikb_book_authors)
            end
            break
          end


          

        when 'mark_book'
          bot.api.send_message(chat_id: message.from.id, text: "Send book's id to mark as read")
          bot.listen do |message|
            puts message.text
            book = Book.find_by_id(message.text)
              if book.nil?
                bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
              else
                book.update(:status => 'true')
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['success']}*\n\nUpdated book:\nId: #{book['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}", date: message.date)
              end
              break
          end


        when 'find_author'
          bot.api.send_message(chat_id: message.from.id, text: "Send authors's id to find")
          bot.listen do |message|
            puts message.text
            author = Author.find_by_id(message.text)
              if author.nil?
                bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
              else
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['success']}*\n\nLoaded author:\nId: #{author['id']}\nName: #{author['name']}\nSurname: #{author['surname']}", date: message.date)
              end
              break
          end


        when 'show_authors'
          all_authors = Array.new(Author.all)
          ikb_all_authors = []
          for author in all_authors do
            ikb_all_authors << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{author['id']}, Name: #{author['name']}, Surname: #{author['surname']}", callback_data: 'author')
          end 
          markup_ikb_all_authors = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_all_authors)
          bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nLoaded authors:", reply_markup: markup_ikb_all_authors)



        when 'add_author'
          bot.api.send_message(chat_id: message.from.id, text: "Send name of the book")
          bot.listen do |message|
            author_name = message.text
            bot.api.send_message(chat_id: message.from.id, text: "Send surname of the author")
            bot.listen do |message|
              author_surname = message.text
              puts title
              puts status
              author = Book.new(name: author_name, surname: author_surname)
              if author.save
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['created']}*\n\nCreated author:\nId: #{author['id']}\nTitle: #{author['name']}\nStatus: #{author['surname']}", date: message.date)
              else
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['bad_request']}*", date: message.date)
              end
            end
            break
          end


        when 'delete_author'
          bot.api.send_message(chat_id: message.from.id, text: "Send authors's id to delete")
          bot.listen do |message|
            puts message.text
            author = Author.find_by_id(message.text)
              if author.nil?
                bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
              else
                bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
                text: "*Status: #{STATUS['success']}*\n\nDeleted book:\nId: #{author['id']}\nName: #{author['name']}\nSurname: #{author['surname']}", date: message.date)
              end
              break
          end


        when 'author_books'
          bot.api.send_message(chat_id: message.from.id, text: "Send authors's id to show books")
          bot.listen do |message|

            author = Author.find_by_id(message.text) 
            if author.nil?
              bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
            else
              author_books = author.books.where("authors_books.author_id" => author[:id]) 
              ikb_author_books = []
              for book in author_books do
                ikb_author_books << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: 'author')
              end 
              markup_ikb_author_books = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_author_books)
              bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nAuthor's books:", reply_markup: markup_ikb_author_books)
            end
            break
          end



        when 'add_book_to_author'
          bot.api.send_message(chat_id: message.from.id, text: "Send author's id to add the book")
          bot.listen do |message|
            author = Author.find_by_id(message.text) 
            if author.nil?
              bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
            else
              bot.api.send_message(chat_id: message.from.id, text: "Send book's id")
              bot.listen do |message|
                book = Book.find_by_id(message.text)
                if book.nil?
                  bot.api.send_message(chat_id: message.chat.id, text: STATUS['not_found'], date: message.date)
                else
                  author.books << book
                  bot.api.send_message(chat_id: message.chat.id, text: STATUS['success'], date: message.date)
                end
                break
              end
            end
            break
          end



      end
    

    when Telegram::Bot::Types::Message
      case message.text 
        when '/start'
          kb_books_authors = [
            Telegram::Bot::Types::KeyboardButton.new(text: "Books📚"),
            Telegram::Bot::Types::KeyboardButton.new(text: "Authors👩🏼‍💼🧑🏽‍💼📝")
          ]

          markup_books_authors = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_books_authors, one_time_keyboard: true)
          bot.api.send_message(chat_id: message.chat.id, text: "Hi, #{message.from.first_name} \nPlease select the desired item", reply_markup: markup_books_authors)

        when 'Books📚'
          books_methods = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Find book by id', callback_data: 'find_book'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Show books', callback_data: 'show_books'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add book', callback_data: 'add_book'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete book by id', callback_data: 'delete_book'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: "Add author to the book", callback_data: 'add_author_to_book'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: "Show book's authors", callback_data: 'book_authors'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Mark a book as read', callback_data: 'mark_book')
          ]

          markup_books_methods = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: books_methods)
          bot.api.send_message(chat_id: message.chat.id, text: "Select the desired command", reply_markup: markup_books_methods)

        when 'All books'
          all_books = Array.new(Book.all)
          ikb_all_books = []
          for book in all_books do
            ikb_all_books << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: 'book')
          end
          markup_ikb_all_books = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_all_books)
          bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nAll books:", reply_markup: markup_ikb_all_books)


        when 'Read books'
          books_true = Array.new(Book.where(status: true))
          ikb_books_true = []

          for book in books_true do
            ikb_books_true << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: 'book')
          end

          markup_ikb_books_true = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_books_true)
          bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nRead books:", reply_markup: markup_ikb_books_true)



        when 'Unread books'
          books_false = Array.new(Book.where(status: false))
          ikb_books_false = []

          for book in books_false do
            ikb_books_false << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: 'book')
          end  

          markup_ikb_books_false = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_books_false)
          bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nUnread books:", reply_markup: markup_ikb_books_false)
          

        when 'Authors👩🏼‍💼🧑🏽‍💼📝'
          authors_methods = [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Find author by id', callback_data: 'find_author'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Show all authors', callback_data: 'show_authors'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add author', callback_data: 'add_author'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete author by id', callback_data: 'delete_author'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: "Add book to author", callback_data: 'add_book_to_author'),
            Telegram::Bot::Types::InlineKeyboardButton.new(text: "Show author's books", callback_data: 'author_books')
          ]

          markup_authors_methods = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: authors_methods)
          bot.api.send_message(chat_id: message.chat.id, text: "Select the desired command", reply_markup: markup_authors_methods)

        else
          bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you :(")
        end
      end
    end
end




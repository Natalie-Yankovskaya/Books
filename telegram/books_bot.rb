require File.expand_path('../config/environment', __dir__)
require File.expand_path('../telegram/books_methods', __dir__)
require File.expand_path('../telegram/authors_methods', __dir__)
require File.expand_path('../telegram/general_methods', __dir__)
require 'openssl'
require 'telegram/bot'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

token = '1212341741:AAE7QeQfJu1CGhlXSFDYB35EXTvrqG1DnUM'
Telegram::Bot::Client.run(token) do |bot|

bot.listen do |message|
  case message

    when Telegram::Bot::Types::CallbackQuery
      case message.data 

        #book's methods
        when /find_book./
          GeneralMethods.find(bot, message, Book) 

        when /delete_book./
          GeneralMethods.delete(bot, message, Book)

        when /mark_book./
          BooksMethods.mark_book_as_read(bot, message)

        when /add_author_to_book./
          GeneralMethods.add_author_or_book(bot, message, Book)

        when /method_book_authors./
         GeneralMethods.show_books_authors(bot, message, Book)

        when /existing_author./
          GeneralMethods.choose_existing(bot, message, Book)

        when /author_to_book./
          GeneralMethods.add_existing(bot, message, Book)

        when /new_author./
          AuthorsMethods.new_author(bot, message, 'book')


        #author's methods
        when /find_author./
          GeneralMethods.find(bot, message, Author)

        when /delete_author./
          GeneralMethods.delete(bot, message, Author)

        when /add_book_to_author./
          GeneralMethods.add_author_or_book(bot, message, Author)

        when /method_author_books./
          GeneralMethods.show_books_authors(bot, message, Author)

        when /existing_book./
          GeneralMethods.choose_existing(bot, message, Author)

        when /book_to_author./
          GeneralMethods.add_existing(bot, message, Author)

        when /new_book./
         BooksMethods.new_book(bot, message, 'author')


      end
    

    when Telegram::Bot::Types::Message
      case message.text 


        when '/start'
          GeneralMethods.start(bot, message)
          


        when 'Books📚'
          GeneralMethods.menu_books_authors(bot, message, Book)
          
        when 'Show books'
          BooksMethods.show_books(bot, message)
           
        when 'Add book'
          BooksMethods.new_book(bot, message, 'else')

        when 'All books'
          BooksMethods.show_status_books(bot, message, 'All')

        when 'Read books'
          BooksMethods.show_status_books(bot, message, 'Read')

        when 'Unread books'
          BooksMethods.show_status_books(bot, message, 'Unread')
          



        when 'Authors👩🏼‍💼🧑🏽‍💼📝'
          GeneralMethods.menu_books_authors(bot, message, Author)

        when 'Show authors'
          AuthorsMethods.show_authors(bot, message)


        when 'Add author'
          AuthorsMethods.new_author(bot, message, 'else')
          


        else
          bot.api.send_message(chat_id: message.chat.id, text: "I don't understand you :(")


        end
      end
    end
end




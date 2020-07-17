require File.expand_path('../telegram/authors_methods', __dir__)
require File.expand_path('../telegram/general_methods', __dir__)


module BooksMethods


  def books_methods(bot, book_id, message)
    book_methods = [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Mark book as read', callback_data: "mark_book,#{book_id}"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete book', callback_data: "delete_book,#{book_id}")
      ],
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "Add author to book", callback_data: "add_author_to_book,#{book_id}"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: "Show book's authors", callback_data: "method_book_authors,#{book_id}")
      ]
    ]

    markup_book_methods = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: book_methods)
    bot.api.send_message(chat_id: message.from.id, text: "Select the desired command", reply_markup: markup_book_methods)  
  end
  module_function :books_methods



  def mark_book_as_read(bot, message)
    book_id = GeneralMethods.find_id(message, 1)
    book = Book.find_by_id(book_id)
    if book.nil?
      bot.api.send_message(chat_id: message.from.id, text: STATUS['not_found'])
    else
      book.update(:status => 'true')
      text_result = "Updated book:\nId: #{book['id']},\nTitle: #{book['title']},\nStatus: #{book['status']}"
      bot.api.send_message(chat_id: message.from.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['success']}*\n\n#{text_result}")
      books_methods(bot, book_id, message)
    end
  end
  module_function :mark_book_as_read



  def new_book(bot, message, item)

    if item == 'author'
      author_id = GeneralMethods.find_id(message, 1)
      author = Author.find_by_id(author_id)
    end

    bot.api.send_message(chat_id: message.from.id, text: "Send book's title")
    bot.listen do |message|
      book_title = message.text
      bot.api.send_message(chat_id: message.from.id, text: "Send book's status (true or false)")
      bot.listen do |message|
        book_status = message.text
        book = Book.new(title: book_title, status: book_status)
        if book.save
          bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
          text: "*Status: #{STATUS['created']}*\n\nCreated book:\nId: #{book['id']}\nTitle: #{book['title']}\nStatus: #{book['status']}", date: message.date)
          if item == 'author'
            author.books << book
            bot.api.send_message(chat_id: message.from.id, text: "#{STATUS['success']} \nBook is added to the author")
            AuthorsMethods.authors_methods(bot, author_id, message)
          else
            books_methods(bot, author_id, message)
          end
        else
          bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['bad_request']}*", date: message.date)
        end
        break
      end
      break
    end
  end
  module_function :new_book



  def show_books(bot, message)
    kb_show_books = [
      Telegram::Bot::Types::KeyboardButton.new(text: "All books"),
      Telegram::Bot::Types::KeyboardButton.new(text: "Read books"),
      Telegram::Bot::Types::KeyboardButton.new(text: "Unread books")
    ]
    markup_show_books = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_show_books, one_time_keyboard: true)
    bot.api.send_message(chat_id: message.from.id, text: "Choose which books you want to see", reply_markup: markup_show_books)
  end
  module_function :show_books



  def show_status_books(bot, message, status)
    if status == 'All'
      books = Array.new(Book.all)
    elsif status == 'Read'
      books = Array.new(Book.where(status: true))
    else
      books = Array.new(Book.where(status: false))
    end

    ikb_books = []

    for book in books do
      ikb_books << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: "find_book,#{book['id']}")
    end  

    markup_ikb_books = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_books)
    bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nUnread books:", reply_markup: markup_ikb_books)

  end
  module_function :show_status_books

end
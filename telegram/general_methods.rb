require File.expand_path('../telegram/books_methods', __dir__)
require File.expand_path('../telegram/authors_methods', __dir__)

module GeneralMethods

  def logger_info(text)
    logger = Logger.new(STDOUT)
    logger.formatter = proc { |severity, datetime, progname, msg| "#{severity}, #{datetime}, #{msg}\n" }
    logger.info(text)
  end
  module_function :logger_info



  def start(bot, message)
    logger_info('The start command selected')
    kb_books_authors = [
      Telegram::Bot::Types::KeyboardButton.new(text: "Books📚"),
      Telegram::Bot::Types::KeyboardButton.new(text: "Authors👩🏼‍💼🧑🏽‍💼📝")
    ]

    markup_books_authors = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb_books_authors, one_time_keyboard: true)
    bot.api.send_message(chat_id: message.chat.id, text: "Hi, #{message.from.first_name} \nPlease select the desired item", reply_markup: markup_books_authors)
  end  
  module_function :start



  def menu_books_authors(bot, message, item)
    logger_info('Showing menu with show and add methods')
    if item == Book
      logger_info('for books')
      result_methods = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Show books'),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Add book')
      ] 
    else
      logger_info('For authors')
      result_methods = [
        Telegram::Bot::Types::KeyboardButton.new(text: 'Show authors'),
        Telegram::Bot::Types::KeyboardButton.new(text: 'Add author')
      ]
    end
    markup_result_methods = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: result_methods)
    bot.api.send_message(chat_id: message.chat.id, text: "Select the desired command", reply_markup: markup_result_methods)
  end
  module_function :menu_books_authors



  def find_id(message, idx)
    data = message.data.split(",")
    id = data[idx]
    return id
  end
  module_function :find_id



  def delete(bot, message, item)
    logger_info('Deleting item')
    id = find_id(message, 1)
    book_author = item.find_by_id(id)
    if book_author.nil?
      logger_info('The item is not found')
      bot.api.send_message(chat_id: message.from.id, text: STATUS['not_found'])
    else
      if item == Book
        logger_info("Book #{id} is deleted")
        text_result =  "Deleted book:\nId: #{book_author['id']},\nTitle: #{book_author['title']},\nStatus: #{book_author['status']}"
      else
        logger_info("Author #{id} is deleted")
        text_result = "Deleted author:\nId: #{book_author['id']}\nName: #{book_author['name']}\nSurname: #{book_author['surname']}"
      end
      book_author.destroy
      bot.api.send_message(chat_id: message.from.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['success']}*\n\n#{text_result}")
    end
  end
  module_function :delete



  def find(bot, message, item)
    id = find_id(message, 1)
    book_author = item.find_by_id(id)
    if book_author.nil?
      logger_info("The book or author is not find from the list")
      bot.api.send_message(chat_id: message.from.id, text: STATUS['not_found'])
    else
      if item == Book
        logger_info("Showing selected book #{id} form the list")
        text_result =  "Loaded book:\nId: #{book_author['id']},\nTitle: #{book_author['title']},\nStatus: #{book_author['status']}"
      else
        logger_info("Showing selected author #{id} form the list")
        text_result = "Loaded author:\nId: #{book_author['id']}\nName: #{book_author['name']}\nSurname: #{book_author['surname']}"
      end
      bot.api.send_message(chat_id: message.from.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['success']}*\n\n#{text_result}")

      if item == Book
        BooksMethods.books_methods(bot, id, message)
      else
        AuthorsMethods.authors_methods(bot, id, message)
      end
    end
  end
  module_function :find



  def add_author_or_book(bot, message, item)
    id = find_id(message, 1)
    book_author = item.find_by_id(id) 
    if book_author.nil?
      logger_info("The book or author is not found")
      bot.api.send_message(chat_id: message.from.id, text: STATUS['not_found'])
    else

      if item == Book
        logger_info("Adding author to the book #{id}")
      choice = [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add existing author', callback_data: "existing_author,#{id}"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add new author', callback_data: "new_author,#{id}"),
      ]

      else
        logger_info("Adding book to the author #{id}")
        choice = [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add existing book', callback_data: "existing_book,#{id}"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Add new book', callback_data: "new_book,#{id}"),
        ]

      end
        markup_choice = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: choice)
        bot.api.send_message(chat_id: message.from.id, text: "Select the desired command", reply_markup: markup_choice)
    end
  end
  module_function :add_author_or_book




  def show_books_authors(bot, message, item)
    id = find_id(message, 1)
    book_author = item.find_by_id(id) 
    if item == Book
      logger_info("Showing authors of the book #id}")
      text_result = "Book's authors:"
      book_authors = book_author.authors.where("authors_books.book_id" => book_author[:id])
      result = []
      for author in book_authors do
        result << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{author['id']}, Name: #{author['name']}, Surname: #{author['surname']}", callback_data: "find_author,#{author['id']}")
      end

    else
      logger_info("Showing books of the author #{id}")
      text_result = "Author's books:"
      author_books = book_author.books.where("authors_books.author_id" => book_author[:id]) 
      result = []
      for book in author_books do
        result << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: "find_book,#{book['id']}")
      end 

    end

    markup_ikb_result = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: result)
    bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \n#{text_result}", reply_markup: markup_ikb_result)

    if item == Book
      BooksMethods.books_methods(bot, id, message)
    else
      AuthorsMethods.authors_methods(bot, id, message)
    end
  end
  module_function :show_books_authors




  def choose_existing(bot, message, item)
    id = find_id(message, 1)
    if item == Book
      logger_info("Choosing existing Author from the list for book #{id}")
      all_authors = Array.new(Author.all)
      result = []
      for author in all_authors do
        result << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{author['id']}, Name: #{author['name']}, Surname: #{author['surname']}", callback_data: "author_to_book,#{id},#{author['id']}")
      end 
    else
      logger_info("Choosing existing book from the list for author #{id}")
      all_books = Array.new(Book.all)
      result = []
      for book in all_books do
        result << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{book['id']}, Title: #{book['title']}, Status: #{book['status']}", callback_data: "book_to_author,#{book['id']},#{id}")
      end 
    end
      
    markup_result = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: result)
    bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nLoaded:", reply_markup: markup_result)
  end
  module_function :choose_existing




  def add_existing(bot, message, item)
    book_id = find_id(message, 1)
    author_id = find_id(message, 2)
    book = Book.find_by_id(book_id)
    author = Author.find_by_id(author_id)
    if item == Book
      logger_info("Adding existing author #{author_id} from the list to book #{book_id}")
      book.authors << author
      bot.api.send_message(chat_id: message.from.id, text: STATUS['success'])
      BooksMethods.books_methods(bot, book_id, message)
    else
      logger_info("Choosing existing book #{book_id} from the list for author #{author_id}")
      author.books << book
      bot.api.send_message(chat_id: message.from.id, text: STATUS['success'])
      AuthorsMethods.authors_methods(bot, book_id, message)
    end
  end
  module_function :add_existing



end
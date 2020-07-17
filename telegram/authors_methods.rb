require File.expand_path('../telegram/books_methods', __dir__)
require File.expand_path('../telegram/general_methods', __dir__)


module AuthorsMethods

	def authors_methods(bot, author_id, message)
    	author_methods = [
      		[Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Delete author', callback_data: "delete_author,#{author_id}")],
     		[Telegram::Bot::Types::InlineKeyboardButton.new(text: "Add book to author", callback_data: "add_book_to_author,#{author_id}"),
       		Telegram::Bot::Types::InlineKeyboardButton.new(text: "Show author's books", callback_data: "method_author_books,#{author_id}")]
    	]

    	markup_author_methods = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: author_methods)
    	bot.api.send_message(chat_id: message.from.id, text: "Select the desired command", reply_markup: markup_author_methods)

  	end
    module_function :authors_methods



  	def new_author(bot, message, item)
    	if item == 'book'
      	book_id = GeneralMethods.find_id(message, 1)
     	book = Book.find_by_id(book_id)
    	end
    	bot.api.send_message(chat_id: message.from.id, text: "Send author's name")
    	bot.listen do |message|
      		author_name = message.text
      		puts author_name
      		bot.api.send_message(chat_id: message.from.id, text: "Send author's surname")
      		bot.listen do |message|
        		author_surname = message.text
        		puts author_surname
       			author = Author.new(name: author_name, surname: author_surname)
        		if author.save
          			bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown',
          			text: "*Status: #{STATUS['created']}*\n\nCreated author:\nId: #{author['id']}\nName: #{author['name']}\nSurname: #{author['surname']}", date: message.date)
          			if item =='book'
           				book.authors << author
            			bot.api.send_message(chat_id: message.from.id, text: "#{STATUS['success']} \nAuthor is added to the book")
            			BooksMethods.books_methods(bot, book_id, message)
          			else
            			authors_methods(bot, book_id, message)
          			end
        		else
          			bot.api.send_message(chat_id: message.chat.id, parse_mode: 'Markdown', text: "*Status: #{STATUS['bad_request']}*", date: message.date)
        		end
        		break
      		end
    		break
    	end
  	end
    module_function :new_author


    def show_authors(bot, message)
    all_authors = Array.new(Author.all)
    ikb_all_authors = []
    for author in all_authors do
      ikb_all_authors << Telegram::Bot::Types::InlineKeyboardButton.new(text: "Id: #{author['id']}, Name: #{author['name']}, Surname: #{author['surname']}", callback_data: "find_author,#{author['id']}'")
    end 
    markup_ikb_all_authors = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: ikb_all_authors)
    bot.api.send_message(chat_id: message.from.id, text: "Status: #{STATUS['success']} \nLoaded authors:", reply_markup: markup_ikb_all_authors) 
 	end
    module_function :show_authors

  
end
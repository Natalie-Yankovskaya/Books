class Api::V1::BooksController < ApplicationController


	#show books (all, true or false)
	def index

		book = Book.new(book_params)
		book1 = book_params[:status]

		if(book1 == true)

		@books_true = Book.select(Arel.star).where(Book.arel_table[:status].eq(true))
		render json: {status: 'SUCCESS', message: 'The books that are read', data: @books_true}

	else
		if(book1 == false)

		@books_false = Book.select(Arel.star).where(Book.arel_table[:status].eq(false))
				render json: {status: 'SUCCESS', message: 'The books that are unread', data: @books_false}

	else

		@books_all = Book.all
		render json: {status: 'SUCCESS', message: 'All books', data: @books_all }

	end		
	end


	end


#show book by index (пишем в строке: например .../12)
def show
	book = Book.find(params[:id])
	render json: {status: 'SUCCESS', message: "Loaded article", data:book}
end



#Add book
	def create
	book = Book.new(book_params)
	if book.save
		render json: {status: 'SUCCESS', message: "The book is created", data:book}
	else
		render json: {status: 'ERROR', message:'The book is not created', data:book.errors}
	end
end


#delete book (пишем в строке: например .../12)
def destroy
	book = Book.find(params[:id])
	book.destroy
	render json: {status: 'SUCCESS', message: "The book is deleted", data:book}
end


#Mark as read
def update
	book = Book.find(params[:id])
	if book
		book.update(:status => 'true')
	render json: {status: 'SUCCESS', message: "The book is marked as read", data:book}
	else
		render json: {status: 'ERROR', message:'The book is not updated', data:book.errors}
	end
end


private
def book_params
	params.permit(:id, :title, :author, :status)
end
end

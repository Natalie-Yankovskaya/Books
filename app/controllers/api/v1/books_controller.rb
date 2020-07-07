class Api::V1::BooksController < ApplicationController

	#show books (all, true or false)
	def index

		if book_params[:status].nil?
			books_all = Book.all
			render json: {status: STATUS['success'], message: 'All books', data: books_all}
		elsif(book_params[:status])
			books_true = Book.where(status: true)
			render json: {status: STATUS['success'], message: 'The books that are read', data: books_true}
		else
			books_false = Book.where(status: false)
			render json: {status: STATUS['success'], message: 'The books that are unread', data: books_false}
		end	

	end


	#show book by index (пишем в строке: например .../12)
	def show
		book = Book.find(params[:id]) 

		if book.nil?
			render json: {status: STATUS['not_found'], message: "The book is not found", data: book.errors}
		else
			if params[:idx_add]
				author = Author.find(params[:idx_add])
				book.authors << author
			end

			if params[:idx_delete]
				author = Author.find(params[:idx_delete])
				book.authors.destroy(author)
			end

			render json: {status: STATUS['success'], message: "Loaded book", data: book, number_of_authors: book.authors.count }
		end

	end



	#Add book
	def create
		book = Book.new(book_params)
		if book.save
			render json: {status: STATUS['created'], message: "The book is created", data: book}
		else
			render json: {status: STATUS['bad_request'], message: "The book is not created", data: book.errors}
		end

	end


	#delete book (пишем в строке: например .../12)
	def destroy
		book = Book.find(params[:id])
		if book.nil? 
			render json: {status: STATUS['not_found'], message: "The book is not found", data: book.errors}
		else
			book.destroy
			render json: {status: STATUS['success'], message: "This book is deleted", data: book}
		end
	end


	#Mark as read
	def update
		book = Book.find(params[:id])
		if book
			book.update(:status => 'true')
			render json: {status: STATUS['success'], message: "The book is marked as read", data: book}
		else
			render json: {status: STATUS['not_found'], message:"The book is not found", data: book.errors}
		end
	end


	private
	def book_params
		params.permit(:id, :title, :status)
	end


end

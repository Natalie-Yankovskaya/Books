class Api::V1::AuthorsController < ApplicationController

	#show author (all, true or false)
	def index
		authors = Author.all
		render json: {status: STATUS['success'], message: 'All authors', data:authors }

	end


	#show author by index (пишем в строке: например .../12)
	def show

		author = Author.find_by_id(params[:id]) 

		if author.nil?
			render json: {status: STATUS['not_found'], message: "The author is not found", data: author.errors }
		else

			if params[:idx_add]
				book = Book.find(params[:idx_add])
				author.books << book
			end

			if params[:idx_delete]
				book = Book.find(params[:idx_delete])
				author.books.destroy(book)
			end
			
			render json: 
			{
				status: STATUS['success'], 
				message: "Loaded author", 
				data: author, 
				number_of_books: author.books.count, 
				books: author.books.where("authors_books.author_id" => author[:id]) 
			}
		end

	end



	#Add author
	def create

		author = Author.new(author_params)
		
		if author.save
			render json: {status: STATUS['created'], message: "The author is created", data: author}
		else
			render json: {status: STATUS['bad_request'], message: "The author is not created", data: author.errors}
		end
	end


	#delete author (пишем в строке: например .../12)
	def destroy
		author = Author.find_by_id(params[:id])
		if author.nil? 
			render json: {status: STATUS['not_found'], message: "The author is not found", data: author.errors}
		else
			author.destroy
			render json: {status: STATUS['success'], message: "This author is deleted", data: author}
		end
	end



	private
	def author_params
		params.permit(:id, :name, :surname)
	end

	


end

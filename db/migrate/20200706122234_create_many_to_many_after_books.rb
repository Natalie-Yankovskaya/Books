class CreateManyToManyAfterBooks < ActiveRecord::Migration[5.1]
   def change
    remove_column(:books, :author)
 
    create_table :authors do |t|
      t.string :name
      t.string :surname
    end
 
    create_table :authors_books do |t|
      t.belongs_to :book
      t.belongs_to :author
    end
  end
end

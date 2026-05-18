class CreateTestimonials < ActiveRecord::Migration[8.2]
  def change
    create_table :testimonials do |t|
      t.string :author_name
      t.string :author_role
      t.text :content
      t.integer :sort_order
      t.boolean :active

      t.timestamps
    end
  end
end

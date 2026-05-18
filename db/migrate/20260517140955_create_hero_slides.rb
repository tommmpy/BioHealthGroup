class CreateHeroSlides < ActiveRecord::Migration[8.2]
  def change
    create_table :hero_slides do |t|
      t.string :title
      t.string :subtitle
      t.string :cta_text
      t.string :cta_link
      t.integer :sort_order
      t.boolean :active

      t.timestamps
    end
  end
end

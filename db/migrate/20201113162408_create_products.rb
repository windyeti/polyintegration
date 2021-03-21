class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :title
      t.string :desc
      t.string :cat
      t.string :charact
      t.decimal :oldprice
      t.decimal :price
      t.integer :quantity
      t.string :image
      t.string :url
      t.bigint :insales_id
      t.bigint :insales_var_id
      t.belongs_to :rt
      t.belongs_to :dr
      t.string :weight
      t.string :color
      t.string :size
      t.string :distributor

      t.timestamps
    end
  end
end

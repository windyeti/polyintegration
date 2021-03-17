class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :sku
      t.string :title
      t.string :desc
      t.string :cat
      t.string :charact
      t.string :charact_gab
      t.decimal :oldprice
      t.decimal :price
      t.integer :quantity
      t.string :image
      t.string :url
      t.decimal :provider_price
      t.bigint :productid_insales
      t.bigint :productid_var_insales
      t.references :productable, polymorphic: true
      t.boolean :visible, default: true
      t.decimal :komplekt

      t.timestamps
    end
  end
end

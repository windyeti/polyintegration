class CreateRts < ActiveRecord::Migration[5.0]
  def change
    create_table :rts do |t|
      t.string :fid
      t.integer :quantity
      t.string :sku
      t.string :title
      t.string :price
      t.string :desc
      t.string :param
      t.boolean :check, default: false

      t.timestamps
    end
  end
end

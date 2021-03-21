class CreateDistributors < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :name
      t.string :prefix
      t.string :permalink
      t.string :link

      t.timestamps
    end
  end
end

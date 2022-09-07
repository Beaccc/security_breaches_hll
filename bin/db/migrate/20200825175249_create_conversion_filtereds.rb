class CreateConversionFiltereds < ActiveRecord::Migration[5.2]
  def change
    create_table :conversion_filtereds do |t|
      t.integer :element

      t.timestamps
    end
  end
end

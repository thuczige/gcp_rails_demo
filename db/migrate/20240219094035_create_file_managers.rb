class CreateFileManagers < ActiveRecord::Migration[7.0]
  def change
    create_table :file_managers do |t|
      t.string :file_name
      t.text :content

      t.timestamps
    end
  end
end

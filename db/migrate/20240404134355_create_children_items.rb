class CreateChildrenItems < ActiveRecord::Migration[7.0]
  def change
    create_table :children_items do |t|
      t.references :child, null: false, foreign_key: { to_table: :children }
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end

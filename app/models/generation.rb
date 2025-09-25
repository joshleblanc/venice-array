class Generation < ApplicationRecord
  belongs_to :user
  belongs_to :generation_array

  has_one_attached :image

  after_create_commit do
    broadcast_append_to generation_array,
      target: ActionView::RecordIdentifier.dom_id(generation_array, :generations),
      partial: "generations/generation",
      locals: { generation: self }
  end
end

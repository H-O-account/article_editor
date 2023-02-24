class Api::V1::ArticlesDetailSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :status, :updated_at
  belongs_to :user, serializer: Api::V1::UserSerializer
end

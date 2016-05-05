class Comment < ActiveRecord::Base

	belongs_to :post
 	belongs_to :user

	default_scope { order('updated_at ASC') }

	validates :body, length: { minimum: 5 }, presence: true
	validates :post, presence: true
	validates :user, presence: true

  after_create :send_favorite_emails


  private

  def send_favorite_emails

    favorite_users_ids = FavoritesManager.favorites_users_ids_for_post_id(post)

    favorite_users_ids.each do |user_favorite_id|
      favorite_user = User.find(user_favorite_id)
      if should_receive_update_for?(favorite_user)
        FavoriteMailer.new_comment(favorite_user, self.post, self).deliver
      end
    end
  end

  def should_receive_update_for?(favorite_user)
    user_id != favorite_user.id && favorite_user.email_favorites?
  end
  
end

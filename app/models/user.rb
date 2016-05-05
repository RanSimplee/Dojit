class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_many :posts, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  mount_uploader :avatar, AvatarUploader

  def voted(post)
    votes.where(post_id: post.id).first
  end

  def admin?
    role == 'admin'
  end
  
  def moderator?
    role == 'moderator'
  end

  def self.top_rated
    self.select('users.*') # Select all attributes of the user
        .select('COUNT(DISTINCT comments.id) AS comments_count') # Count the comments made by the user
        .select('COUNT(DISTINCT posts.id) AS posts_count') # Count the posts made by the user
        .select('COUNT(DISTINCT comments.id) + COUNT(DISTINCT posts.id) AS rank') # Add the comment count to the post count and label the sum as "rank"
        .joins(:posts) # Ties the posts table to the users table, via the user_id
        .joins(:comments) # Ties the comments table to the users table, via the user_id
        .group('users.id') # Instructs the database to group the results so that each user will be returned in a distinct row
        .order('rank DESC') # Instructs the database to order the results in descending order, by the rank that we created in this query. (rank = comment count + post count)
  end

  def is_favorited(post)
    favorites_manager = FavoritesManager.new(self.id)
    favorites_manager.already_favorited?(post)
  end

  def add_post_to_favorites(post)
    favorites_manager = FavoritesManager.new(self.id)
    favorites_manager.favorite_post(post)
  end

  def remove_post_from_favorites(post)
    favorites_manager = FavoritesManager.new(self.id)
    favorites_manager.unfavorite_post(post)
  end

  def suggested_posts
    favorites_manager = FavoritesManager.new(self.id)
    ranked_suggestions = favorites_manager.suggestions

    suggested_ids = []
    max_suggestions = 5
    ranked_suggestions.map do |e|
      if(suggested_ids.count >= max_suggestions)
        break
      end
      suggested_ids << e[0]
    end

    Post.find(suggested_ids)
  end


end

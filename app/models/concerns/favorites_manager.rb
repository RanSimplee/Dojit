class FavoritesManager

  attr_reader :user_id

  def initialize(user_id)
    @user_id = user_id
    @client = REDIS
  end

  def favorite_post(post)
    client.multi do
      client.sadd(user_key, post.id)
      client.sadd(self.class.post_key(post), self.user_id)
    end
  end

  def unfavorite_post(post)
    client.multi do
      client.srem(user_key, post.id)
      client.srem(self.class.post_key(post), self.user_id)
    end
  end

  def already_favorited?(post)
    client.sismember(user_key, post.id)
  end

  def my_favorited_post_ids
    client.smembers(user_key)
  end

  def favorited_posts_count
    client.scard(user_key)
  end

  def suggestions
    # i'll leave it up to you guys, keep in mind that "intersections are a powerful tool"
    similar_users = Set.new([])

    my_favorited_post_ids.each do |post_id|
    	similar_users.merge(FavoritesManager.favorites_users_ids_for_post_id(post_id).to_set)
    end

    suggested_posts_ids = {}

    similar_users.each do |user_id|

			if (user_id.to_i == @user_id)
				next
			end

    	fav_man = FavoritesManager.new(user_id)

    	fav_man.my_favorited_post_ids.each do |fav_id|
    		if(suggested_posts_ids.member?(fav_id.to_s))
    			suggested_posts_ids[fav_id.to_s] = suggested_posts_ids[fav_id.to_s] + 1
    		else
    			suggested_posts_ids[fav_id.to_s] = 1
    		end
    	end
    end

    my_favorited_post_ids.each do |post_id|
    	suggested_posts_ids.delete(post_id)
    end

    sorted_suggestion = suggested_posts_ids.sort_by {|_key, value| value}
 		sorted_suggestion.reverse
  end

  def FavoritesManager.favorites_users_ids_for_post_id(post_id)
    REDIS.smembers(post_id_key(post_id))
  end

  private

  def user_key
    "users:#{self.user_id}:favorited_posts"
  end

  def self.post_key(post)
    post_id_key(post.id)
  end

   def self.post_id_key(post_id)
    "posts:#{post_id}:favorited_by_users"
  end

  def client
    @client
  end
end
class FavoritesController < ApplicationController
  
  def create
    @post = Post.find(params[:post_id])
    current_user.add_post_to_favorites(@post)

    redirect_to [@post.topic, @post]
  end

	def destroy
    @post = Post.find(params[:post_id])
    current_user.remove_post_from_favorites(@post)

    redirect_to [@post.topic, @post]
	end

end

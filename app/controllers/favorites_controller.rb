class FavoritesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    favorite = current_user.favorites.build(post: @post)
		authorize favorite

    if favorite.save
      flash[:notice] = "The post was successfuly added to your Favorites posts list."
      redirect_to [@post.topic, @post]
    else
			flash[:error] = "There was an error adding the post to your favorites list. Please try again."
      redirect_to [@post.topic, @post]
    end
  end

	def destroy
    @post = Post.find(params[:post_id])
    favorite = current_user.favorites.find(params[:id])
		authorize favorite
			
	  if favorite.destroy
      flash[:notice] = "The post was successfuly removed from your Favorites posts list."
      redirect_to [@post.topic, @post]
	  else
			flash[:error] = "There was an error removing the post from your favorites list. Please try again."
      redirect_to [@post.topic, @post]	  
    end
	end

end

module VotesHelper


	def up_vote_link_classes(post)
		"glyphicon glyphicon-chevron-up #{(current_user.voted(post) && current_user.voted(post).up_vote?) ? 'voted' : '' }" 
	end

	def down_vote_link_classes(post)
		"glyphicon glyphicon-chevron-down #{(current_user.voted(post) && current_user.voted(post).down_vote?) ? 'voted' : '' }" 
	end

end
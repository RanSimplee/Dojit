class Post < ActiveRecord::Base
	has_many :votes, dependent: :destroy
	has_many :comments, dependent: :destroy
	has_many :favorites, dependent: :destroy
	belongs_to :user
	belongs_to :topic
	mount_uploader :image, ImageUploader

	def up_votes
		votes.where(value: 1).count
	end

	def down_votes
		votes.where(value: -1).count
	end

	def points
		votes.sum(:value)
	end

	#default_scope { order('created_at DESC') }
	default_scope { order('rank DESC') }
	scope :visible_to, -> (user) { user ? all : joins(:topic).where('topics.public' => true) }

	validates :title, length: { minimum: 5 }, presence: true
	validates :body, length: { minimum: 20 }, presence: true
	validates :topic, presence: true
	validates :user, presence: true

	def update_rank
		one_day_in_second = 60 * 60 * 24
	  age_in_days = (created_at - Time.new(1970,1,1)) / one_day_in_second
	  new_rank = points + age_in_days
	  update_attribute(:rank, new_rank)
	end

	def create_vote
    	user.votes.create(value: 1, post: self)
	end

	def save_with_initial_vote
		ActiveRecord::Base.transaction do 
		  save
		  create_vote
		end
	end

end

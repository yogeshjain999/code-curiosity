class Commit
  include Mongoid::Document
  include Mongoid::Timestamps
  include JudgeScoringHelper

  COMMIT_TYPE = {score: 'Scores', commit: 'Commits', activity: 'Activities'}

  attr_accessor :branch

  field :message,        type: String
  field :commit_date,    type: DateTime
  field :html_url,       type: String
  field :comments_count, type: Integer, default: 0
  field :sha,            type: String
  field :auto_score,     type: Integer
  field :default_score,  type: Float, default: 0
  field :bugspots_score, type: Float, default: 0

  belongs_to :user
  belongs_to :repository
  belongs_to :round
  has_many :comments, as: :commentable
  embeds_many :scores, as: :scorable
  belongs_to :organization

  validates :message, uniqueness: {:scope => :commit_date}

  scope :for_round, -> (round_id) { where(:round_id => round_id) }

  index({ user_id: 1, round_id: 1 })
  index({ repository_id: 1 })
  index({ commit_date: -1 })
  index({ sha: 1 })
  index(auto_score: 1)

  after_create do |c|
    c.user.inc(commits_count: 1)
  end

  def info
    @info ||= GITHUB.repos.commits.get(repository.owner, repository.name, sha) #rescue nil
  end

  def max_rating
    COMMIT_RATINGS.last
  end

end

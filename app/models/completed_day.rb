class CompletedDay < ActiveRecord::Base
  belongs_to :chain
  belongs_to :habit
  
  validates :date, format: { with: /\d{4}-\d{2}-\d{2}/, :message => "must be in the following format: yyyy-mm-dd" }

  validates :date, presence: { message: " may not be blank" }

  validates :date, uniqueness: { scope: [:habit_id], message: "has already been logged" }

  validates :date, :timeliness => {:on_or_before => lambda { Date.current }, :type => :date, :on_or_before_message => "is in the future"}

  def self.update_chains
    completed_days = CompletedDay.all.sort_by(&:date)

        chains = completed_days.slice_before { |completed_day|
          index = completed_days.index(completed_day)
          completed_days[index-1].date != completed_day.date-1.day
        }

        Chain.destroy_all
        @chains = chains.map { |chain| 
          Chain.create(:start_date => chain[0].date, :end_date => chain[-1].date, :current => FALSE)
        }

        latest_chain = Chain.all.max_by {|chain| chain.start_date}
        latest_chain.current = TRUE
        latest_chain.save
        # TODO:
        # try sidekiq for async 
  end
end

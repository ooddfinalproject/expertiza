# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  def initialize(question_text, question_id, weight, question_max_score, seq)
    @question_text = question_text
    @weight = weight
    @question_id = question_id
    @question_seq = seq
    @question_max_score = question_max_score
    @score_row = []
    @countofcomments = 0
  end

  attr_reader :countofcomments
  attr_reader :question_seq
  attr_writer :countofcomments
  attr_reader :question_text
  attr_reader :question_id
  attr_reader :score_row
  attr_reader :weight

  # the question max score is the max score of the questionnaire, except if the question is a true/false, in which case
  # the max score is one.
  def question_max_score
    question = Question.find(self.question_id)
    if question.type == "Checkbox"
      return 1
    elsif question.is_a? ScoredQuestion
      @question_max_score
    else
      "N/A"
    end
  end

  def average_score_for_row
    row_average_score = 0.0
    @no_of_columns = 0.0 # Counting reviews that are not null
    @self_review_score_of_row = @score_row[-1].score_value
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        @no_of_columns += 1
        row_average_score += score.score_value.to_f
      end
    end
    unless @no_of_columns.zero?
      row_average_score /= @no_of_columns
      row_average_score.round(2)
    end
  end

  def composite_score_for_row
    @total_avg_score = average_score_for_row
    @peer_total = (@total_avg_score * @no_of_columns) - @self_review_score_of_row
    @peer_avg = @peer_total / (@no_of_columns - 1)
    if !@peer_avg.nan?
      # Apply your formula here
      composite_score = (100 - (@self_review_score_of_row - @peer_avg).abs) * (@peer_avg / 100)
      composite_score.round(2)
    else
      composite_score = "Not applicable"
    end
  end
end


# Copyright (c) 2011 Rice University.  All rights reserved.

require 'test_helper'

class AnswerChoiceTest < ActiveSupport::TestCase

  fixtures
  self.use_transactional_fixtures = true

  test "can't modify/destroy a choice for a published question" do
    sq = make_simple_question({:answer_credits => [0,1,0,0], 
                               :published => true,
                               :method => :create})
    
    ac1_id = sq.answer_choices.first.id
    sq.answer_choices.first.destroy
    
    assert_nothing_raised(ActiveRecord::RecordNotFound) {AnswerChoice.find(ac1_id)}
    
    ac1 = AnswerChoice.find(ac1_id)
    ac1.content = "This shouldn't stick"
    assert_raise(ActiveRecord::RecordInvalid) {ac1.save!}
  end

  test "can't mass-assign question and content_html" do
    question = Factory.create(:simple_question)
    cached = "Some cached content"
    ac = AnswerChoice.create(:question => question, :content_html => cached)
    assert !ac.save
    assert ac.question != question
    assert ac.content_html != cached
  end
  
  test "content copy" do
    ac1 = Factory.build(:answer_choice)
    ac2 = ac1.content_copy
    assert_equal(ac1.content, ac2.content)
    assert_equal(ac1.credit, ac2.credit)
    assert_not_equal(ac1, ac2)
  end

end
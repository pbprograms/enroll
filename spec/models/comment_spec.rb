require 'rails_helper'

RSpec.describe Comment, type: :model do
  it { should validate_presence_of :body }
  it { should validate_presence_of :priority }
  it { should validate_presence_of :user }

  let(:valid_params) do
    {
      body: "Enroll App team rocks!",
    }
  end

  context 'User parameter' do
    context 'when empty' do
      let(:params){valid_params.deep_merge!({user: nil})}
      it 'is invalid' do
        expect(Comment.create(**params).errors[:user].any?).to be_truthy
        expect(Comment.create(**params).errors[:user]).to eq ["can't be blank"]
      end
    end
  end

  context 'Priority Kind parameter' do
    context 'when empty' do
      let(:params){valid_params.deep_merge!({priority: ""})}
      it 'is invalid' do
        expect(Comment.create(**params).errors[:priority].any?).to be_truthy
        expect(Comment.create(**params).errors[:priority]).to eq ["Choose a priority", " is not a valid priority kind"]
      end
    end

    context "when invalid" do
      let(:params){valid_params.deep_merge!(priority: "fake")}
      it 'is invalid' do
        expect(Comment.create(**params).errors[:priority].any?).to be_truthy
        expect(Comment.create(**params).errors[:priority]).to eq ["fake is not a valid priority kind"]
      end
    end

    valid_priorities = Comment::PRIORITY_KINDS
    valid_priorities.each do |priority|
      context("when priority value is #{priority}") do
        let(:params){valid_params}
        it 'is valid' do
          params.deep_merge!({priority: priority})
          comment = Comment.new(**params)
          expect(comment).to be_truthy
          expect(comment.errors.messages.size).to eq 0
        end
      end
    end
  end



end

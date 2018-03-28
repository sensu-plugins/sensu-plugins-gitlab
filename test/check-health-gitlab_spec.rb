require_relative './spec_helper.rb'
require_relative '../bin/check-health-gitlab'
require_relative './fixtures.rb'

describe 'CheckHealthGitlab' do
  before do
    CheckHealthGitlab.class_variable_set(:@@autorun, false)
  end

  describe 'with positive answer' do
    before do
      @check = CheckHealthGitlab.new
      allow(@check).to receive(:request).and_return(gitlab_health_good_response)
    end

    describe '#run' do
      it 'tests that a check are ok' do
        expect(@check).to receive(:ok).with('Gitlab is ok')

        @check.run
      end
    end
  end

  describe 'with negative answer' do
    before do
      @check = CheckHealthGitlab.new
      allow(@check).to receive(:request).and_return(gitlab_health_bad_response)
    end

    describe '#run' do
      it 'tests that a check are ok' do
        expect(@check).to receive(:warning).with('Gitlab is not good db_check:error')

        @check.run
      end
    end
  end

  describe 'can not receive answer' do
    before do
      @check = CheckHealthGitlab.new
      allow(@check).to receive(:request).and_raise(StandardError, 'error')
    end

    describe '#run' do
      it 'tests that a check are ok' do
        expect(@check).to receive(:critical).with('error')

        @check.run
      end
    end
  end
end

# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

require 'logger'

class RunnerModel

  include ZeevexReliability::OptimisticLockRetryable

  def initialize(retry_count = 2)
    @retry_count = retry_count
    @executed = 0
    @reload_count = 0
  end

  def execution_count
    @executed
  end

  def succeed_at_once
    @executed += 1
    true
  end

  def never_succeed(error = ActiveRecord::StaleObjectError)
    @executed += 1
    raise error
  end

  def succeed_eventually(error = ActiveRecord::StaleObjectError)
    @executed += 1

    return true if @retry_count == 0
    @retry_count -= 1
    raise error
  end

  def reload
    @reload_count += 1
  end

  def reload!
    reload
  end

  def changed?
    false
  end

end

describe ZeevexReliability::OptimisticLockRetryable do 

  let :logger do
    Logger.new("/dev/null")
  end
  
  let :runner do
    RunnerModel.new
  end

  context "without error" do
    it "should execute once and succeed" do
      runner.with_optimistic_retry do
        runner.succeed_at_once
      end.should == true
      runner.execution_count.should == 1
    end
  end

  context "caught error" do
    it "when block fails twice and then succeeds, should return true" do
      runner.should_receive(:reload).twice.and_return(true)

      runner.with_optimistic_retry do
        runner.succeed_eventually
      end.should == true
      runner.execution_count.should == 3
    end

    it "when block fails twice and then succeeds, should return true" do
      runner.should_receive(:changed?).and_return(true)
      runner.should_receive(:logger).and_return(logger)
      logger.should_receive(:warn).once
      
      runner.with_optimistic_retry do
        runner.succeed_eventually
      end.should == true
    end

    it "when block always fails, it should stop after 3 tries then re-raise error" do
      expect {
        runner.with_optimistic_retry do
          runner.never_succeed
        end
      }.to raise_error(ActiveRecord::StaleObjectError)
      runner.execution_count.should == 3
    end

    it "when block always fails, it should stop after # of tries specified then re-raise error" do
      expect {
        runner.with_optimistic_retry(:tries => 10) do
          runner.never_succeed
        end
      }.to raise_error(ActiveRecord::StaleObjectError)
      runner.execution_count.should == 10
    end
  end

  context "uncaught error" do
    it "should fail once and not retry" do
      expect {
        runner.with_optimistic_retry do
          runner.never_succeed(NameError)
        end
      }.to raise_error(NameError)
      runner.execution_count.should == 1
    end
  end
end

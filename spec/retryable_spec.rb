# -*- coding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

class Runner
  def initialize(retry_count = 2)
    @retry_count = retry_count
    @executed = 0
  end

  def execution_count
    @executed
  end
  
  def succeed_at_once
    @executed += 1
    true
  end

  def never_succeed(error = ArgumentError)
    @executed += 1
    raise error
  end

  def succeed_eventually(error = ArgumentError)
    @executed += 1

    return true if @retry_count == 0
    @retry_count -= 1
    raise error
  end
    
  def raise_known
    raise ArgumentError
  end

  def raise_unknown
    raise "Just some other thing"
  end
end

describe ZeevexReliability::Retryable do 

  let :runner do
    Runner.new
  end
  
  context "without error" do
    it "should execute once and succeed" do
      ZeevexReliability::Retryable.retryable do
        runner.succeed_at_once
      end.should == true
      runner.execution_count.should == 1
    end
  end

  context "caught error" do
    it "when block fails twice and then succeeds, should return true" do
      ZeevexReliability::Retryable.retryable(:on => ArgumentError) do
        runner.succeed_eventually
      end.should == true
      runner.execution_count.should == 3
    end

    it "when block always fails, it should stop after 3 tries then re-raise error" do
      expect {
        ZeevexReliability::Retryable.retryable(:on => ArgumentError) do
          runner.never_succeed
        end
      }.to raise_error(ArgumentError)
      runner.execution_count.should == 3
    end

    it "when block always fails, it should stop after # of tries specified then re-raise error" do
      expect {
        ZeevexReliability::Retryable.retryable(:on => ArgumentError, :tries => 10) do
          runner.never_succeed
        end
      }.to raise_error(ArgumentError)
      runner.execution_count.should == 10
    end
  end

  context "uncaught error" do
    it "should fail once and not retry" do
      expect {
        ZeevexReliability::Retryable.retryable(:on => NameError) do
          runner.never_succeed
        end
      }.to raise_error(ArgumentError)
      runner.execution_count.should == 1
    end
  end
end

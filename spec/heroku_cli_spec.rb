require "spec_helper"
require "./lib/heroku_cli.rb"

RSpec.describe HerokuCLI do
  describe "#HerokuCLI.cmd" do
    context "Heroku CLI is found in path" do
      before do
        allow(HerokuCLI).to receive(:path).and_return("valid/path/to/heroku")
      end

      it "should make a system call with the specified arg" do
        expect_any_instance_of(Kernel).to receive(:system).with "valid/path/to/heroku pg:backup --app demo-application"
        HerokuCLI.cmd("pg:backup", "demo-application")
      end
    end
  end
end

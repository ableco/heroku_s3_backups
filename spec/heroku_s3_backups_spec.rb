RSpec.describe HerokuS3Backups do
  it "has a version number" do
    expect(HerokuS3Backups::VERSION).not_to be nil
  end

  describe "Heroku" do
    describe "#initialize" do
      context "valid arguments not provided" do
        it "should raise an error if required args aren't provided" do
          expect { HerokuS3Backups::Heroku.new }.to raise_error(ArgumentError)
        end
      end

      context "valid arguments provided" do
        it "should set the instance variables appropriately" do
          heroku_app = HerokuS3Backups::Heroku.new("demo-application")
          expect(heroku_app.app_name).to eq("demo-application")
        end
      end
    end

    describe "#backup_to_s3" do
      # TODO
    end

    describe "#capture" do
      context "Heroku CLI is found in path" do
        subject { HerokuS3Backups::Heroku.new("demo-application") }
        before do
          allow(HerokuCLI).to receive(:path).and_return("valid/path/to/heroku")
        end

        it "should set maintenance mode to on if maintenance_mode flag is not set" do
          expect_any_instance_of(Kernel).to receive(:system).with("valid/path/to/heroku pg:backups:capture --app demo-application")
          subject.capture
        end
      end
    end

    describe "#download" do
      context "Heroku CLI is found in path" do
        subject { HerokuS3Backups::Heroku.new("demo-application") }
        before do
          allow(HerokuCLI).to receive(:path).and_return("valid/path/to/heroku")
        end

        it "should download the latest backup with the specified filename" do
          expect_any_instance_of(Kernel).to receive(:system).with("valid/path/to/heroku pg:backups:download --output demo.dump --app demo-application")
          subject.download("demo.dump")
        end

        it "should throw an error if a filename isn't specified" do
          expect { subject.download }.to raise_error(ArgumentError)
        end

        it "should throw an error if a filename is an empty string" do
          expect { subject.download("") }.to raise_error(RuntimeError)
        end
      end

      context "Heroku CLI is not found in path" do
        subject { HerokuS3Backups::Heroku.new("demo-application") }
        before do
          allow(File).to receive(:exist?).and_return(false)
        end
        it "should download the latest backup with the specified filename" do
          expect { subject.download("demo.dump") }.to raise_error(RuntimeError)
        end
      end
    end
  end
end

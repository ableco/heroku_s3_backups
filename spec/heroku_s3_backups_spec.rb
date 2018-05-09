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
  end
end

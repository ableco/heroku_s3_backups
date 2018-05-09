require "s3"
require "heroku_s3_backups/version"
require "heroku_cli.rb"
module HerokuS3Backups
  class Heroku
    attr_accessor :app_name
    include HerokuCLI

    # @param {string} app_name
    # @return nil
    def initialize(app_name)
      @app_name = app_name
    end

    # @param {hash} options
    # @return nil
    def backup_to_s3(backup_location, options = { capture: true })

      # Capture backups if toggled
      HerokuCLI.cmd("pg:backups:capture", @app_name) if options[:capture]

      # Generate the filename for the backup
      backup_filename = generate_backup_name

      # Download the latest backup
      # TODO: Be more explicit about which DB to download
      HerokuCLI.cmd("pg:backups:download --output #{backup_filename}", @app_name)

      store_on_s3(backup_location, backup_filename)

      # Remove the backup from the system
      system("rm #{backup_filename}")
    end

    private

    # Stores the recently backed up file in a specified S3 bucket
    # @param {string} backup_location
    # @param {string} backup_filename
    def store_on_s3(backup_location, backup_filename)
      prod_backup_folder = AWS_S3().buckets.find(ENV["S3_PRODUCTION_BACKUP_BUCKET"]).objects(prefix: backup_location)

      backup_obj = prod_backup_folder.build("#{backup_location}/#{backup_filename}")

      # Need to do this to set content length for some reason
      backup_obj.content = open(backup_filename)

      backup_obj.save
    end

    def generate_backup_name
      curr_time = Time.now.strftime("%Y-%m-%d_%H%M%S")
      "backup_#{curr_time}.dump"
    end

    # Instantiates a new S3 service using the provided credentials
    # @return S3::Service
    def AWS_S3
      S3::Service.new(
        access_key_id: ENV["S3_ACCESS_KEY_ID"],
        secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
      )
    end
  end
end

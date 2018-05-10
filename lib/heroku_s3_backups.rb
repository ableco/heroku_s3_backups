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
      @backup_filename = nil
    end

    # Backup Heroku DB to S3
    # Valid options:
    # => {boolean} capture - If true, capture a new backup at the current point in
    #    time. Otherwise, we'll just download the latest backup
    #
    # @param {hash} options
    # @return nil
    def backup_to_s3(backup_location, options = { capture: true })

      # Capture backups if toggled
      capture if options[:capture]

      # Download the latest backup from Heroku and store it on S3
      generate_backup_filename
      download(@backup_filename)
      store_on_s3(backup_location)

      # Remove the backup from the local system
      remove_backup(@backup_filename)
    end

    # Creates a new Heroku backup for a particular moment in time
    # Valid options:
    # => {boolean} maintenance_mode - If true, set the application to go into
    #    maintenance mode to prevent further interaction until the capture is
    #    complete
    # @param {hash} options
    # @return nil
    def capture(options = { maintenance_mode: false })

      # Enable maintenance mode if set
      HerokuCLI.cmd("maintenance:on") if options[:maintenance_mode]

      HerokuCLI.cmd("pg:backups:capture", @app_name)

      # Turn off maintenance mode once capture is complete
      HerokuCLI.cmd("maintenance:off") if options[:maintenance_mode]
    end

    # Download the latest backup
    # TODO: Be more explicit about which DB to download
    # @param {string} output_filename
    def download(output_filename)
      HerokuCLI.cmd("pg:backups:download --output #{output_filename}", @app_name)
    end

    private

    def remove_backup
      system("rm #{@backup_filename}")
      @backup_filename = nil
    end

    # Stores the recently backed up file in a specified S3 bucket
    # @param {string} backup_location
    def store_on_s3(backup_location, backup_filename)
      prod_backup_folder = AWS_S3().buckets.find(ENV["S3_PRODUCTION_BACKUP_BUCKET"]).objects(prefix: backup_location)

      backup_obj = prod_backup_folder.build("#{backup_location}/#{backup_filename}")

      # Need to do this to set content length for some reason
      backup_obj.content = open(@backup_filename)

      backup_obj.save
    end

    def generate_backup_filename
      curr_time = Time.now.strftime("%Y-%m-%d_%H%M%S")
      @backup_filename = "backup_#{curr_time}.dump"
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

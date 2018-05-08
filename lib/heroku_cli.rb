module HerokuCLI
  VALID_HEROKU_CLI_PATHS = [
    "/app/heroku-cli/bin/heroku",
    "/usr/local/bin/heroku",
    "/usr/bin/heroku"
  ]

  # Invokes a command using the Heroku CLI
  # @param {string} arg
  # @param {string} app_name
  # @return nil
  def HerokuCLI.cmd(arg, app_name)
    system("#{HerokuCLI.path} #{arg} --app #{app_name}")
  end

  private

  # Searches for the Heroku CLI and returns a string containing the found path,
  # otherwise it raises an error
  # @return {string}
  def HerokuCLI.path
    path = nil
    VALID_HEROKU_CLI_PATHS.each { |p| path = p if File.exist?(p) }
    if path.nil?
      raise "Heroku cli not found. Install the heroku-cli and ensure the path is set properly"
    end
    path
  end
end
